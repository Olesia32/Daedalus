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
    (editedClass compile: source)
        ifNil: [ self inform: 'Compilation error' ]
        ifNotNil: [
            (targetPresenter instVarNamed: varName) label: aString ]
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

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> loadPropertiesFor: arg1 [ 
    arg1 ifNil: [
        labelInput text: ''.
        ^ self ].

    [ labelInput text: arg1 label ]
        on: Error
        do: [ labelInput text: '' ]

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
        | ivar |
        ivar := targetPresenter instVarAt: i.
        ivar == subPresenter ifTrue: [ ^ names at: i ].
        (ivar respondsTo: #mainPresenter) ifTrue: [
            ivar mainPresenter == subPresenter ifTrue: [ ^ names at: i ] ] ].

    ^ nil
]
