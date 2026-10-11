Class {
	#name : 'DdFormSpecExporter',
	#superclass : 'Object',
	#instVars : [
		'editor',
		'widgets'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'exporting' }
DdFormSpecExporter class >> descriptionOf: aClass [
	^ self new descriptionOf: aClass
]

{ #category : 'widgets' }
DdFormSpecExporter >> apply: aMessage to: info [
	"A prop or a style setting when the selector is a known one and its argument a literal;
	anything else is left alone (and stays in the code on import)."

	| selector entry |
	selector := DdFormSpecSchema legacySelectors
		            at: aMessage selector asString
		            ifAbsent: [ aMessage selector asString ].
	entry := (DdFormSpecSchema widgetProperties at: (info at: #type) ifAbsent: [ #(  ) ])
		         detect: [ :each | each second = selector ]
		         ifNone: [ nil ].
	entry ifNotNil: [
		(self hasLiteralArgument: aMessage) ifTrue: [
			(info at: #props)
				at: entry first
				put: (DdFormSpecSchema jsonValue: aMessage arguments first value) ].
		^ self ].
	entry := DdFormSpecSchema styleProperties
		         detect: [ :each | each second = selector ]
		         ifNone: [ ^ self ].
	entry third = #flag ifTrue: [
		(info at: #style) at: entry first put: true.
		^ self ].
	(self hasLiteralArgument: aMessage) ifTrue: [
		(info at: #style)
			at: entry first
			put: (DdFormSpecSchema jsonValue: aMessage arguments first value) ]
]

{ #category : 'layout' }
DdFormSpecExporter >> codeJsonFor: aNode [
	"Kept word for word: the import writes it back into the parent's cascade."

	^ Dictionary newFrom: { ('code' -> (self sourceOfMessage: aNode addMessage)) }
]

{ #category : 'layout' }
DdFormSpecExporter >> constraintsJsonFor: aNode values: aDictionary [
	"Only what differs from the default - except a grid cell, which a grid child always needs."

	| json |
	json := Dictionary new.
	(aNode parent constraintPropertiesFor: aNode) do: [ :property |
		| value |
		value := aDictionary at: property key ifAbsent: [ nil ].
		(value notNil and: [ value ~= property default or: [ property key = #cell ] ])
			ifTrue: [
				json
					at: property key asString
					put: (DdFormSpecSchema jsonValue: value) ] ].
	^ json
]

{ #category : 'layout' }
DdFormSpecExporter >> containerJsonFor: aNode at: aPath [

	| kind json props |
	kind := DdFormSpecSchema kindOf: aNode.
	json := Dictionary new.
	json at: 'layout' put: kind.
	(DdFormSpecSchema hasDirection: kind) ifTrue: [
		json at: 'direction' put: (aNode isHorizontal
				 ifTrue: [ 'horizontal' ]
				 ifFalse: [ 'vertical' ]) ].
	props := Dictionary new.
	aNode layoutProperties do: [ :property |
		| value |
		value := editor valueOf: property at: aPath.
		(self isWorthWriting: value for: property) ifTrue: [
			props
				at: (DdFormSpecSchema jsonKeyFor: property)
				put: (DdFormSpecSchema jsonValue: value) ] ].
	props isEmpty ifFalse: [ json at: 'props' put: props ].
	json
		at: 'children'
		put: (aNode children asArray withIndexCollect: [ :child :i |
				 self nodeJsonFor: child at: aPath , { i } ]).
	^ json
]

{ #category : 'exporting' }
DdFormSpecExporter >> descriptionOf: aClass [
	"The form of aClass as a description (a Dictionary ready for STONJSON) in the format the
	import reads. DdFormSpecError when the class has no layout the designer can read."

	(aClass includesSelector: #defaultLayout) ifFalse: [
		^ DdFormSpecError signalProblems: { aClass name , ' has no defaultLayout' } ].
	editor := DdLayoutEditor forClass: aClass.
	(editor root notNil and: [ editor root isContainerNode ]) ifFalse: [
		^ DdFormSpecError signalProblems:
			  { 'the defaultLayout of ' , aClass name , ' is not a layout the designer can read' } ].
	widgets := self widgetsOf: aClass.
	^ Dictionary newFrom: {
			  ('version' -> DdFormSpecSchema formatVersion).
			  ('root' -> (self containerJsonFor: editor root at: #(  ))) }
]

{ #category : 'widgets' }
DdFormSpecExporter >> hasLiteralArgument: aMessage [

	^ aMessage arguments size = 1 and: [ aMessage arguments first isLiteralNode ]
]

{ #category : 'layout' }
DdFormSpecExporter >> isWorthWriting: aValue for: aLayoutProperty [

	aValue ifNil: [ ^ false ].
	aValue = aLayoutProperty default ifTrue: [ ^ false ].
	(aLayoutProperty isAlign and: [ aValue = #none ]) ifTrue: [ ^ false ].
	(aLayoutProperty isIndexList and: [ aValue isEmpty ]) ifTrue: [ ^ false ].
	(aLayoutProperty isString and: [ aValue isEmpty ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : 'layout' }
DdFormSpecExporter >> nodeJsonFor: aNode at: aPath [
	"A child: its own description plus how it sits in its parent."

	| values json constraints |
	values := aNode parent constraintValuesOf: aNode.
	(values isNil or: [
		 aNode isContainerNode not and: [ aNode isWidgetNode not ] ]) ifTrue: [
		^ self codeJsonFor: aNode ].
	json := aNode isWidgetNode
		        ifTrue: [ self widgetJsonFor: aNode ]
		        ifFalse: [ self containerJsonFor: aNode at: aPath ].
	constraints := self constraintsJsonFor: aNode values: values.
	constraints isEmpty ifFalse: [ json at: 'constraints' put: constraints ].
	^ json
]

{ #category : 'widgets' }
DdFormSpecExporter >> presenterClassNameIn: anExpression [
	"PresenterDecorator wrap: X, X new, self newButton -> the presenter class name, or nil."

	anExpression isMessage ifFalse: [ ^ nil ].
	(anExpression selector = #wrap: and: [ anExpression arguments first isVariable ])
		ifTrue: [ ^ anExpression arguments first name asSymbol ].
	anExpression receiver isVariable ifFalse: [ ^ nil ].
	anExpression selector = #new ifTrue: [ ^ anExpression receiver name asSymbol ].
	anExpression receiver name = 'self' ifTrue: [
		^ DdFormSpecSchema factoryClasses at: anExpression selector ifAbsent: [ nil ] ].
	^ nil
]

{ #category : 'widgets' }
DdFormSpecExporter >> read: aStatement into: found [

	| receiver messages info |
	aStatement isAssignment ifTrue: [
		^ self readAssignment: aStatement into: found ].
	aStatement isCascade
		ifTrue: [
			receiver := aStatement receiver.
			messages := aStatement messages ]
		ifFalse: [
			aStatement isMessage ifFalse: [ ^ self ].
			receiver := aStatement receiver.
			messages := { aStatement } ].
	receiver isVariable ifFalse: [ ^ self ].
	info := found at: receiver name asString ifAbsent: [ ^ self ].
	messages do: [ :each | self apply: each to: info ]
]

{ #category : 'widgets' }
DdFormSpecExporter >> readAssignment: anAssignment into: found [

	| value className info |
	value := anAssignment value.
	className := self presenterClassNameIn: (value isCascade
			              ifTrue: [ value receiver ]
			              ifFalse: [ value ]).
	info := Dictionary new.
	info
		at: #class put: className;
		at: #type
		put: ((DdFormSpecSchema widgetClassTypes at: className ifAbsent: [ nil ])
				 ifNil: [ 'other' ]);
		at: #props put: Dictionary new;
		at: #style put: Dictionary new.
	found at: anAssignment variable name asString put: info.
	value isCascade ifTrue: [
		value messages do: [ :each | self apply: each to: info ] ]
]

{ #category : 'layout' }
DdFormSpecExporter >> sourceOfMessage: aMessage [
	"add: (SpBoxLayout new ...) expand: false - without its receiver, arguments in parentheses
	unless they are a plain variable or literal."

	aMessage arguments isEmpty ifTrue: [ ^ aMessage selector asString ].
	^ ' ' join: (aMessage selector keywords
			   with: aMessage arguments
			   collect: [ :keyword :argument |
				   keyword , ' ' , ((argument isLiteralNode or: [ argument isVariable ])
					    ifTrue: [ argument formattedCode ]
					    ifFalse: [ '(' , argument formattedCode , ')' ]) ])
]

{ #category : 'widgets' }
DdFormSpecExporter >> widgetJsonFor: aNode [

	| name info json |
	name := aNode varName asString.
	json := Dictionary new.
	json at: 'name' put: name.
	info := widgets at: name ifAbsent: [ nil ].
	info ifNil: [
		json at: 'widget' put: 'other'.
		^ json ].
	json at: 'widget' put: (info at: #type).
	((info at: #type) = 'other' and: [ (info at: #class) notNil ]) ifTrue: [
		json at: 'class' put: (info at: #class) asString ].
	(info at: #props) isEmpty ifFalse: [ json at: 'props' put: (info at: #props) ].
	(info at: #style) isEmpty ifFalse: [ json at: 'style' put: (info at: #style) ].
	^ json
]

{ #category : 'widgets' }
DdFormSpecExporter >> widgetsOf: aClass [
	"Variable name -> its type, props and style, read from initializePresenters."

	| found source ast |
	found := Dictionary new.
	source := aClass sourceCodeAt: #initializePresenters ifAbsent: [ ^ found ].
	ast := [ OCParser parseMethod: source ]
		       on: Error
		       do: [ ^ found ].
	ast body statements do: [ :statement | self read: statement into: found ].
	^ found
]
