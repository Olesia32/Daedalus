Class {
	#name : 'DdFormSpecSchema',
	#superclass : 'Object',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'layouts' }
DdFormSpecSchema class >> childLimitsFor: aKind [
	"{ min. max } children, max nil = no limit; nil when any number will do."

	aKind = 'paned' ifTrue: [ ^ #( 2 2 ) ].
	(#( 'scroll' 'frame' ) includes: aKind) ifTrue: [ ^ #( 1 1 ) ].
	aKind = 'overlay' ifTrue: [ ^ #( 1 nil ) ].
	^ nil
]

{ #category : 'layouts' }
DdFormSpecSchema class >> childRuleFor: aKind [
	"Said in the prompt next to the layout."

	aKind = 'paned' ifTrue: [ ^ 'Exactly 2 children' ].
	(#( 'scroll' 'frame' ) includes: aKind) ifTrue: [ ^ 'Exactly 1 child' ].
	aKind = 'overlay' ifTrue: [
		^ 'The first child is the content, the others are drawn on top of it and only they take constraints' ].
	aKind = 'grid' ifTrue: [ ^ 'Every child needs "cell"' ].
	aKind = 'absolute' ifTrue: [
		^ '"position" and "extent" are pixels, from the top left corner' ].
	^ nil
]

{ #category : 'layouts' }
DdFormSpecSchema class >> directionsFor: aKind [
	"nil: a layout without direction."

	^ (self hasDirection: aKind)
		  ifTrue: [ #( 'vertical' 'horizontal' ) ]
		  ifFalse: [ { nil } ]
]

{ #category : 'widgets' }
DdFormSpecSchema class >> factoryClasses [
	"self newButton and friends -> the class they create."

	^ Dictionary newFrom: {
			  (#newButton -> #SpButtonPresenter).
			  (#newLabel -> #SpLabelPresenter).
			  (#newTextInput -> #SpTextInputFieldPresenter).
			  (#newText -> #SpTextPresenter).
			  (#newList -> #SpListPresenter).
			  (#newCheckBox -> #SpCheckBoxPresenter).
			  (#newSlider -> #SpSliderPresenter).
			  (#newProgressBar -> #SpProgressBarPresenter) }
]

{ #category : 'format' }
DdFormSpecSchema class >> formatVersion [
	^ 2
]

{ #category : 'layouts' }
DdFormSpecSchema class >> hasDirection: aKind [
	^ #( 'box' 'paned' ) includes: aKind
]

{ #category : 'layouts' }
DdFormSpecSchema class >> jsonKeyFor: aLayoutProperty [
	"Made from the property's selector, so a property added to a node gets its key for free:
	spacing: -> spacing, beHomogeneous -> homogeneous, hAlign -> hAlign,
	positionOfSlider: -> positionOfSlider, column:expand: -> expandColumns."

	| selector |
	selector := aLayoutProperty selector asString.
	aLayoutProperty isFlag ifTrue: [
		^ (selector beginsWith: 'be')
			  ifTrue: [ (selector allButFirst: 2) uncapitalized ]
			  ifFalse: [ selector ] ].
	aLayoutProperty isIndexList ifTrue: [
		^ 'expand' , (selector copyUpTo: $:) capitalized , 's' ].
	^ selector copyWithout: $:
]

{ #category : 'values' }
DdFormSpecSchema class >> jsonValue: aValue [
	"A value of the model as JSON has it: 2@1 -> [2, 1], #center -> 'center'."

	aValue isSymbol ifTrue: [ ^ aValue asString ].
	aValue isString ifTrue: [ ^ aValue ].
	(aValue isKindOf: Point) ifTrue: [
		^ {
			  aValue x.
			  aValue y } ].
	aValue isCollection ifTrue: [
		^ (aValue collect: [ :each | self jsonValue: each ]) asArray ].
	^ aValue
]

{ #category : 'layouts' }
DdFormSpecSchema class >> kindNames [
	"Node class -> JSON layout kind."

	^ Dictionary newFrom: {
			  (#DdBoxNode -> 'box').
			  (#DdPanedNode -> 'paned').
			  (#DdGridNode -> 'grid').
			  (#DdAbsoluteNode -> 'absolute').
			  (#DdScrollNode -> 'scroll').
			  (#DdOverlayNode -> 'overlay').
			  (#DdFrameNode -> 'frame') }
]

{ #category : 'layouts' }
DdFormSpecSchema class >> kindOf: aNode [
	"The nearest class in aNode's hierarchy that has a kind, so a new subclass of a known
	node is read as that node."

	| class |
	class := aNode class.
	[ class notNil ] whileTrue: [
		(self kindNames at: class name ifAbsent: [ nil ]) ifNotNil: [ :kind | ^ kind ].
		class := class superclass ].
	^ nil
]

{ #category : 'layouts' }
DdFormSpecSchema class >> kindsInOrder [
	^ #( 'box' 'paned' 'grid' 'absolute' 'scroll' 'overlay' 'frame' )
]

{ #category : 'widgets' }
DdFormSpecSchema class >> legacySelectors [
	"Selectors found in older code, read as the ones they stand for. The first one is
	columnCount: written with a Cyrillic first letter."

	^ Dictionary newFrom: { ('columnCount:' -> 'columnCount:') }
]

{ #category : 'widgets' }
DdFormSpecSchema class >> propertyAliases [
	"Another key a model tends to use for a prop: label of a label widget is its text."

	^ Dictionary newFrom: { ('label' -> (Dictionary newFrom: { ('label' -> 'text') })) }
]

{ #category : 'layouts' }
DdFormSpecSchema class >> receiverFor: aKind direction: aDirection [
	"The factory expression a layout of aKind starts with, or nil for an unknown kind."

	aKind = 'box' ifTrue: [
		^ aDirection = 'horizontal'
			  ifTrue: [ 'SpBoxLayout newLeftToRight' ]
			  ifFalse: [ 'SpBoxLayout newTopToBottom' ] ].
	aKind = 'paned' ifTrue: [
		^ aDirection = 'vertical'
			  ifTrue: [ 'SpPanedLayout newTopToBottom' ]
			  ifFalse: [ 'SpPanedLayout newLeftToRight' ] ].
	^ (Dictionary newFrom: {
			   ('grid' -> 'SpGridLayout new').
			   ('absolute' -> 'DdAbsoluteLayout new').
			   ('scroll' -> 'SpScrollableLayout new').
			   ('overlay' -> 'SpOverlayLayout new').
			   ('frame' -> 'SpFrameLayout new') }) at: aKind ifAbsent: [ nil ]
]

{ #category : 'layouts' }
DdFormSpecSchema class >> sampleSourceFor: aKind direction: aDirection [
	"A small layout of aKind with children, for reading what its node allows (the prompt)."

	| children |
	children := (Dictionary newFrom: {
			             ('box' -> 'add: a').
			             ('paned' -> 'add: a; add: b').
			             ('grid' -> 'add: a atPoint: 1 @ 1').
			             ('absolute' -> 'add: a atPoint: 0 @ 0').
			             ('scroll' -> 'child: a').
			             ('overlay' -> 'child: a; addOverlay: b').
			             ('frame' -> 'add: a') }) at: aKind.
	^ (self receiverFor: aKind direction: aDirection) , ' ' , children , '; yourself'
]

{ #category : 'widgets' }
DdFormSpecSchema class >> styleProperties [
	"The Style tab (DdBasePresenterPropertyDescriptor), the same for every widget.
	#flag: a unary message, present or not (bold, italic)."

	^ #( #( 'fontSize' 'fontSize:' #number ) #( 'color' 'color:' #string )
	     #( 'backgroundColor' 'backgroundColor:' #string )
	     #( 'borderColor' 'borderColor:' #string ) #( 'borderWidth' 'borderWidth:' #number )
	     #( 'bold' 'bold' #flag ) #( 'italic' 'italic' #flag ) #( 'width' 'width:' #number )
	     #( 'height' 'height:' #number ) )
]

{ #category : 'widgets' }
DdFormSpecSchema class >> typeOfClassNamed: aName [
	"The JSON widget type of a presenter class: one of the palette, one named after a Spec
	presenter (LabelPresenter is SpLabelPresenter, CheckboxPresenter is SpCheckBoxPresenter), or
	one inheriting from a palette class. other for anything else."

	| known class |
	aName ifNil: [ ^ 'other' ].
	known := self widgetClassTypes.
	(known at: aName asSymbol ifAbsent: [ nil ]) ifNotNil: [ :type | ^ type ].
	known keysAndValuesDo: [ :className :type |
		className asString asLowercase = ('sp' , aName asString asLowercase) ifTrue: [
			^ type ] ].
	class := Smalltalk globals at: aName asSymbol ifAbsent: [ ^ 'other' ].
	class isClass ifFalse: [ ^ 'other' ].
	known keysAndValuesDo: [ :className :type |
		(Smalltalk globals at: className ifAbsent: [ nil ]) ifNotNil: [ :knownClass |
			(class inheritsFrom: knownClass) ifTrue: [ ^ type ] ] ].
	^ 'other'

]

{ #category : 'widgets' }
DdFormSpecSchema class >> widgetClassTypes [
	"Presenter class name -> JSON widget type: the classes of the palette, plus the one Spec's
	own newTextInput creates."

	| types |
	types := Dictionary new.
	DdFormSpecLayoutBuilder widgetTypes keysAndValuesDo: [ :type :label |
		(DdWidgetRegistry all
			 detect: [ :each | each label = label ]
			 ifNone: [ nil ]) ifNotNil: [ :descriptor |
			types at: descriptor presenterClass name put: type ] ].
	types at: #SpTextInputFieldPresenter put: 'textInput'.
	^ types
]

{ #category : 'widgets' }
DdFormSpecSchema class >> widgetProperties [
	"JSON widget type -> its props as { json key. selector. kind }, in writing order. The
	selectors are the ones the property descriptors write."

	^ Dictionary newFrom: {
			  ('label' -> #( #( 'text' 'label:' #string ) )).
			  ('button' -> #( #( 'label' 'label:' #string ) )).
			  ('checkbox' -> #( #( 'label' 'label:' #string ) #( 'checked' 'state:' #boolean ) )).
			  ('textInput'
			   -> #( #( 'text' 'text:' #string ) #( 'placeholder' 'placeholder:' #string ) )).
			  ('textArea' -> #( #( 'text' 'text:' #string ) )).
			  ('list' -> #( #( 'items' 'items:' #strings ) )).
			  ('comboBox'
			   -> #( #( 'items' 'items:' #strings ) #( 'selected' 'selectIndex:' #index ) )).
			  ('radioGroup'
			   ->
			   #( #( 'title' 'title:' #string ) #( 'showTitle' 'showTitle:' #boolean )
			      #( 'showFrame' 'showFrame:' #boolean ) #( 'columns' 'columnCount:' #number )
			      #( 'items' 'items:' #strings ) #( 'selected' 'itemSelected:' #index ) )).
			  ('checkboxGroup'
			   ->
			   #( #( 'title' 'title:' #string ) #( 'showTitle' 'showTitle:' #boolean )
			      #( 'showFrame' 'showFrame:' #boolean ) #( 'columns' 'columnCount:' #number )
			      #( 'items' 'items:' #strings ) #( 'selected' 'selectedIndexes:' #indexes ) )).
			  ('slider'
			   ->
			   #( #( 'label' 'label:' #string ) #( 'min' 'min:' #number ) #( 'max' 'max:' #number )
			      #( 'value' 'value:' #number ) #( 'quantum' 'quantum:' #number ) )).
			  ('progressBar' -> #( #( 'value' 'value:' #number ) )).
			  ('datePicker' -> #( #( 'date' 'date:' #string ) )).
			  ('timePicker'
			   ->
			   #( #( 'hour' 'hour:' #number ) #( 'minutes' 'minutes:' #number )
			      #( 'okLabel' 'okButtonLabel:' #string )
			      #( 'cancelLabel' 'cancelButtonLabel:' #string ) )) }
]
