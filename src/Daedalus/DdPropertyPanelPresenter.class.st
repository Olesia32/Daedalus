Class {
	#name : 'DdPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetPresenter',
		'subPresenter',
		'editedClass',
		'canvas',
		'descriptor',
		'applyButton',
		'descriptorPanel'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'private' }
DdPropertyPanelPresenter >> applyChanges [

	| propsList builder source varName |
	descriptor ifNil: [ ^ self ].
	varName := self varNameForSubPresenter.
	varName ifNil: [ ^ self ].

	propsList := descriptor collectPropertiesWithVarName: varName.
	propsList ifEmpty: [ ^ self ].

	builder := DdInitializeCodeBuilder new
		           presenterClass: editedClass
		           properties: propsList.
	source := builder generate.

	(editedClass compile: source)
		ifNil: [ self inform: 'Compilation error' ]
		ifNotNil: [ propsList do: [ :props | props applyTo: subPresenter ]. canvas refreshPreview ]
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> defaultLayout [ 

    | layout titleLabel title |
    
    title := self varNameForSubPresenter ifNil: [ 'Properties' ].

    titleLabel := SpLabelPresenter new
        label: title;
        yourself.

    layout := SpBoxLayout newTopToBottom
        spacing: 6;
        add: titleLabel expand: false.

    descriptorPanel ifNotNil: [
        layout add: descriptorPanel expand: true ].

    layout add: applyButton expand: false.

    ^ layout yourself
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> initializePresenters [ 

    super initializePresenters.

    applyButton := self newButton.
    applyButton
        label: 'Apply';
        action: [ self applyChanges ].

    descriptorPanel := SpNotebookPresenter new.
    descriptorPanel
        addPage: (SpNotebookPage title: 'Properties' provider: [ 
            SpPresenter new 
                layout: SpBoxLayout newTopToBottom; 
                yourself ]);
        addPage: (SpNotebookPage title: 'Style' provider: [ 
            SpPresenter new 
                layout: SpBoxLayout newTopToBottom; 
                yourself ]).
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> rebuildDescriptorPanel [

	subPresenter ifNil: [ ^ self ].
	descriptor := DdPropertyDescriptor forPresenter: subPresenter.
	descriptor ifNil: [ ^ self ].
	descriptorPanel pages copy do: [ :p | descriptorPanel removePage: p ].

	descriptorPanel
		addPage: (SpNotebookPage
				 title: 'Properties'
				 provider: [ descriptor buildPanelFor: subPresenter ]);
		addPage: (SpNotebookPage
				 title: 'Style'
				 provider: [ descriptor buildStylePanelFor: subPresenter ]).

	self rebuildLayout
]

{ #category : 'private' }
DdPropertyPanelPresenter >> rebuildLayout [ 
    self layout: self defaultLayout.
    self needRebuild: true.
    self updatePresenter
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> target: aPresenter subPresenter: aSubPresenter onClass: aClass canvas: aCanvas [

	targetPresenter := aPresenter.
	subPresenter := aSubPresenter.
	editedClass := aClass.
	canvas := aCanvas.
	self rebuildDescriptorPanel
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> varNameForSubPresenter [ 
    | names |
    targetPresenter ifNil: [ ^ nil ].
    names := targetPresenter class allInstVarNames.
    1 to: targetPresenter class instSize do: [ :i |
        | ivar |
        ivar := targetPresenter instVarAt: i.
        ivar == subPresenter ifTrue: [ ^ names at: i ].
        (ivar respondsTo: #mainPresenter) ifTrue: [
            ivar mainPresenter == subPresenter ifTrue: [ ^ names at: i ] ] ].
    ^ nil
]
