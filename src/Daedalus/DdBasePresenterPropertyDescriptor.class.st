"
I am the base class for all widget property descriptors. I own and build the common style fields (font, colors, borders, size) that
apply to every widget type. Subclasses extend me with widget-specific fields by overriding `addSpecificFieldsTo:for:`.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor` (this is me)

### Instance Variables
- _fontSizeInput_: `SpTextInputFieldPresenter`
- _colorInput_: `SpTextInputFieldPresenter`
- _backgroundColorInput_: `SpTextInputFieldPresenter`
- _borderColorInput_: `SpTextInputFieldPresenter`
- _borderWidthInput_: `SpTextInputFieldPresenter`
- _boldCheckbox_: `SpCheckBoxPresenter`
- _italicCheckbox_: `SpCheckBoxPresenter`
- _widthInput_: `SpTextInputFieldPresenter`
- _heightInput_: `SpTextInputFieldPresenter`
"
Class {
	#name : 'DdBasePresenterPropertyDescriptor',
	#superclass : 'DdPropertyDescriptor',
	#instVars : [
		'fontSizeInput',
		'colorInput',
		'backgroundColorInput',
		'borderColorInput',
		'borderWidthInput',
		'boldCheckbox',
		'italicCheckbox',
		'widthInput',
		'heightInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdBasePresenterPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> buildPanelFor: aPresenter [
"Builds and returns a presenter containing only the widget-specific fields by calling addSpecificFieldsTo:for: on a fresh layout."
	| specificLayout |
	self initializeFieldsFor: aPresenter.
	specificLayout := SpBoxLayout newTopToBottom spacing: 4.
	self addSpecificFieldsTo: specificLayout for: aPresenter.

	^ SpPresenter new
		  layout: specificLayout;
		  yourself
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> buildStylePanelFor: aPresenter [
"Builds and returns a presenter with all common style fields (font size, colors, border, bold, italic, width, height)."

	| styleLayout |
	fontSizeInput ifNil: [ self initializeFieldsFor: aPresenter ].
	styleLayout := SpBoxLayout newTopToBottom spacing: 4.
	styleLayout
		add: (self rowFor: 'Font size' input: fontSizeInput) expand: false;
		add: (self rowFor: 'Color' input: colorInput) expand: false;
		add: (self rowFor: 'Background' input: backgroundColorInput)
		expand: false;
		add: (self rowFor: 'Border color' input: borderColorInput)
		expand: false;
		add: (self rowFor: 'Border width' input: borderWidthInput)
		expand: false;
		add: boldCheckbox expand: false;
		add: italicCheckbox expand: false;
		add: (self rowFor: 'Width' input: widthInput) expand: false;
		add: (self rowFor: 'Height' input: heightInput) expand: false.

	^ SpPresenter new
		  layout: styleLayout;
		  yourself
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> collectPropertiesWithVarName: varName [
	"Reads all style fields and returns a collection of DdGenericProperties and DdUnaryProperties, one per filled field."

	| result |
	result := OrderedCollection new.

	fontSizeInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'fontSize:';
					 value: v asInteger;
					 yourself) ].

	colorInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'color:';
					 value: v;
					 yourself) ].

	backgroundColorInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'backgroundColor:';
					 value: v;
					 yourself) ].

	borderColorInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'borderColor:';
					 value: v;
					 yourself) ].

	borderWidthInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'borderWidth:';
					 value: v asInteger;
					 yourself) ].

	result add: (DdUnaryProperties new
    varName: varName;
    selector: 'bold';
    state: boldCheckbox state;
    yourself).

result add: (DdUnaryProperties new
    varName: varName;
    selector: 'italic';
    state: italicCheckbox state;
    yourself).

	widthInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'width:';
					 value: v asInteger;
					 yourself) ].

	heightInput text ifNotEmpty: [ :v |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'height:';
					 value: v asInteger;
					 yourself) ].

	^ result
]

{ #category : 'initialization' }
DdBasePresenterPropertyDescriptor >> initializeFieldsFor: aPresenter [
"Creates and pre-populates all style input fields from aPresenter's current styleProperties. Errors are silently swallowed so missing
properties degrade gracefully."

	fontSizeInput := SpTextInputFieldPresenter new.
	colorInput := SpTextInputFieldPresenter new.
	backgroundColorInput := SpTextInputFieldPresenter new.
	borderColorInput := SpTextInputFieldPresenter new.
	borderWidthInput := SpTextInputFieldPresenter new.
	boldCheckbox := SpCheckBoxPresenter new label: 'Bold'.
	italicCheckbox := SpCheckBoxPresenter new label: 'Italic'.
	widthInput := SpTextInputFieldPresenter new.
	heightInput := SpTextInputFieldPresenter new.

	[
		| tmp |
		tmp := aPresenter styleProperties.
		fontSizeInput text: (tmp at: #fontSize ifAbsent: [ '' ]) asString.
		colorInput text: (tmp at: #color ifAbsent: [ '' ]).
		backgroundColorInput text:
			(tmp at: #backgroundColor ifAbsent: [ '' ]).
		borderColorInput text: (tmp at: #borderColor ifAbsent: [ '' ]).
		borderWidthInput text:
			(tmp at: #borderWidth ifAbsent: [ '' ]) asString.
		boldCheckbox state: (tmp at: #bold ifAbsent: [ false ]).
		italicCheckbox state: (tmp at: #italic ifAbsent: [ false ]).
		widthInput text: (tmp at: #width ifAbsent: [ '' ]) asString.
		heightInput text: (tmp at: #height ifAbsent: [ '' ]) asString ]
		on: Error
		do: [ ]
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> rowFor: arg1 input: arg2 [
"Returns a left-to-right row layout with a fixed-width label and an input field, used to build uniform property rows."

	| tmp2 |
	tmp2 := SpBoxLayout newLeftToRight.
	tmp2
		spacing: 4;
		add: (SpLabelPresenter new label: arg1) width: 80;
		add: arg2.
	^ tmp2 yourself
]
