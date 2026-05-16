Class {
	#name : 'DdPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetPresenter',
		'subPresenter',
		'editedClass',
		'canvas',
		'varNameInput',
		'descriptor',
		'applyButton',
		'descriptorPanel'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'layout' }
DdPropertyPanelPresenter >> applyChanges [

	| propsList builder source varName newVarName |
	descriptor ifNil: [ ^ self ].
	varName := self varNameForSubPresenter.
	varName ifNil: [ ^ self ].

	newVarName := varNameInput text trim.
	(newVarName notEmpty and: [ newVarName ~= varName ]) ifTrue: [
			DdRenameVarService new
				renameIn: editedClass
				from: varName
				to: newVarName.
			varName := newVarName.
			canvas designer codeEditor refreshCode].

	propsList := descriptor collectPropertiesWithVarName: varName.
	propsList ifEmpty: [ ^ self ].
	builder := DdInitializeCodeBuilder new
		           presenterClass: editedClass
		           properties: propsList.
	source := builder generate.
	(editedClass compile: source)
		ifNil: [ self inform: 'Compilation error' ]
		ifNotNil: [
				propsList do: [ :props | props applyTo: subPresenter ].
				canvas refreshPreview ]
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> defaultLayout [ 
    | layout |
    layout := SpBoxLayout newTopToBottom spacing: 6.
    layout
        add: (SpBoxLayout newLeftToRight
            spacing: 4;
            add: (SpLabelPresenter new label: 'Var:') width: 30;
            add: varNameInput;
            yourself) expand: false.
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
   varNameInput := SpTextInputFieldPresenter new.
	descriptorPanel := SpNotebookPresenter new.
	descriptorPanel
		addPage: (SpNotebookPage title: 'Properties' provider: [
						 SpPresenter new
							 layout: SpBoxLayout newTopToBottom;
							 yourself ]);
		addPage: (SpNotebookPage title: 'Style' provider: [
					 SpPresenter new
						 layout: SpBoxLayout newTopToBottom;
						 yourself ])
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

	self
		layout: self defaultLayout;
		needRebuild: true;
		updatePresenter
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> target: aPresenter subPresenter: aSubPresenter onClass: aClass canvas: aCanvas [ 
    targetPresenter := aPresenter.
    subPresenter := aSubPresenter.
    editedClass := aClass.
    canvas := aCanvas.
    varNameInput text: (self varNameForSubPresenter ifNil: [ '' ]).
    self rebuildDescriptorPanel
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> varNameForSubPresenter [

	| tmp1 tmp2 tmp3 |
	targetPresenter ifNil: [ ^ nil ] ifNotNil: [ targetPresenter ].
	tmp1 := targetPresenter class allInstVarNames.
	tmp2 := targetPresenter class instSize.
	1 to: tmp2 do: [ :tmp4 |
			tmp3 := nil.
			tmp3 := targetPresenter instVarAt: tmp4.
			tmp3 == subPresenter ifTrue: [ ^ tmp1 at: tmp4 ].
			nil.
			(tmp3 respondsTo: #mainPresenter) ifTrue: [
				tmp3 mainPresenter == subPresenter ifTrue: [ ^ tmp1 at: tmp4 ] ] ].
	1.
	^ nil
]
