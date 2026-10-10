Class {
	#name : 'DdFormSpecLayoutBuilder',
	#superclass : 'Object',
	#instVars : [
		'problems',
		'usedNames',
		'widgets',
		'notices',
		'reservedNames'
	],
	#category : 'Daedalus-Daedalus-Import',
	#package : 'Daedalus',
	#tag : 'Daedalus-Import'
}

{ #category : 'constants' }
DdFormSpecLayoutBuilder class >> propertyKinds [

	^ Dictionary newFrom: {
			  ('text' -> #string).
			  ('label' -> #string).
			  ('placeholder' -> #string).
			  ('items' -> #strings).
			  ('checked' -> #boolean).
			  ('password' -> #boolean).
			  ('selected' -> #index).
			  ('min' -> #number).
			  ('max' -> #number).
			  ('value' -> #number) }
]

{ #category : 'constants' }
DdFormSpecLayoutBuilder class >> propertySelectors [

	^ Dictionary newFrom: {
			  ('label' -> #( #( 'text' 'label:' ) #( 'label' 'label:' ) )).
			  ('button' -> #( #( 'label' 'label:' ) )).
			  ('checkbox' -> #( #( 'label' 'label:' ) #( 'checked' 'state:' ) )).
			  ('textInput'
			   -> #( #( 'text' 'text:' ) #( 'placeholder' 'placeholder:' )
				      #( 'password' nil ) )).
			  ('textArea' -> #( #( 'text' 'text:' ) #( 'placeholder'
			         nil ) )).
			  ('list' -> #( #( 'items' 'items:' ) )).
			  ('comboBox'
			   -> #( #( 'items' 'items:' ) #( 'selected' 'selectIndex:' ) )).
			  ('radioGroup'
			   -> #( #( 'items' 'items:' ) #( 'selected' 'itemSelected:' ) )).
			  ('checkboxGroup'
			   -> #( #( 'items' 'items:' ) #( 'selected' 'selectedIndexes:' ) )).
			  ('slider'
			   -> #( #( 'label' 'label:' ) #( 'min' 'min:' ) #( 'max' 'max:' )
				      #( 'value' 'value:' ) )).
			  ('progressBar'
			   -> #( #( 'value' 'value:' ) #( 'min' nil ) #( 'max' nil ) )).
			  ('datePicker' -> #(  )).
			  ('timePicker' -> #(  )) }
]

{ #category : 'building' }
DdFormSpecLayoutBuilder class >> sourceFor: aDictionary [

	^ self new sourceFor: aDictionary
]

{ #category : 'constants' }
DdFormSpecLayoutBuilder class >> widgetTypes [
"JSON widget type -> label of its DdWidgetRegistry descriptor (the next slice creates the variables from it)."

	^ Dictionary newFrom: {
			  ('button' -> 'Button').
			  ('label' -> 'Label').
			  ('textInput' -> 'Text Input').
			  ('textArea' -> 'Text Area').
			  ('list' -> 'List').
			  ('comboBox' -> 'Combobox').
			  ('checkbox' -> 'Checkbox').
			  ('radioGroup' -> 'Group of radiobuttons').
			  ('checkboxGroup' -> 'Group of checkboxes').
			  ('progressBar' -> 'Progress bar').
			  ('slider' -> 'Slider').
			  ('datePicker' -> 'Date picker').
			  ('timePicker' -> 'Time picker') }
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> boxAddFor: aChild sizeKey: aSizeKey at: aPath [
"The shortest add-message, as DdBoxNode>>addMessageFor:values: writes it. expand: false next
to a size is accepted (a fixed size already means it); expand: true next to one is not.
Without constraints, a vertical box decides by the kind of child (see growsByDefault:)."

	| argument constraints size expand |
	argument := self expressionFor: aChild at: aPath.
	constraints := self constraintsOf: aChild at: aPath allowed: {
			               aSizeKey.
			               'expand' }.
	size := constraints at: aSizeKey ifAbsent: [ nil ].
	expand := constraints at: 'expand' ifAbsent: [ nil ].
	size ifNotNil: [
			(self isWholeNumber: size) ifFalse: [
					self
						problem: aSizeKey , ' must be a whole number, 0 or more'
						at: aPath , '.constraints'.
					^ 'add: ' , argument ].
			expand = true ifTrue: [
					self
						problem:
						'a fixed ' , aSizeKey , ' cannot be combined with expand: true'
						at: aPath , '.constraints' ].
			^ 'add: ' , argument , ' ' , aSizeKey , ': ' , size printString ].
	expand ifNil: [
			^ (aSizeKey = 'width' or: [ self growsByDefault: aChild ])
				  ifTrue: [ 'add: ' , argument ]
				  ifFalse: [ 'add: ' , argument , ' expand: false' ] ].
	(#( true false ) includes: expand) ifFalse: [
			self
				problem: 'expand must be true or false'
				at: aPath , '.constraints'.
			^ 'add: ' , argument ].
	^ expand
		  ifTrue: [ 'add: ' , argument ]
		  ifFalse: [ 'add: ' , argument , ' expand: false' ]
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> boxExpressionFor: aNode children: children at: aPath [
"A vertical box sizes its children with height:, a horizontal one with width: - the same
rule as DdBoxNode>>sizeKey."

	| direction sizeKey messages |
	direction := self directionOf: aNode at: aPath default: 'vertical'.
	sizeKey := direction = 'vertical'
		           ifTrue: [ 'height' ]
		           ifFalse: [ 'width' ].
	messages := OrderedCollection new.
	(aNode at: 'spacing' ifAbsent: [ nil ]) ifNotNil: [ :spacing |
			(self isWholeNumber: spacing)
				ifTrue: [ messages add: 'spacing: ' , spacing printString ]
				ifFalse: [
				self
					problem: 'spacing must be a whole number, 0 or more'
					at: aPath ] ].
	children withIndexDo: [ :child :i |
			messages add: (self
					 boxAddFor: child
					 sizeKey: sizeKey
					 at: aPath , '.children[' , i printString , ']') ].
	^ self
		  cascadeOn: 'SpBoxLayout ' , (direction = 'vertical'
				   ifTrue: [ 'newTopToBottom' ]
				   ifFalse: [ 'newLeftToRight' ])
		  messages: messages
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> cascadeOn: aReceiverSource messages: aCollection [
"Always at least two messages, so the result is a cascade DdLayoutParser understands
(the same reason DdBoxNode>>removeChild: never leaves a single one)."

	| messages |
	messages := OrderedCollection withAll: aCollection.
	messages add: 'yourself'.
	messages size < 2 ifTrue: [ messages addFirst: 'yourself' ].
	^ '(' , aReceiverSource , ' ' , ('; ' join: messages) , ')'
]

{ #category : 'properties' }
DdFormSpecLayoutBuilder >> checkProperty: aValue kind: aKind items: items at: aPath [

	(self property: aValue fits: aKind items: items) ifTrue: [ ^ true ].
	self problem: 'must be ' , (self describeKind: aKind) at: aPath.
	^ false
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> collectNamesIn: aNode at: aPath [
"First pass: the names written in the description, so a generated or renamed one never
collides with a name that only comes later in the document. A reserved name is left out
here: it is renamed when the widget is reached."

	| children |
	aNode isDictionary ifFalse: [ ^ self ].
	(aNode includesKey: 'widget') ifTrue: [
			(aNode at: 'name' ifAbsent: [ nil ]) ifNotNil: [ :name |
					(self isValidName: name)
						ifFalse: [
								self
									problem:
									'name ' , name printString , ' is not a valid variable name'
									at: aPath ]
						ifTrue: [
								(self isReserved: name) ifFalse: [
										(usedNames includes: name)
											ifTrue: [
												self
													problem: 'name ' , name printString , ' is used twice'
													at: aPath ]
											ifFalse: [ usedNames add: name ] ] ] ] ].
	children := aNode at: 'children' ifAbsent: [ #(  ) ].
	(self isList: children) ifFalse: [ ^ self ].
	children withIndexDo: [ :child :i |
			self
				collectNamesIn: child
				at: aPath , '.children[' , i printString , ']' ]
]

{ #category : 'constraints' }
DdFormSpecLayoutBuilder >> constraintsOf: aChild at: aPath allowed: allowedKeys [
"The child's constraints. Which keys are allowed depends on the PARENT's layout; any other
key is reported."

	| constraints |
	aChild isDictionary ifFalse: [ ^ Dictionary new ].
	constraints := aChild
		               at: 'constraints'
		               ifAbsent: [ ^ Dictionary new ].
	constraints isDictionary ifFalse: [
			self problem: '"constraints" must be an object' at: aPath.
			^ Dictionary new ].
	constraints keysDo: [ :key |
			(allowedKeys includes: key) ifFalse: [
					self
						problem:
							'constraint ' , key printString , ' is not allowed here'
							, (allowedKeys isEmpty
									 ifTrue: [ ' (this layout takes none)' ]
									 ifFalse: [ ' (allowed: ' , (', ' join: allowedKeys) , ')' ])
						at: aPath , '.constraints' ] ].
	^ constraints
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> containerExpressionFor: aNode at: aPath [

	| kind children |
	kind := aNode at: 'layout'.
	children := aNode at: 'children' ifAbsent: [ #(  ) ].
	(self isList: children) ifFalse: [
			self problem: '"children" must be an array' at: aPath.
			children := #(  ) ].
	kind = 'box' ifTrue: [
		^ self boxExpressionFor: aNode children: children at: aPath ].
	kind = 'paned' ifTrue: [
		^ self panedExpressionFor: aNode children: children at: aPath ].
	kind = 'grid' ifTrue: [
		^ self gridExpressionFor: aNode children: children at: aPath ].
	self
		problem:
		'unknown layout ' , kind printString , ' (box, grid or paned)'
		at: aPath.
	^ 'nil'
]

{ #category : 'properties' }
DdFormSpecLayoutBuilder >> describeKind: aKind [

	aKind = #string ifTrue: [ ^ 'a string' ].
	aKind = #strings ifTrue: [ ^ 'an array of strings' ].
	aKind = #boolean ifTrue: [ ^ 'true or false' ].
	aKind = #number ifTrue: [ ^ 'a number' ].
	^ 'a position in "items", from 1'
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> directionOf: aNode at: aPath default: aString [

	| direction |
	direction := aNode at: 'direction' ifAbsent: [ aString ].
	(#( 'vertical' 'horizontal' ) includes: direction) ifFalse: [
			self
				problem: 'direction must be "vertical" or "horizontal"'
				at: aPath.
			^ aString ].
	^ direction
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> documentExpressionFor: aDocument [

	| root |
	aDocument isDictionary ifFalse: [
			self problem: 'the description is not a JSON object' at: ''.
			^ 'nil' ].
	(aDocument at: 'version' ifAbsent: [ nil ]) = 1 ifFalse: [
		self problem: 'must be 1' at: 'version' ].
	root := aDocument at: 'root' ifAbsent: [ nil ].
	(root isDictionary and: [ root includesKey: 'layout' ]) ifFalse: [
			self
				problem: 'must be a container (an object with "layout")'
				at: 'root'.
			^ 'nil' ].
	self collectNamesIn: root at: 'root'.
	^ self expressionFor: root at: 'root'
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> expressionFor: aNode at: aPath [

	aNode isDictionary ifFalse: [
			self problem: 'a node must be a JSON object' at: aPath.
			^ 'nil' ].
	((aNode includesKey: 'layout') and: [ aNode includesKey: 'widget' ])
		ifTrue: [
				self
					problem:
					'a node is either a container ("layout") or a widget ("widget"), not both'
					at: aPath.
				^ 'nil' ].
	(aNode includesKey: 'widget') ifTrue: [
		^ self widgetExpressionFor: aNode at: aPath ].
	(aNode includesKey: 'layout') ifTrue: [
		^ self containerExpressionFor: aNode at: aPath ].
	self problem: 'a node needs "layout" or "widget"' at: aPath.
	^ 'nil'
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> freeNameFrom: aName [
"titleLabel -> titleLabel2, titleLabel3 ... the first one neither the description nor the
class uses."

	| index |
	index := 2.
	[ self isTaken: aName , index printString ] whileTrue: [
		index := index + 1 ].
	^ aName , index printString
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> gridExpressionFor: aNode children: children at: aPath [

	| messages occupied |
	messages := OrderedCollection new.
	occupied := Dictionary new.
	children withIndexDo: [ :child :i |
			| childPath argument constraints position span |
			childPath := aPath , '.children[' , i printString , ']'.
			argument := self expressionFor: child at: childPath.
			constraints := self
				               constraintsOf: child
				               at: childPath
				               allowed: #( 'position' 'span' ).
			position := self pointFrom:
				            (constraints at: 'position' ifAbsent: [ nil ]).
			span := self pointFrom:
				        (constraints at: 'span' ifAbsent: [ #( 1 1 ) ]).
			position ifNil: [
					self
						problem:
						'a grid child needs "position": [column, row], both from 1'
						at: childPath , '.constraints' ].
			span ifNil: [
					self
						problem: '"span" must be [columns, rows], both from 1'
						at: childPath , '.constraints' ].
			(position notNil and: [ span notNil ]) ifTrue: [
					self
						occupy: position
						span: span
						by: childPath
						in: occupied.
					messages add: (span = (1 @ 1)
							 ifTrue: [
							 'add: ' , argument , ' atPoint: '
							 , (self pointSource: position) ]
							 ifFalse: [
									 'add: ' , argument , ' atPoint: '
									 , (self pointSource: position) , ' span: '
									 , (self pointSource: span) ]) ] ].
	^ self cascadeOn: 'SpGridLayout new' messages: messages
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> growsByDefault: aChild [
"For a child of a vertical box that says nothing about its height."

	aChild isDictionary ifFalse: [ ^ true ].
	(aChild includesKey: 'widget') ifTrue: [
		^ #( 'textArea' 'list' ) includes: (aChild at: 'widget') ].
	(aChild at: 'layout' ifAbsent: [ nil ]) = 'box' ifTrue: [
		^ (aChild at: 'direction' ifAbsent: [ 'vertical' ]) = 'vertical' ].
	"a grid or a paned"
	^ true
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> isList: aValue [

	^ aValue isCollection and: [
		  aValue isString not and: [ aValue isDictionary not ] ]
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> isReserved: aName [

	^ reservedNames notNil and: [ reservedNames includes: aName ]
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> isTaken: aName [

	^ (usedNames includes: aName) or: [ self isReserved: aName ]
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> isValidName: aName [

	aName isString ifFalse: [ ^ false ].
	aName isEmpty ifTrue: [ ^ false ].
	(aName first isLetter and: [ aName first isLowercase ]) ifFalse: [
		^ false ].
	(aName allSatisfy: [ :c |
		 c asInteger < 128 and: [ c isLetter or: [ c isDigit ] ] ])
		ifFalse: [ ^ false ].
	^ (#( 'self' 'super' 'nil' 'true' 'false' 'thisContext' ) includes:
		   aName) not
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> isWholeNumber: aValue [

	^ aValue isInteger and: [ aValue >= 0 ]
]

{ #category : 'accessing' }
DdFormSpecLayoutBuilder >> notices [
"Things that were accepted but not applied (a prop the designer has no property for yet)."

	^ notices
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> occupy: aPosition span: aSpan by: aPath in: occupied [

	aPosition x to: aPosition x + aSpan x - 1 do: [ :column |
			aPosition y to: aPosition y + aSpan y - 1 do: [ :row |
					(occupied at: column @ row ifAbsent: [ nil ])
						ifNil: [ occupied at: column @ row put: aPath ]
						ifNotNil: [ :other |
								self
									problem:
										'cell ' , (self pointSource: column @ row)
										, ' is already taken by ' , other
									at: aPath , '.constraints' ] ] ]
]

{ #category : 'containers' }
DdFormSpecLayoutBuilder >> panedExpressionFor: aNode children: children at: aPath [
"Without a direction a paned is horizontal (left and right) - the usual meaning of a
list-and-details window."

	| direction messages |
	direction := self directionOf: aNode at: aPath default: 'horizontal'.
	children size = 2 ifFalse: [
			self
				problem: 'a paned layout has exactly 2 children, not '
					, children size printString
				at: aPath ].
	messages := OrderedCollection new.
	children withIndexDo: [ :child :i |
			| childPath argument |
			childPath := aPath , '.children[' , i printString , ']'.
			argument := self expressionFor: child at: childPath.
			self constraintsOf: child at: childPath allowed: #(  ).
			messages add: 'add: ' , argument ].
	^ self
		  cascadeOn: 'SpPanedLayout ' , (direction = 'horizontal'
				   ifTrue: [ 'newLeftToRight' ]
				   ifFalse: [ 'newTopToBottom' ])
		  messages: messages
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> pointFrom: aValue [
"[2, 1] -> 2@1; nil for anything that is not two whole numbers from 1."

	((self isList: aValue) and: [ aValue size = 2 ]) ifFalse: [ ^ nil ].
	(aValue allSatisfy: [ :each | each isInteger and: [ each >= 1 ] ])
		ifFalse: [ ^ nil ].
	^ aValue first @ aValue second
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> pointSource: aPoint [

	^ aPoint x printString , ' @ ' , aPoint y printString
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> problem: aString at: aPath [

	problems add: (aPath isEmpty
			 ifTrue: [ aString ]
			 ifFalse: [ aPath , ': ' , aString ])
]

{ #category : 'properties' }
DdFormSpecLayoutBuilder >> propertiesFor: aNode type: aType at: aPath [

	| props entries items result |
	result := OrderedCollection new.
	props := aNode at: 'props' ifAbsent: [ ^ result ].
	props isDictionary ifFalse: [
			self problem: '"props" must be an object' at: aPath.
			^ result ].
	"an unknown type has already been reported"
	entries := self class propertySelectors
		           at: aType
		           ifAbsent: [ ^ result ].
	props keysDo: [ :key |
			(entries anySatisfy: [ :each | each first = key ]) ifFalse: [
					self
						problem:
							'property ' , key printString , ' is not allowed for ' , aType
							, (entries isEmpty
									 ifTrue: [ ' (it takes none)' ]
									 ifFalse: [
											 ' (allowed: '
											 , (', ' join: (entries collect: [ :each | each first ]))
											 , ')' ])
						at: aPath , '.props' ] ].
	items := props at: 'items' ifAbsent: [ nil ].
	entries do: [ :entry |
			props at: entry first ifPresent: [ :value |
					(self
						 checkProperty: value
						 kind: (self class propertyKinds at: entry first)
						 items: items
						 at: aPath , '.props.' , entry first) ifTrue: [
							entry second
								ifNil: [
										notices add:
											aPath , '.props.' , entry first
											, ': accepted, not applied yet' ]
								ifNotNil: [ :selector |
									result add:
										selector -> (self property: value forSelector: selector) ] ] ] ].
	^ result
]

{ #category : 'properties' }
DdFormSpecLayoutBuilder >> property: aValue fits: aKind items: items [

	aKind = #string ifTrue: [ ^ aValue isString ].
	aKind = #strings ifTrue: [
			^ (self isList: aValue) and: [
				  aValue allSatisfy: [ :each | each isString ] ] ].
	aKind = #boolean ifTrue: [ ^ #( true false ) includes: aValue ].
	aKind = #number ifTrue: [ ^ aValue isNumber ].
	"#index: a position in items, when there are items to count"
	^ aValue isInteger and: [
			  aValue >= 1 and: [
				  (self isList: items) not or: [ aValue <= items size ] ] ]
]

{ #category : 'properties' }
DdFormSpecLayoutBuilder >> property: aValue forSelector: aSelector [
"items: takes an Array (STON may hand over another collection); a checkbox group selects by
a list of indexes, the description by one index."

	aSelector = 'items:' ifTrue: [ ^ aValue asArray ].
	aSelector = 'selectedIndexes:' ifTrue: [ ^ { aValue } ].
	^ aValue
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> reservedNames: aCollection [
"The names the target class already uses (its instance variables, inherited ones too):
a widget named like one of them is renamed, never refused."

	reservedNames := (aCollection collect: [ :each | each asString ])
		                 asSet
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> sourceFor: aDictionary [
"The defaultLayout method source for a form description. Every problem is collected first;
if there is any, DdFormSpecError lists them all and no source is answered. Afterwards
#widgets and #notices describe what was read."

	| expression |
	problems := OrderedCollection new.
	usedNames := Set new.
	widgets := OrderedCollection new.
	notices := OrderedCollection new.
	expression := self documentExpressionFor: aDictionary.
	problems isEmpty ifFalse: [
		^ DdFormSpecError signalProblems: problems ].
	^ 'defaultLayout' , String cr , String tab , '^ ' , expression
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> varNameFor: aWidgetNode [
"The name from the description - renamed when the class already has it; a missing one is
made from the widget type (button1, button2 ...). An invalid one has already been reported."

	| base index |
	(aWidgetNode includesKey: 'name') ifTrue: [
			| name newName |
			name := aWidgetNode at: 'name'.
			(self isValidName: name) ifFalse: [ ^ 'nil' ].
			(self isReserved: name) ifFalse: [ ^ name ].
			newName := self freeNameFrom: name.
			usedNames add: newName.
			notices add: name , ' renamed to ' , newName
				, ': the class already has a variable ' , name.
			^ newName ].
	base := (self class widgetTypes includesKey:
		         (aWidgetNode at: 'widget'))
		        ifTrue: [ aWidgetNode at: 'widget' ]
		        ifFalse: [ 'widget' ].
	index := 1.
	[ self isTaken: base , index printString ] whileTrue: [
		index := index + 1 ].
	usedNames add: base , index printString.
	^ base , index printString
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> widgetExpressionFor: aNode at: aPath [

	| type name |
	type := aNode at: 'widget'.
	(self class widgetTypes includesKey: type) ifFalse: [
		self problem: 'unknown widget type ' , type printString at: aPath ].
	(aNode includesKey: 'children') ifTrue: [
		self problem: 'a widget has no children' at: aPath ].
	name := self varNameFor: aNode.
	widgets add: {
			name.
			type.
			(self propertiesFor: aNode type: type at: aPath) }.
	^ name
]

{ #category : 'accessing' }
DdFormSpecLayoutBuilder >> widgets [
"{ varName. jsonType. property messages (selector -> value, in writing order) } per widget,
in document order."

	^ widgets
]
