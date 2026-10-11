Class {
	#name : 'DdFormSpecLayoutBuilder',
	#superclass : 'Object',
	#instVars : [
		'problems',
		'usedNames',
		'widgets',
		'notices',
		'reservedNames',
		'editor',
		'existingWidgets'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

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

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> add: anEntries from: aDictionary items: items at: aPath to: aCollection [

	anEntries do: [ :entry |
		aDictionary at: entry first ifPresent: [ :value |
			(self value: value fits: entry third items: items)
				ifTrue: [
					(entry third = #flag and: [ value = false ]) ifFalse: [
						aCollection add: {
								entry second.
								(self smalltalkValue: value kind: entry third).
								entry third } ] ]
				ifFalse: [
					self
						problem: 'must be ' , (self describeKind: entry third)
						at: aPath , '.' , entry first ] ] ]
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> applyConstraints: aChild at: aModelPath path: aPath [
	"Through DdLayoutEditor>>setConstraints:at:, with the parent's own list of constraints.
	A child of a vertical box that says nothing gets the default of its kind (growsByDefault:)."

	| node parent properties constraints values |
	node := editor nodeAt: aModelPath.
	parent := node parent.
	properties := parent constraintPropertiesFor: node.
	constraints := self objectAt: 'constraints' in: aChild at: aPath.
	constraints isEmpty ifTrue: [
		constraints := self defaultConstraintsFor: aChild in: parent ].
	constraints isEmpty ifTrue: [ ^ self ].
	self
		check: constraints keys
		allowed: (properties collect: [ :each | each key asString ])
		at: aPath , '.constraints'
		what: 'constraint'
		for: 'a child of ' , parent kindLabel.
	values := Dictionary new.
	properties do: [ :property |
		constraints at: property key asString ifPresent: [ :value |
			values
				at: property key
				put: (self constraintValue: value for: property) ] ].
	values isEmpty ifTrue: [ ^ self ].
	[ editor setConstraints: values at: aModelPath ]
		on: Error
		do: [ :error | self problem: error messageText at: aPath , '.constraints' ]
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> applyLayoutProps: aJson at: aModelPath path: aPath [
	"Through DdLayoutEditor>>set:to:at:, which checks the value against the property."

	| props |
	props := self objectAt: 'props' in: aJson at: aPath.
	props keysAndValuesDo: [ :key :value |
		| node property |
		node := editor nodeAt: aModelPath.
		property := node layoutProperties
			            detect: [ :each | (DdFormSpecSchema jsonKeyFor: each) = key ]
			            ifNone: [ nil ].
		property
			ifNil: [
				self
					check: { key }
					allowed: (node layoutProperties collect: [ :each |
							 DdFormSpecSchema jsonKeyFor: each ])
					at: aPath , '.props'
					what: 'property'
					for: node kindLabel ]
			ifNotNil: [
				[
				editor
					set: property
					to: (self layoutValue: value for: property)
					at: aModelPath ]
					on: Error
					do: [ :error |
					self problem: error messageText at: aPath , '.props.' , key ] ] ]
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

{ #category : 'private' }
DdFormSpecLayoutBuilder >> check: aKeys allowed: allowedKeys at: aPath what: aWord for: aWhat [

	aKeys do: [ :key |
		(allowedKeys includes: key) ifFalse: [
			self
				problem: aWord , ' ' , key printString , ' is not allowed for ' , aWhat
					, (allowedKeys isEmpty
							 ifTrue: [ ' (it takes none)' ]
							 ifFalse: [ ' (allowed: ' , (', ' join: allowedKeys) , ')' ])
				at: aPath ] ]
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> check: aNumber childrenOf: aKind at: aPath [

	(DdFormSpecSchema childLimitsFor: aKind) ifNotNil: [ :limits |
		(aNumber >= limits first and: [
			 limits second isNil or: [ aNumber <= limits second ] ]) ifFalse: [
			self
				problem: 'a ' , aKind , ' layout has '
					, (limits second = limits first
							 ifTrue: [ 'exactly ' , limits first printString ]
							 ifFalse: [ 'at least ' , limits first printString ])
					, ' child(ren), not ' , aNumber printString
				at: aPath ] ]
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> childMessageFor: aChild at: aPath index: anIndex in: aKind occupied: occupied [
	"The plain message that puts aChild into a layout of aKind. Constraints come in phase B,
	except a grid cell (two children must never share one, even for a moment) and code."

	| argument |
	(aChild isDictionary and: [ aChild includesKey: 'code' ]) ifTrue: [
		^ self codeMessageFor: aChild at: aPath ].
	argument := self expressionFor: aChild at: aPath.
	aKind = 'scroll' ifTrue: [ ^ 'child: ' , argument ].
	aKind = 'overlay' ifTrue: [
		^ (anIndex = 1
			   ifTrue: [ 'child: ' ]
			   ifFalse: [ 'addOverlay: ' ]) , argument ].
	aKind = 'absolute' ifTrue: [ ^ 'add: ' , argument , ' atPoint: 0 @ 0' ].
	aKind = 'grid' ifTrue: [
		^ self gridMessageFor: aChild argument: argument at: aPath occupied: occupied ].
	^ 'add: ' , argument
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> codeMessageFor: aChild at: aPath [
	"Code the designer could not read when the form was exported: one message to the layout."

	| code parsed |
	code := aChild at: 'code'.
	(aChild keys copyWithout: 'code') isEmpty ifFalse: [
		self problem: 'a code node has nothing but "code"' at: aPath ].
	parsed := code isString
		          ifTrue: [
			          [ RBParser parseExpression: 'layout ' , code ]
				          on: Error
				          do: [ nil ] ]
		          ifFalse: [ nil ].
	(parsed notNil and: [
		 parsed isMessage and: [
			 parsed receiver isVariable and: [ parsed receiver name = 'layout' ] ] ])
		ifFalse: [
			self problem: '"code" must be one message to the layout, e.g. add: x' at: aPath.
			^ 'yourself' ].
	^ code
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> collectNamesIn: aNode at: aPath [
	"First pass: the names written in the description, so a generated or renamed one never
	collides with a name that only comes later in the document. A reserved name is left out
	here (it is renamed when the widget is reached) - unless it is a widget that stays."

	| children |
	aNode isDictionary ifFalse: [ ^ self ].
	(aNode includesKey: 'widget') ifTrue: [
		(aNode at: 'name' ifAbsent: [ nil ]) ifNotNil: [ :name |
			(self isValidName: name)
				ifFalse: [
					self
						problem: 'name ' , name printString , ' is not a valid variable name'
						at: aPath ]
				ifTrue: [
					((self isReserved: name) and: [ (self keeps: aNode) not ]) ifFalse: [
						(usedNames includes: name)
							ifTrue: [ self problem: 'name ' , name printString , ' is used twice' at: aPath ]
							ifFalse: [ usedNames add: name ] ] ] ] ].
	children := aNode at: 'children' ifAbsent: [ #(  ) ].
	(self isList: children) ifFalse: [ ^ self ].
	children withIndexDo: [ :child :i |
		self collectNamesIn: child at: aPath , '.children[' , i printString , ']' ]
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> constraintValue: aValue for: aConstraintProperty [
	"JSON -> what the constraint expects: [2, 1] -> 2@1, 'end' -> #end. Anything else is passed
	on as it is, for the property's own check to refuse."

	aConstraintProperty kind = #point ifTrue: [
		^ (self pointFrom: aValue) ifNil: [
			  ((self isList: aValue) and: [
				   aValue size = 2 and: [ aValue allSatisfy: [ :each | each isInteger ] ] ])
				  ifTrue: [ aValue first @ aValue second ]
				  ifFalse: [ aValue ] ] ].
	(aConstraintProperty kind = #choice and: [ aValue isString ]) ifTrue: [
		^ aValue asSymbol ].
	^ aValue
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> containerExpressionFor: aNode at: aPath [

	| kind direction receiver children occupied messages |
	kind := aNode at: 'layout'.
	direction := (DdFormSpecSchema hasDirection: kind)
		             ifTrue: [
			             self directionOf: aNode at: aPath default: (kind = 'paned'
					              ifTrue: [ 'horizontal' ]
					              ifFalse: [ 'vertical' ]) ]
		             ifFalse: [ nil ].
	receiver := DdFormSpecSchema receiverFor: kind direction: direction.
	receiver ifNil: [
		self
			problem: 'unknown layout ' , kind printString , ' ('
				, (', ' join: DdFormSpecSchema kindsInOrder) , ')'
			at: aPath.
		^ 'nil' ].
	(direction isNil and: [ aNode includesKey: 'direction' ]) ifTrue: [
		self problem: 'a ' , kind , ' layout has no direction' at: aPath ].
	children := aNode at: 'children' ifAbsent: [ #(  ) ].
	(self isList: children) ifFalse: [
		self problem: '"children" must be an array' at: aPath.
		children := #(  ) ].
	children := children asArray.
	self check: children size childrenOf: kind at: aPath.
	occupied := Dictionary new.
	messages := children withIndexCollect: [ :child :i |
		            self
			            childMessageFor: child
			            at: aPath , '.children[' , i printString , ']'
			            index: i
			            in: kind
			            occupied: occupied ].
	^ self cascadeOn: receiver messages: messages
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> defaultConstraintsFor: aChild in: aParent [

	(aParent class == DdBoxNode and: [
		 aParent isHorizontal not and: [ (self growsByDefault: aChild) not ] ])
		ifTrue: [ ^ Dictionary newFrom: { ('expand' -> false) } ].
	^ Dictionary new
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> describeKind: aKind [

	aKind = #string ifTrue: [ ^ 'a text' ].
	aKind = #strings ifTrue: [ ^ 'an array of texts' ].
	(aKind = #boolean or: [ aKind = #flag ]) ifTrue: [ ^ 'true or false' ].
	aKind = #number ifTrue: [ ^ 'a number' ].
	aKind = #indexes ifTrue: [ ^ 'an array of positions in "items", from 1' ].
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

{ #category : 'names' }
DdFormSpecLayoutBuilder >> existingWidgets: aDictionary [
	"Variable name -> JSON type of the widgets the class already has (from the export)."

	existingWidgets := aDictionary
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> expressionFor: aNode at: aPath [

	| kinds |
	aNode isDictionary ifFalse: [
		self problem: 'a node must be a JSON object' at: aPath.
		^ 'nil' ].
	kinds := #( 'layout' 'widget' 'code' ) select: [ :each | aNode includesKey: each ].
	kinds size = 1 ifFalse: [
		self
			problem: 'a node has exactly one of "layout", "widget" or "code"'
			at: aPath.
		^ 'nil' ].
	kinds first = 'code' ifTrue: [
		self problem: 'code can only be a child of a layout' at: aPath.
		^ 'nil' ].
	kinds first = 'widget' ifTrue: [ ^ self widgetExpressionFor: aNode at: aPath ].
	^ self containerExpressionFor: aNode at: aPath
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

{ #category : 'building' }
DdFormSpecLayoutBuilder >> gridMessageFor: aChild argument: anArgument at: aPath occupied: occupied [

	| constraints cell span |
	constraints := (aChild isDictionary
		                ifTrue: [ aChild at: 'constraints' ifAbsent: [ nil ] ]
		                ifFalse: [ nil ]) ifNil: [ Dictionary new ].
	constraints isDictionary ifFalse: [ constraints := Dictionary new ].
	cell := self pointFrom: (constraints at: 'cell' ifAbsent: [ nil ]).
	span := self pointFrom: (constraints at: 'span' ifAbsent: [ #( 1 1 ) ]).
	cell ifNil: [
		self
			problem: 'a grid child needs "cell": [column, row], both from 1'
			at: aPath , '.constraints'.
		^ 'add: ' , anArgument , ' atPoint: 1 @ 1' ].
	span ifNil: [
		self
			problem: '"span" must be [columns, rows], both from 1'
			at: aPath , '.constraints'.
		span := 1 @ 1 ].
	self occupy: cell span: span by: aPath in: occupied.
	^ 'add: ' , anArgument , ' atPoint: ' , (self pointSource: cell) , (span = (1 @ 1)
		   ifTrue: [ '' ]
		   ifFalse: [ ' span: ' , (self pointSource: span) ])
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> growsByDefault: aChild [
	"For a child of a vertical box that says nothing about its height: only what holds content
	of its own grows."

	aChild isDictionary ifFalse: [ ^ true ].
	(aChild includesKey: 'widget') ifTrue: [
		^ #( 'textArea' 'list' ) includes: (aChild at: 'widget') ].
	(aChild at: 'layout' ifAbsent: [ nil ]) = 'box' ifTrue: [
		^ (aChild at: 'direction' ifAbsent: [ 'vertical' ]) = 'vertical' ].
	^ true
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> isIndex: aValue within: items [

	^ aValue isInteger and: [
		  aValue >= 1 and: [ (self isList: items) not or: [ aValue <= items size ] ] ]
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

{ #category : 'names' }
DdFormSpecLayoutBuilder >> keeps: aWidgetNode [
	"Whether aWidgetNode is a widget of the class that stays: same name, same type - or type
	other, which only an existing widget can have."

	| name type |
	existingWidgets ifNil: [ ^ false ].
	name := aWidgetNode at: 'name' ifAbsent: [ ^ false ].
	type := aWidgetNode at: 'widget' ifAbsent: [ ^ false ].
	^ (existingWidgets at: name ifAbsent: [ ^ false ]) = type or: [ type = 'other' ]
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> layoutValue: aValue for: aLayoutProperty [
	"JSON -> what the property expects: 'center' -> #center, [2, 3] -> #(2 3)."

	(aLayoutProperty isAlign and: [ aValue isString ]) ifTrue: [ ^ aValue asSymbol ].
	(aLayoutProperty isIndexList and: [ self isList: aValue ]) ifTrue: [ ^ aValue asArray ].
	^ aValue
]

{ #category : 'accessing' }
DdFormSpecLayoutBuilder >> notices [
"Things that were accepted but not applied (a prop the designer has no property for yet)."

	^ notices
]

{ #category : 'private' }
DdFormSpecLayoutBuilder >> objectAt: aKey in: aNode at: aPath [

	| value |
	value := aNode at: aKey ifAbsent: [ ^ Dictionary new ].
	value isDictionary ifTrue: [ ^ value ].
	self problem: '"' , aKey , '" must be an object' at: aPath.
	^ Dictionary new
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

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> refine: aSource by: aDocument [

	editor := [ DdLayoutEditor on: aSource ]
		          on: Error
		          do: [ :error |
			          self problem: 'the layout does not parse: ' , error messageText at: 'root'.
			          ^ self ].
	self refineContainer: (aDocument at: 'root') at: #(  ) path: 'root'
]

{ #category : 'refining' }
DdFormSpecLayoutBuilder >> refineContainer: aJson at: aModelPath path: aPath [

	| children |
	children := (aJson at: 'children' ifAbsent: [ #(  ) ]) asArray.
	(editor nodeAt: aModelPath) children size = children size ifFalse: [
		self problem: 'every "code" here must add a child (add:, child: ...)' at: aPath.
		^ self ].
	self applyLayoutProps: aJson at: aModelPath path: aPath.
	children withIndexDo: [ :child :i |
		| childPath |
		childPath := aPath , '.children[' , i printString , ']'.
		(child includesKey: 'code') ifFalse: [
			self applyConstraints: child at: aModelPath , { i } path: childPath.
			(child includesKey: 'layout') ifTrue: [
				self refineContainer: child at: aModelPath , { i } path: childPath ] ] ]
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> reservedNames: aCollection [
"The names the target class already uses (its instance variables, inherited ones too):
a widget named like one of them is renamed, never refused."

	reservedNames := (aCollection collect: [ :each | each asString ])
		                 asSet
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> settingsFor: aNode type: aType at: aPath [
	"props and style, checked against DdFormSpecSchema and turned into messages."

	| result entries props style |
	result := OrderedCollection new.
	entries := DdFormSpecSchema widgetProperties at: aType ifAbsent: [ ^ result ].
	props := self
		         withAliases: (self objectAt: 'props' in: aNode at: aPath)
		         for: aType.
	self
		check: props keys
		allowed: (entries collect: [ :each | each first ])
		at: aPath , '.props'
		what: 'property'
		for: aType.
	self
		add: entries
		from: props
		items: (props at: 'items' ifAbsent: [ nil ])
		at: aPath , '.props'
		to: result.
	style := self objectAt: 'style' in: aNode at: aPath.
	self
		check: style keys
		allowed: (DdFormSpecSchema styleProperties collect: [ :each | each first ])
		at: aPath , '.style'
		what: 'style'
		for: aType.
	self
		add: DdFormSpecSchema styleProperties
		from: style
		items: nil
		at: aPath , '.style'
		to: result.
	^ result
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> skeletonFor: aDocument [

	| root |
	aDocument isDictionary ifFalse: [
		self problem: 'the description is not a JSON object' at: ''.
		^ nil ].
	(aDocument at: 'version' ifAbsent: [ nil ]) = DdFormSpecSchema formatVersion ifFalse: [
		self problem: 'must be ' , DdFormSpecSchema formatVersion printString at: 'version' ].
	root := aDocument at: 'root' ifAbsent: [ nil ].
	(root isDictionary and: [ root includesKey: 'layout' ]) ifFalse: [
		self problem: 'must be a container (an object with "layout")' at: 'root'.
		^ nil ].
	self collectNamesIn: root at: 'root'.
	^ 'defaultLayout' , String cr , String tab , '^ ' , (self expressionFor: root at: 'root')
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> smalltalkValue: aValue kind: aKind [

	(#( #strings #indexes ) includes: aKind) ifTrue: [ ^ aValue asArray ].
	^ aValue
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> sourceFor: aDictionary [
	"The defaultLayout method source for a form description. Phase A checks the structure and
	builds a skeleton; only when it has no problem, phase B sets properties and constraints
	through DdLayoutEditor. Every problem found is listed by DdFormSpecError. Afterwards
	#widgets and #notices describe what was read."

	| skeleton |
	problems := OrderedCollection new.
	usedNames := Set new.
	widgets := OrderedCollection new.
	notices := OrderedCollection new.
	skeleton := self skeletonFor: aDictionary.
	problems isEmpty ifFalse: [ ^ DdFormSpecError signalProblems: problems ].
	self refine: skeleton by: aDictionary.
	problems isEmpty ifFalse: [ ^ DdFormSpecError signalProblems: problems ].
	^ editor source
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> value: aValue fits: aKind items: items [

	aKind = #string ifTrue: [ ^ aValue isString ].
	aKind = #strings ifTrue: [
		^ (self isList: aValue) and: [ aValue allSatisfy: [ :each | each isString ] ] ].
	(aKind = #boolean or: [ aKind = #flag ]) ifTrue: [ ^ #( true false ) includes: aValue ].
	aKind = #number ifTrue: [ ^ aValue isNumber ].
	aKind = #indexes ifTrue: [
		^ (self isList: aValue) and: [
			  aValue allSatisfy: [ :each | self isIndex: each within: items ] ] ].
	^ self isIndex: aValue within: items
]

{ #category : 'names' }
DdFormSpecLayoutBuilder >> varNameFor: aWidgetNode [
	"The name from the description - kept for a widget that stays, renamed when the class has
	it for something else; a missing one is made from the widget type (button1, button2 ...).
	An invalid one has already been reported."

	| base index |
	(aWidgetNode includesKey: 'name') ifTrue: [
		| name newName |
		name := aWidgetNode at: 'name'.
		(self isValidName: name) ifFalse: [ ^ 'nil' ].
		((self isReserved: name) not or: [ self keeps: aWidgetNode ]) ifTrue: [ ^ name ].
		newName := self freeNameFrom: name.
		usedNames add: newName.
		notices add:
			name , ' renamed to ' , newName , ': the class already has a variable ' , name.
		^ newName ].
	base := (self class widgetTypes includesKey: (aWidgetNode at: 'widget'))
		        ifTrue: [ aWidgetNode at: 'widget' ]
		        ifFalse: [ 'widget' ].
	index := 1.
	[ self isTaken: base , index printString ] whileTrue: [ index := index + 1 ].
	usedNames add: base , index printString.
	^ base , index printString
]

{ #category : 'building' }
DdFormSpecLayoutBuilder >> widgetExpressionFor: aNode at: aPath [

	| type name |
	type := aNode at: 'widget'.
	type = 'other'
		ifTrue: [
			(self keeps: aNode) ifFalse: [
				self
					problem: 'a widget of type "other" must be one the form already has, with its name'
					at: aPath ] ]
		ifFalse: [
			(self class widgetTypes includesKey: type) ifFalse: [
				self
					problem: 'unknown widget type ' , type printString , ' ('
						, (', ' join: self class widgetTypes keys asSortedCollection) , ')'
					at: aPath ] ].
	(aNode includesKey: 'children') ifTrue: [
		self problem: 'a widget has no children' at: aPath ].
	name := self varNameFor: aNode.
	widgets add: {
			name.
			type.
			(self settingsFor: aNode type: type at: aPath).
			(self keeps: aNode) }.
	^ name
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> widgets [
	"{ varName. jsonType. settings. stays } per widget, in document order. A setting is
	{ selector. value. kind }; kind #flag is a unary message (bold). stays: the class already has
	this widget, with this name and type."

	^ widgets
]

{ #category : 'widgets' }
DdFormSpecLayoutBuilder >> withAliases: aDictionary for: aType [

	| aliases result |
	aliases := DdFormSpecSchema propertyAliases at: aType ifAbsent: [ ^ aDictionary ].
	result := Dictionary new.
	aDictionary keysAndValuesDo: [ :key :value |
		result at: (aliases at: key ifAbsent: [ key ]) put: value ].
	^ result
]
