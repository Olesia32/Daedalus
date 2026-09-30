Class {
	#name : 'DdLayoutPropertiesPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'presenterClass',
		'path',
		'kindLabel',
		'rows',
		'notebook',
		'applyButton',
		'applyAction',
		'constraintRows'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdLayoutPropertiesPresenter class >> embeddedForClass: aClass path: aPath [
"Just the content, to be the Layout page of another notebook (the widget property panel)."

	^ self new
		  setClass: aClass path: aPath embedded: true;
		  yourself
]

{ #category : 'instance creation' }
DdLayoutPropertiesPresenter class >> forClass: aClass path: aPath [
"Stand-alone, with its own Layout tab: what the designer shows for a selected container."

	^ self new
		  setClass: aClass path: aPath embedded: false;
		  yourself
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> addOwnSectionFor: aNode editor: anEditor to: aBox [

	kindLabel := self newLabel
		             label: aNode kindLabel;
		             yourself.
	aBox add: kindLabel expand: false.
	aNode layoutProperties isEmpty ifTrue: [
			^ aBox
				  add: (self newLabel
						   label: 'This layout has no properties of its own.';
						   yourself)
				  expand: false ].
	aNode layoutProperties do: [ :property |
			| input |
			input := self
				         newInputFor: property
				         value: (anEditor valueOf: property at: path).
			rows add: property -> input.
			aBox add: (self rowFor: property with: input) expand: false ]
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> addParentSectionFor: aNode in: aContainer editor: anEditor to: aBox [

	| properties values |
	properties := aContainer constraintPropertiesFor: aNode.
	properties isEmpty ifTrue: [ ^ self ].
	aBox
		add: (self newLabel
				 label: 'In ' , aContainer kindLabel;
				 yourself)
		expand: false.
	values := anEditor constraintValuesAt: path.
	values ifNil: [
			^ aBox
				  add: (self newLabel
						   label:
							   'Written in a form the designer cannot edit - change it in the code.';
						   yourself)
				  expand: false ].
	properties do: [ :property |
			| input |
			input := self
				         newConstraintInputFor: property
				         value:
				         (values at: property key ifAbsent: [ property default ]).
			constraintRows add: property -> input.
			aBox add: (self rowFor: property with: input) expand: false ].
	self coupleExpandWithSizeIn: aBox
]

{ #category : 'actions' }
DdLayoutPropertiesPresenter >> apply [
"Writes both sections at once, so one Apply is one undo step."

	| editor |
	[
		editor := DdLayoutEditor forClass: presenterClass.
		rows do: [ :row |
				editor
					set: row key
					to: (self valueOf: row value for: row key)
					at: path ].
		constraintRows isEmpty ifFalse: [
				| values |
				values := Dictionary new.
				constraintRows do: [ :row |
						values
							at: row key key
							put: (self constraintValueOf: row value for: row key) ].
				editor setConstraints: values at: path ].
		editor applyTo: presenterClass ]
		on: Error
		do: [ :error | ^ self inform: error messageText ].
	applyAction ifNotNil: [ :action | action value: editor ]
]

{ #category : 'accessing' }
DdLayoutPropertiesPresenter >> constraintInputFor: aKey [

	^ (constraintRows detect: [ :each | each key key = aKey ]) value
]

{ #category : 'private' }
DdLayoutPropertiesPresenter >> constraintValueOf: anInput for: aProperty [

	| text point |
	aProperty kind = #boolean ifTrue: [ ^ anInput state ].
	aProperty kind = #choice ifTrue: [ ^ anInput selectedItem ].
	text := anInput text asString trimBoth.
	text isEmpty ifTrue: [ ^ aProperty default ].
	aProperty kind = #number ifTrue: [
			^ (Number readFrom: text ifFail: [ nil ]) ifNil: [
				  self error: aProperty label , ': "' , text , '" is not a number' ] ].
	point := [
	         DdLayoutNode pointFromNode: (OCParser parseExpression: text) ]
		         on: Error
		         do: [ nil ].
	^ point ifNil: [
		  self error: aProperty label , ': write it as x@y, for example 2@1' ]
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> coupleExpandWithSizeIn: aBox [

	| expandInput sizeRow sizeInput |
	expandInput := constraintRows
		               detect: [ :each | each key key = #expand ]
		               ifNone: [ ^ self ].
	sizeRow := constraintRows
		           detect: [ :each |
		           #( #width #height ) includes: each key key ]
		           ifNone: [ ^ self ].
	expandInput := expandInput value.
	sizeInput := sizeRow value.
	expandInput whenChangedDo: [ :checked |
		checked ifTrue: [ sizeInput text: '' ] ].
	sizeInput whenTextChangedDo: [ :text |
		text asString trimBoth isEmpty ifFalse: [ expandInput state: false ] ].
	aBox
		add: (self newLabel
				 label:
					 'A fixed ' , sizeRow key label asLowercase
					 , ' turns Expand off.';
				 yourself)
		expand: false
]

{ #category : 'accessing' }
DdLayoutPropertiesPresenter >> inputFor: arg1 [

	^ (rows detect: [ :arg2 | arg2 key selector = arg1 ]) value
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> newConstraintInputFor: aProperty value: aValue [

	aProperty kind = #boolean ifTrue: [
			^ self newCheckBox
				  label: aProperty label;
				  state: aValue == true;
				  yourself ].
	aProperty kind = #choice ifTrue: [
			^ self newDropList
				  items: aProperty choices;
				  display: [ :each | each asString ];
				  selectItem: aValue;
				  yourself ].
	^ self newTextInput
		  text: (aValue ifNil: [ '' ] ifNotNil: [ aValue printString ]);
		  placeholder: (aProperty default
				   ifNil: [ 'natural' ]
				   ifNotNil: [ :default | default printString ]);
		  yourself
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> newInputFor: arg1 value: arg2 [

	| tmp4 |
	arg1 isFlag ifTrue: [
			| tmp2 |
			tmp2 := self newCheckBox.
			tmp2
				label: arg1 label;
				state: arg2 == true.
			^ tmp2 yourself ].
	nil.
	tmp4 := self newTextInput.
	tmp4
		text: (arg2 ifNil: [ '' ] ifNotNil: [ arg2 printString ]);
		placeholder: 'default'.
	^ tmp4 yourself
]

{ #category : 'accessing' }
DdLayoutPropertiesPresenter >> path [

	^ path
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> rowFor: aProperty with: anInput [
"A yes/no value is a checkbox carrying its own label; anything else gets a label in front."

	(anInput isKindOf: SpCheckBoxPresenter) ifTrue: [ ^ anInput ].
	^ SpBoxLayout newLeftToRight
		  spacing: 4;
		  add: (self newLabel
				   label: aProperty label;
				   yourself)
		  width: 120;
		  add: anInput;
		  yourself
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> setClass: aClass path: aPath [

	self setClass: aClass path: aPath embedded: false
]

{ #category : 'initialization' }
DdLayoutPropertiesPresenter >> setClass: aClass path: aPath embedded: aBoolean [
"Two sections: the layout's own properties (only for a container), then how the node sits in
its parent (for anything but the root)."

	| editor node box content |
	presenterClass := aClass.
	path := aPath.
	editor := DdLayoutEditor forClass: aClass.
	node := editor nodeAt: aPath.
	rows := OrderedCollection new.
	constraintRows := OrderedCollection new.
	box := SpBoxLayout newTopToBottom
		       spacing: 6;
		       yourself.
	node isContainerNode ifTrue: [
		self addOwnSectionFor: node editor: editor to: box ].
	node parent ifNotNil: [ :container |
			self
				addParentSectionFor: node
				in: container
				editor: editor
				to: box ].
	(rows isEmpty and: [ constraintRows isEmpty ]) ifTrue: [
			box
				add: (self newLabel
						 label: 'Nothing to set here.';
						 yourself)
				expand: false ].
	applyButton := self newButton
		               label: 'Apply';
		               action: [ self apply ];
		               enabled:
			               (rows notEmpty or: [ constraintRows notEmpty ]);
		               yourself.
	aBoolean ifTrue: [
			box add: applyButton expand: false.
			^ self layout: box ].
	content := SpPresenter new.
	content layout: box.
	notebook := self newNotebook.
	notebook addPage:
		(SpNotebookPage title: 'Layout' provider: [ content ]).
	self layout: (SpBoxLayout newTopToBottom
			 add: notebook;
			 add: applyButton expand: false;
			 yourself)
]

{ #category : 'private' }
DdLayoutPropertiesPresenter >> valueOf: arg1 for: arg2 [

	| tmp1 tmp2 |
	arg2 isFlag ifTrue: [ ^ arg1 state ].
	nil.
	tmp1 := arg1 text asString trimBoth.
	tmp1 isEmpty ifTrue: [ ^ nil ].
	nil.
	tmp2 := Number readFrom: tmp1 ifFail: [ ].
	tmp2
		ifNil: [
		^ self error: arg2 label , ': "' , tmp1 , '" is not a number' ]
		ifNotNil: [ tmp2 ].
	^ tmp2
]

{ #category : 'accessing' }
DdLayoutPropertiesPresenter >> whenAppliedDo: arg1 [

	applyAction := arg1
]
