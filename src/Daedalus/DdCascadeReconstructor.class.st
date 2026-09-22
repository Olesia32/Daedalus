Class {
	#name : 'DdCascadeReconstructor',
	#superclass : 'Object',
	#instVars : [
		'receivers',
		'messageLists',
		'failed'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'reconstructing' }
DdCascadeReconstructor class >> reconstructedRootSourceFor: aMethodNode [
"The source text of the single nested-cascade expression equivalent to aMethodNode's body,
when that body has the flattened 'tmpVar := receiver. tmpVar msg1; msg2. ... ^ tmpVar [yourself]'
shape (as produced when a method's source is lost and Pharo decompiles it from bytecode, or as
written by hand with temps). Answers nil when the body does not match that shape - the caller
then falls back to its normal handling, unchanged."

	^ self new reconstructFrom: aMethodNode
]

{ #category : 'private' }
DdCascadeReconstructor >> expressionTextFor: aVarName appendYourself: aBoolean [
"The source text of the reconstructed expression for aVarName, without surrounding parentheses -
callers add parentheses only where the grammar needs them (as a keyword-message argument)."

	| texts |
	(receivers includesKey: aVarName) ifFalse: [
			failed := true.
			^ '' ].
	texts := (messageLists at: aVarName) collect: [ :each |
		         self textForMessage: each ].
	aBoolean ifTrue: [ texts := texts , { 'yourself' } ].
	texts isEmpty ifTrue: [ ^ receivers at: aVarName ].
	^ (receivers at: aVarName) , ' ' , ('; ' join: texts)
]

{ #category : 'initialization' }
DdCascadeReconstructor >> initialize [
	super initialize.
	receivers := Dictionary new.
	messageLists := Dictionary new.
	failed := false
]

{ #category : 'private' }
DdCascadeReconstructor >> messageListEndsWithYourself: aName [
	| list |
	list := messageLists at: aName ifAbsent: [ ^ false ].
	list isEmpty ifTrue: [ ^ false ].
	^ list last isMessage and: [
		  list last selector = #yourself and: [ list last arguments isEmpty ] ]
]

{ #category : 'private' }
DdCascadeReconstructor >> processAssignment: stmt [
	| name value |
	name := stmt variable name.
	value := stmt value.
	(value isMessage or: [ value isCascade ]) ifFalse: [
			failed := true.
			^ self ].
	value isCascade
		ifTrue: [
				receivers at: name put: value receiver formattedCode.
				messageLists at: name put: value messages asOrderedCollection ]
		ifFalse: [
				receivers at: name put: value formattedCode.
				messageLists at: name put: OrderedCollection new ]
]

{ #category : 'private' }
DdCascadeReconstructor >> processReceiverStatement: stmt [
	| name messages |
	stmt receiver isVariable ifFalse: [
			failed := true.
			^ self ].
	name := stmt receiver name.
	(receivers includesKey: name) ifFalse: [
			failed := true.
			^ self ].
	messages := stmt isCascade
		            ifTrue: [ stmt messages asOrderedCollection ]
		            ifFalse: [ OrderedCollection with: stmt ].
	(messageLists at: name) addAll: messages
]

{ #category : 'private' }
DdCascadeReconstructor >> processStatement: stmt [
	failed ifTrue: [ ^ self ].
	stmt isAssignment ifTrue: [ ^ self processAssignment: stmt ].
	(stmt isMessage or: [ stmt isCascade ]) ifTrue: [
		^ self processReceiverStatement: stmt ].
	failed := true
]

{ #category : 'reconstructing' }
DdCascadeReconstructor >> reconstructFrom: aMethodNode [
"Handles two shapes for the final return, both folded through the same machinery as any other
statement: a bare variable or 'variable yourself' (the fully flattened, decompiler-style form,
one message per statement), and a variable followed directly by a full cascade or single message
(a human-written style: 'box := Ctor. ^ box add: a; add: b; yourself'). Answers nil, leaving the
caller's normal handling untouched, for anything else - including ordinary, already-nested code,
which never has a return value whose receiver is a bare variable."

	| statements returnStatement value rootName |
	statements := aMethodNode body statements.
	statements isEmpty ifTrue: [ ^ nil ].
	returnStatement := statements last.
	returnStatement isReturn ifFalse: [ ^ nil ].
	statements allButLast do: [ :stmt | self processStatement: stmt ].
	failed ifTrue: [ ^ nil ].
	value := returnStatement value.
	value isVariable
		ifTrue: [ rootName := value name ]
		ifFalse: [
				(value isMessage or: [ value isCascade ]) ifFalse: [ ^ nil ].
				value receiver isVariable ifFalse: [ ^ nil ].
				rootName := value receiver name.
				self processReceiverStatement: value ].
	(failed or: [ (receivers includesKey: rootName) not ]) ifTrue: [
		^ nil ].
	^ self
		  expressionTextFor: rootName
		  appendYourself: (self messageListEndsWithYourself: rootName) not
]

{ #category : 'private' }
DdCascadeReconstructor >> textForArgument: anArgumentNode [
	(anArgumentNode isVariable and: [
		 receivers includesKey: anArgumentNode name ]) ifTrue: [
			^ '('
			  ,
			  (self
				   expressionTextFor: anArgumentNode name
				   appendYourself: false) , ')' ].
	(anArgumentNode isMessage and: [
			 anArgumentNode selector = #yourself and: [
					 anArgumentNode receiver isVariable and: [
						 receivers includesKey: anArgumentNode receiver name ] ] ])
		ifTrue: [
				^ '(' , (self
					   expressionTextFor: anArgumentNode receiver name
					   appendYourself: true) , ')' ].
	^ anArgumentNode formattedCode
]

{ #category : 'private' }
DdCascadeReconstructor >> textForMessage: aMessageNode [
	| keywords argTexts |
	aMessageNode arguments isEmpty ifTrue: [
		^ aMessageNode selector asString ].
	keywords := aMessageNode selector keywords.
	argTexts := aMessageNode arguments collect: [ :each |
		            self textForArgument: each ].
	^ ' ' join: (keywords
			   with: argTexts
			   collect: [ :keyword :text | keyword , ' ' , text ])
]
