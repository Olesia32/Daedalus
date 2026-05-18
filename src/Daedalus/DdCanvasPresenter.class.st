"
I am the central canvas of the designer. I host a live preview of the edited presenter, maintain a click-based selection mechanism,
and expose the currently selected presenter and sub-presenter to the rest of the designer.

### Hierarchy
`SpPresenter`
`DdCanvasPresenter` (this is me)

### Instance Variables
- _editedPresenter_: `Class` — the presenter class being designed
- _rootPreviewPresenter_: `SpPresenter` — the live preview instance
- _presenterIndex_: `DdPresenterIndex` — maps widgets to presenters
- _selectedPresenter_: `SpPresenter` — the top-level selected presenter
- _selectedSubPresenter_: `SpPresenter` — the directly clicked sub-presenter
- _designer_: `DdDesignerPresenter` — the parent designer, notified on selection changes
"
Class {
	#name : 'DdCanvasPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'editedPresenter',
		'previewPresenter',
		'rootPreviewPresenter',
		'presenterIndex',
		'selectedPresenter',
		'designer'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdCanvasPresenter class >> onPresenter: aPresenter [
    "Creates and opens a new canvas for aPresenter, returning the configured instance."
^ self new
        editedPresenter: aPresenter;
        yourself.
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [

	| model result handler |
	handler := anEvent handler.
	model := [ handler model model ]
		         on: Error
		         do: [
				         result := self presenterFromMorphWithoutModel: handler.
				         result ifNil: [ ^ self ].
				         selectedPresenter := result owner ifNil: [ result ].
				         designer ifNotNil: [ designer onSelectionChanged ].
				         (anEvent respondsTo: #wasHandled:) ifTrue: [
					         anEvent wasHandled: true ].
				         ^ self ].
	result := model owner.
	result ifNil: [ ^ self ].
	selectedPresenter := result.
	(selectedPresenter owner isKindOf: RadioGroupPresenter) ifTrue: [
		selectedPresenter := selectedPresenter owner ].
	(selectedPresenter owner isKindOf: CheckboxGroupPresenter) ifTrue: [
		selectedPresenter := selectedPresenter owner ].
	designer ifNotNil: [ designer onSelectionChanged ].
	(anEvent respondsTo: #wasHandled:) ifTrue: [
		anEvent wasHandled: true ]
]

{ #category : 'layout' }
DdCanvasPresenter >> defaultLayout [

	^ SpBoxLayout new
		  spacing: 30;
		  add: previewPresenter;
		  yourself
]

{ #category : 'accessing' }
DdCanvasPresenter >> designer [
  ^designer 
]

{ #category : 'accessing' }
DdCanvasPresenter >> designer: arg1 [

	designer := arg1
]

{ #category : 'accessing' }
DdCanvasPresenter >> editedPresenter: aPresenter [

	editedPresenter := aPresenter.
	self rebuildPreview
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> instVarNameForPresenterInRoot: aPresenter [
"Returns the instance variable name under which aPresenter is stored in rootPreviewPresenter, or nil if not found."

    | names |
    names := rootPreviewPresenter class allInstVarNames.
    1 to: rootPreviewPresenter class instSize do: [ :i |
        ((rootPreviewPresenter instVarAt: i) == aPresenter)
            ifTrue: [ ^ names at: i ] ].
    ^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> installClickHooks [
	"Attaches a mouseDown handler on every indexed presenter widget so that clicks on the preview are routed to ddOnMouseDown:."

	| root |
	root := rootPreviewPresenter adapter widget.
	root ifNil: [ ^ self ].

	"Знімаємо старі обробники"
	root allMorphsDo: [ :m |
			(m respondsTo: #removeActionsForEvent:) ifTrue: [
				m removeActionsForEvent: #mouseDown ] ].
	
	rootPreviewPresenter allPresenters do: [ :p |
			(p adapter notNil and: [ p adapter widget notNil ]) ifTrue: [
					| w |
					w := p adapter widget.
					(w respondsTo: #on:send:to:) ifTrue: [
						w on: #mouseDown send: #ddOnMouseDown: to: self ] ] ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> presenterFromMorphWithoutModel: aMorph [
"Walks up the morph ownership chain from aMorph, searching allPresenters 
for a presenter whose adapter widget matches. Returns the found presenter or nil."
    | m result |
    m := aMorph.
    result := nil.
    [ m notNil and: [ result isNil ] ] whileTrue: [
        rootPreviewPresenter allPresenters do: [ :p |
            (p adapter notNil and: [ p adapter widget == m ]) ifTrue: [
                result := p ] ].
        m := m owner ].
    ^ result
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterIndex [

	^ presenterIndex
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [
"Instantiates a fresh preview from editedPresenter, rebuilds the presenter index, updates the layout, and schedules click hook
installation after two UI cycles."

	 | newPresenter |
    newPresenter := editedPresenter class new.
    newPresenter build.
    rootPreviewPresenter := newPresenter.

    self layout: (SpBoxLayout new
        spacing: 30;
        add: rootPreviewPresenter;
        yourself).
    self installClickHooks 
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [
"Re-runs initializePresenters and defaultLayout on the existing root preview instance, rebuilds the index, restores the previously
selected presenters by variable name, and reinstalls click hooks."

	| subVarName presenterVarName |
    subVarName := selectedPresenter ifNotNil: [
        self instVarNameForPresenterInRoot: selectedPresenter ].

    SpNullApplication skipReset: true.
    [
        rootPreviewPresenter initializePresenters.
        rootPreviewPresenter layout: rootPreviewPresenter defaultLayout.
    ] ensure: [ SpNullApplication skipReset: false ].

    subVarName ifNotNil: [
        | idx |
        idx := rootPreviewPresenter class allInstVarNames indexOf: subVarName.
        idx > 0 ifTrue: [
            selectedPresenter := rootPreviewPresenter instVarAt: idx ] ].

        self installClickHooks.
        designer ifNotNil: [ designer onSelectionChanged ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [

	^ selectedPresenter
]
