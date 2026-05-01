Class {
	#name : 'DdPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetPresenter',
		'labelInput',
		'editedClass',
		'canvas',
		'applyButton'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> applyLabelChange: aString [

	| props builder source |
	props := DdLabelProperties new
		         varName: 'label';
		         label: aString;
		         yourself.
	builder := DdInitializeCodeBuilder new
		           presenterClass: editedClass
		           properties: { props }.
	source := builder generate.
	(editedClass compile: source) ifNotNil: [
			canvas rebuildPreview ]
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> defaultLayout [ 
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: 'Properties' expand: false;
        add: labelInput expand: false;
        add: applyButton expand: false;
        yourself
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> initializePresenters [ 
    super initializePresenters.
    labelInput := self newTextInput.
    labelInput placeholder: ''.
    applyButton := self newButton.
    applyButton 
        label: 'Apply';
        action: [ self applyLabelChange: labelInput text]
]

{ #category : 'accessing' }
DdPropertyPanelPresenter >> loadProperties [ 
    | labelPresenter |
    targetPresenter ifNil: [ ^ self ].
    labelPresenter := targetPresenter instVarNamed: 'label'.
    labelInput text: labelPresenter label.
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> target: aPresenter onClass: aClass canvas: aCanvas [
	"aPresenter — живий об'єкт preview,
     aClass     — клас який редагуємо (DdInnerDemoPresenter),
     aCanvas    — щоб викликати rebuildPreview після компіляції"

	targetPresenter := aPresenter.
	editedClass := aClass.
	canvas := aCanvas.
	self loadProperties
]
