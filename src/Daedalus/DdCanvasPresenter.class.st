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
		'designer',
		'selectionOverlay'
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
DdCanvasPresenter >> clearOverlay [
    selectionOverlay ifNotNil: [ 
        selectionOverlay delete.
        selectionOverlay := nil ].
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
				         designer ifNotNil: [
						         designer
							         onSelectionChanged;
							         onCanvasClicked ].
				         (anEvent respondsTo: #wasHandled:) ifTrue: [
					         anEvent wasHandled: true ].
				         ^ self ].
	result := model owner == rootPreviewPresenter
		          ifTrue: [ model ]
		          ifFalse: [ model owner ].
	result ifNil: [ ^ self ].
	selectedPresenter := result.
	(selectedPresenter owner isKindOf: RadioGroupPresenter) ifTrue: [
		selectedPresenter := selectedPresenter owner ].
	(selectedPresenter owner isKindOf: CheckboxGroupPresenter) ifTrue: [
		selectedPresenter := selectedPresenter owner ].
	designer ifNotNil: [
			designer
				onSelectionChanged;
				onCanvasClicked ].
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
		rootPreviewPresenter layout: rootPreviewPresenter defaultLayout ]
		ensure: [ SpNullApplication skipReset: false ].

	subVarName ifNotNil: [
			| idx |
			idx := rootPreviewPresenter class allInstVarNames indexOf:
				       subVarName.
			idx > 0 ifTrue: [
				selectedPresenter := rootPreviewPresenter instVarAt: idx ] ].

	self installClickHooks.
	designer ifNotNil: [ designer onSelectionChanged ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'selection' }
DdCanvasPresenter >> selectWidgetNamed: aVarName [
	"Makes the widget held in the root preview's variable aVarName the canvas selection
	(the same state a click on it produces). Answers false when there is no such variable or it is empty."

	| index widget |
	index := (rootPreviewPresenter class allInstVarNames collect: [ :each |
		          each asString ]) indexOf: aVarName asString.
	index = 0 ifTrue: [ ^ false ].
	widget := rootPreviewPresenter instVarAt: index.
	widget ifNil: [ ^ false ].
	selectedPresenter := widget.
	^ true
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [

	^ selectedPresenter
]

{ #category : 'selection' }
DdCanvasPresenter >> selectedWidgetMorph [
	"The morph of the widget selected on the canvas, or nil."

	^ selectedPresenter ifNotNil: [ :each |
		  each adapter ifNotNil: [ :anAdapter | anAdapter widget ] ]
]

{ #category : 'selection' }
DdCanvasPresenter >> selectionOverlay [
	"The glass that frames the selected widget. It lives in the Morphic world, like halos, not in the
	layout of the preview: an extra morph inside a Spec layout breaks its calculators."

	^ selectionOverlay ifNil: [
			  selectionOverlay := DdSelectionGlassMorph new
				                      targetProvider: [ self selectedWidgetMorph ];
				                      yourself ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> showOverlayFor: aMorph [
    | world morphBounds |
    selectionOverlay ifNotNil: [ selectionOverlay delete ].
    world := self adapter ifNotNil: [ :a | a widget world ] ifNil: [ nil ].
    world ifNil: [ ^ self ].
    morphBounds := aMorph bounds.
    selectionOverlay := DdSelectionOverlayMorph new
        initializeFor: aMorph.
    selectionOverlay bounds: morphBounds.
    world addMorph: selectionOverlay.
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> updateOverlay [
    selectionOverlay ifNotNil: [ selectionOverlay update ]
]

{ #category : 'selection' }
DdCanvasPresenter >> updateSelectionOverlay [
"Makes sure the selection frame is on screen; it then follows the selection by itself."

	| world |
	world := self adapter ifNotNil: [ :anAdapter |
		         anAdapter widget ifNotNil: [ :morph | morph world ] ].
	self selectionOverlay showIn: world
]
