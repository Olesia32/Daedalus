Class {
	#name : 'DdPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetPresenter',
		'labelInput',
		'editedClass',
		'canvas',
		'applyButton',
		'subPresenter'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> applyLabelChange: aString [

	| props builder source varName |
	varName := self varNameForSubPresenter.
	varName ifNil: [ ^ self ].

	props := DdLabelProperties new
		         varName: varName;
		         label: aString;
		         yourself.

	builder := DdInitializeCodeBuilder new
		           presenterClass: editedClass
		           properties: { props }.

	source := builder generate.
	(editedClass compile: source) ifNotNil: [
			canvas rebuildPreview. ]
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> defaultLayout [

	| tmp2 |
	tmp2 := SpBoxLayout newTopToBottom.
	tmp2
		spacing: 10;
		add: 'Properties' expand: false;
		add: labelInput expand: false;
		add: applyButton expand: false.
	^ tmp2 yourself
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> initializePresenters [

	super initializePresenters.
	labelInput := self newTextInput.
	labelInput placeholder: ''.
	applyButton := self newButton.
	applyButton
		label: 'Apply';
		action: [ self applyLabelChange: labelInput text ]
]

{ #category : 'accessing' }
DdPropertyPanelPresenter >> loadProperties [ 
    | labelPresenter |
    targetPresenter ifNil: [ ^ self ].
    labelPresenter := targetPresenter instVarNamed: 'label'.
    labelInput text: labelPresenter label.
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> loadPropertiesFor: arg1 [

	arg1
		ifNil: [
				labelInput text: ''.
				^ self ]
		ifNotNil: [ arg1 ].
	(arg1 isKindOf: SpLabelPresenter) ifTrue: [
			labelInput text: arg1 label.
			^ self ].
	nil.
	labelInput text: ''
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> target: arg1 onClass: arg2 canvas: arg3 [

	targetPresenter := arg1.
	editedClass := arg2.
	canvas := arg3.
	self loadProperties
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> target: aPresenter subPresenter: aSubPresenter onClass: aClass canvas: aCanvas [ 

    targetPresenter := aPresenter.
    subPresenter := aSubPresenter.
    editedClass := aClass.
    canvas := aCanvas.

    self loadPropertiesFor: aSubPresenter

]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> varNameForSubPresenter [ 

    | names |

    targetPresenter ifNil: [ ^ 'label' ].

    names := targetPresenter class allInstVarNames.

    1 to: targetPresenter class instSize do: [ :i |
        (targetPresenter instVarAt: i) == subPresenter ifTrue: [
            ^ names at: i ] ].

    ^ nil
]
