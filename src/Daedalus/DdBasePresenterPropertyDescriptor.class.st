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

	| panel tmp2 |
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
		| tmp3 |
		tmp3 := aPresenter styleProperties.
		fontSizeInput text: (tmp3 at: #fontSize ifAbsent: [ '' ]) asString.
		colorInput text: (tmp3 at: #color ifAbsent: [ '' ]).
		backgroundColorInput text:
			(tmp3 at: #backgroundColor ifAbsent: [ '' ]).
		borderColorInput text: (tmp3 at: #borderColor ifAbsent: [ '' ]).
		borderWidthInput text:
			(tmp3 at: #borderWidth ifAbsent: [ '' ]) asString.
		boldCheckbox state: (tmp3 at: #bold ifAbsent: [ false ]).
		italicCheckbox state: (tmp3 at: #italic ifAbsent: [ false ]).
		widthInput text: (tmp3 at: #width ifAbsent: [ '' ]) asString.
		heightInput text: (tmp3 at: #height ifAbsent: [ '' ]) asString ]
		on: Error
		do: [ ].
	panel := SpBoxLayout newTopToBottom spacing: 4.
	
    "Специфічні поля зверху — підкласи додають свої"
    self addSpecificFieldsTo: panel for: aPresenter.

    "Стильові поля"
    panel

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
	tmp2 := SpPresenter new.
	tmp2 layout: panel.
	^ tmp2
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> collectPropertiesWithVarName: arg1 [

	| tmp1 tmp2 |
	tmp1 := OrderedCollection new.
	tmp2 := DdStyleProperties new.
	tmp2 varName: arg1.
	fontSizeInput text ifNotEmpty: [ :arg2 |
		tmp2 at: 'fontSize:' put: arg2 asInteger ].
	colorInput text ifNotEmpty: [ :arg3 | tmp2 at: 'color:' put: arg3 ].
	backgroundColorInput text ifNotEmpty: [ :arg4 |
		tmp2 at: 'backgroundColor:' put: arg4 ].
	borderColorInput text ifNotEmpty: [ :arg5 |
		tmp2 at: 'borderColor:' put: arg5 ].
	borderWidthInput text ifNotEmpty: [ :arg6 |
		tmp2 at: 'borderWidth:' put: arg6 asInteger ].
	boldCheckbox state ifTrue: [ tmp2 at: 'bold' put: nil ].
	italicCheckbox state ifTrue: [ tmp2 at: 'italic' put: nil ].
	widthInput text ifNotEmpty: [ :arg7 |
		tmp2 at: 'width:' put: arg7 asInteger ].
	heightInput text ifNotEmpty: [ :arg8 |
		tmp2 at: 'height:' put: arg8 asInteger ].
	tmp2 properties ifNotEmpty: [ tmp1 add: tmp2 ].
	^ tmp1
]

{ #category : 'as yet unclassified' }
DdBasePresenterPropertyDescriptor >> rowFor: arg1 input: arg2 [

	| tmp2 |
	tmp2 := SpBoxLayout newLeftToRight.
	tmp2
		spacing: 4;
		add: (SpLabelPresenter new label: arg1) width: 80;
		add: arg2.
	^ tmp2 yourself
]
