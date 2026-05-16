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
		'selectedSubPresenter'
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
DdCanvasPresenter >> clickedMorphFromEvent: arg1 [

	| tmp1 |
	tmp1 := arg1 position.
	^ self deepestMorphAt: tmp1
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [
"Resolves the clicked morph to a selected presenter and sub-presenter pair, updates the selection state, and notifies
the designer."

	| clickedMorph result |
	clickedMorph := self clickedMorphFromEvent: anEvent.
	clickedMorph ifNil: [ ^ self ].

	result := self presenterFromClickedMorph: clickedMorph.
	result ifNil: [ ^ self ].
	selectedPresenter := result key.
	selectedSubPresenter := result value.
	designer ifNotNil: [ designer onSelectionChanged ].
	(anEvent respondsTo: #wasHandled:) ifTrue: [
		anEvent wasHandled: true ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> deepestMorphAt: arg1 [

	| tmp1 |
	tmp1 := rootPreviewPresenter adapter widget.
	tmp1 ifNil: [ ^ nil ].
	tmp1.
	^ self deepestMorphIn: tmp1 at: arg1
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> deepestMorphIn: arg1 at: arg2 [
"Recursively finds the deepest morph at aPoint within arg1's submorph tree."

	(arg1 bounds containsPoint: arg2) ifFalse: [ ^ nil ].
	arg1 submorphs reverseDo: [ :arg3 |
			| tmp1 |
			tmp1 := self deepestMorphIn: arg3 at: arg2.
			tmp1 ifNotNil: [ ^ tmp1 ] ].
	^ arg1
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

	presenterIndex presenters do: [ :p |
		(p adapter notNil and: [ p adapter widget notNil ]) ifTrue: [
			| w |
			w := p adapter widget.
			(w respondsTo: #on:send:to:) ifTrue: [
				w on: #mouseDown send: #ddOnMouseDown: to: self ] ] ].
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterFromClickedMorph: aMorph [
"Walks up the morph ownership chain from aMorph to find the nearest user-defined presenter that owns the clicked widget,
returning an Association of presenter→subPresenter."

    | m compositeClasses |
    compositeClasses := {
                            ComboBoxPresenter.
                            TimePickerPresenter }.
    m := aMorph.
    [ m notNil ] whileTrue: [
        presenterIndex presenters do: [ :p |
            (p adapter notNil and: [ p adapter widget == m ]) ifTrue: [
                | current |
                current := p owner.
                [ current notNil 
    and: [ (current isKindOf: SpPresenter) 
    and: [ current ~~ rootPreviewPresenter ] ] 
] whileTrue: [
                    | varName |
                    varName := self instVarNameForPresenterInRoot: current.
                    varName ifNotNil: [
                        (compositeClasses anySatisfy: [ :cls | current isKindOf: cls ])
                            ifTrue: [ ^ Association key: current value: current ]
                            ifFalse: [ ^ Association key: current value: p ] ].
                    current := current owner ].

                (self instVarNameForPresenterInRoot: p) ifNotNil: [
                    ^ Association key: p value: p ] ] ].
        m := m owner ].
    ^ nil
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
	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.
	self layout: (SpBoxLayout new
			 spacing: 30;
			 add: rootPreviewPresenter;
			 yourself).
	self needRebuild: true.

	self updatePresenter.
	UIManager default defer: [
		UIManager default defer: [  
			presenterIndex := DdPresenterIndex new
				buildFromRootPresenter: rootPreviewPresenter.
			self installClickHooks ] ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [
"Re-runs initializePresenters and defaultLayout on the existing root preview instance, rebuilds the index, restores the previously
selected presenters by variable name, and reinstalls click hooks."

	| subVarName presenterVarName |
	subVarName := selectedSubPresenter ifNotNil: [
		              self instVarNameForPresenterInRoot:
			              selectedSubPresenter ].
	presenterVarName := selectedPresenter ifNotNil: [
		                    self instVarNameForPresenterInRoot:
			                    selectedPresenter ].

	SpNullApplication skipReset: true.
	[
		rootPreviewPresenter initializePresenters.
		rootPreviewPresenter layout: rootPreviewPresenter defaultLayout ]
		ensure: [ SpNullApplication skipReset: false ].

	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.

	presenterVarName ifNotNil: [
			| idx |
			idx := rootPreviewPresenter class allInstVarNames indexOf:
				       presenterVarName.
			idx > 0 ifTrue: [
				selectedPresenter := rootPreviewPresenter instVarAt: idx ] ].

	subVarName ifNotNil: [
			| idx |
			idx := rootPreviewPresenter class allInstVarNames indexOf:
				       subVarName.
			idx > 0 ifTrue: [
				selectedSubPresenter := rootPreviewPresenter instVarAt: idx ] ].

	UIManager default defer: [
			self installClickHooks. ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [

	^ selectedPresenter
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedSubPresenter [

	^ selectedSubPresenter
]
