"
I am the property panel shown on the right side of the designer. When the user selects a widget on the canvas I display its editable
properties across two notebook tabs — Properties and Style — and provide an Apply button that compiles the changes back into the
edited presenter class.

### Hierarchy
`SpPresenter`
`DdPropertyPanelPresenter` (this is me)

### Instance Variables
- _targetPresenter_: `SpPresenter` — the top-level owner presenter
- _subPresenter_: `SpPresenter` — the directly selected widget presenter
- _editedClass_: `Class` — the presenter class being compiled into
- _canvas_: `DdCanvasPresenter` — used to trigger preview refresh
- _varNameInput_: `SpTextInputFieldPresenter` — displays and edits the variable name
- _descriptor_: `DdPropertyDescriptor` — the active property descriptor for the selection
- _applyButton_: `SpButtonPresenter` — triggers applyChanges
- _descriptorPanel_: `SpNotebookPresenter` — hosts Properties and Style tabs
"
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
"Renames the variable if the name input changed, collects all edited properties via the descriptor, generates patched source
via DdInitializeCodeBuilder, compiles it, applies properties to the live presenter, and triggers a canvas refresh for complex components."
	| propsList builder source varName newVarName needsRefresh |
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
			canvas designer codeEditor refreshCode ].
	propsList := descriptor collectPropertiesWithVarName: varName.
	propsList ifEmpty: [ ^ self ].
	builder := DdInitializeCodeBuilder new
		           presenterClass: editedClass
		           properties: propsList.
	source := builder generate.
	needsRefresh := (descriptor isKindOf: DdGroupPropertyDescriptor)
		or: [ descriptor isKindOf: DdComboboxPropertyDescriptor ].
	(editedClass compile: source)
		ifNil: [ self inform: 'Compilation error' ]
		ifNotNil: [
				propsList do: [ :props | props applyTo: subPresenter ].
				needsRefresh ifTrue: [ canvas refreshPreview ] ]
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> currentVarName [
    ^ varNameInput text trim
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

{ #category : 'testing' }
DdPropertyPanelPresenter >> hasSameTargetAs: aSubPresenter [
    ^ subPresenter class == aSubPresenter class
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
]

{ #category : 'testing' }
DdPropertyPanelPresenter >> rebuildDescriptorPanel [
"Resolves the descriptor for subPresenter, rebuilds the notebook tabs with fresh Properties and Style panels, and updates the layout."

    subPresenter ifNil: [ ^ self ].
    descriptor := DdPropertyDescriptor forPresenter: subPresenter.
    descriptor ifNil: [ ^ self ].

    descriptorPanel := SpNotebookPresenter new.

    descriptorPanel
        addPage: (SpNotebookPage
            title: 'Properties'
            provider: [
                | inner |
                inner := descriptor buildPanelFor: subPresenter.
                SpPresenter new
                    layout: (SpScrollableLayout new child: inner layout; yourself);
                    yourself ]);
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

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> syncTarget: aPresenter subPresenter: aSubPresenter [
    targetPresenter := aPresenter.
    subPresenter := aSubPresenter.
    varNameInput text: (self varNameForSubPresenter ifNil: [ '' ])
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> target: aPresenter subPresenter: aSubPresenter onClass: aClass canvas: aCanvas [
"Sets the target, sub-presenter, class and canvas, pre-populates the variable name input, and rebuilds the descriptor panel."
 
    targetPresenter := aPresenter.
    subPresenter := aSubPresenter.
    editedClass := aClass.
    canvas := aCanvas.
    varNameInput text: (self varNameForSubPresenter ifNil: [ '' ]).
    self rebuildDescriptorPanel
]

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> varNameForSubPresenter [
"Walks targetPresenter's inst vars to find the index at which subPresenter is stored, returning the corresponding variable name
or nil if not found."

    | searchIn |
    targetPresenter ifNil: [ ^ nil ].
    searchIn := (targetPresenter == subPresenter)
        ifTrue: [ targetPresenter owner ]
        ifFalse: [ targetPresenter ].
    
    searchIn ifNil: [ ^ nil ].
    
    1 to: searchIn class instSize do: [ :i |
        | val |
        val := searchIn instVarAt: i.
        val == subPresenter ifTrue: [ ^ searchIn class allInstVarNames at: i ].
        (val respondsTo: #mainPresenter) ifTrue: [
            val mainPresenter == subPresenter ifTrue: [ 
                ^ searchIn class allInstVarNames at: i ] ] ].
    
    ^ nil
]
