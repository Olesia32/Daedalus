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
		'selectionOverlay',
		'shieldMorph',
		'containerOutlineOverlay'
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

{ #category : 'selection' }
DdCanvasPresenter >> containerOutlineEntries [

	| livePresenter root map entries |
	livePresenter := self rootPreviewPresenter.
	livePresenter ifNil: [ ^ #(  ) ].
	root := [ (DdLayoutEditor forClass: livePresenter class) root ]
		        on: Error
		        do: [ nil ].
	root ifNil: [ ^ #(  ) ].
	map := [ DdCanvasMap presenter: livePresenter model: root ]
		       on: Error
		       do: [ nil ].
	map ifNil: [ ^ #(  ) ].
	entries := OrderedCollection new.
	root allNodesDo: [ :node |
			node isContainerNode ifTrue: [
					(map boundsAt: node path) ifNotNil: [ :rect |
						entries add: rect -> node kindLabel ] ] ].
	^ entries
]

{ #category : 'selection' }
DdCanvasPresenter >> containerOutlineOverlay [
"The overlay that outlines every live container on the canvas. Lives in the Morphic world, like
selectionOverlay, not in the layout of the preview."

	^ containerOutlineOverlay ifNil: [
			  containerOutlineOverlay := DdContainerOutlinesMorph new
				                             anchorProvider: [
					                             self adapter ifNotNil: [ :anAdapter |
							                             anAdapter widget ] ];
				                             entriesProvider: [
					                             self containerOutlineEntries ];
				                             yourself ]
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

{ #category : 'selection' }
DdCanvasPresenter >> ensureShieldInstalled [
"Added to the World right away so stepping engages; from then on the shield's own step method
hides it until a live preview actually exists, and keeps it positioned over that preview only."

	shieldMorph ifNotNil: [ ^ self ].
	shieldMorph := DdInputShieldMorph new
		               canvas: self;
		               yourself.
	World ifNotNil: [ :w | w addMorphFront: shieldMorph ]
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
DdCanvasPresenter >> installInteractionOverlay [
	"Spike/slice-12 wiring: builds a fresh DdCanvasMap and drops a single DdInteractionOverlayMorph
on top of the preview window, replacing per-widget mouseDown hooks for selection/drag purposes.
onSelect:/onDrop: are left as simple logging for now; slice 13 wires onDrop: to
DdLayoutEditor moveAt:toBoxAt:index: plus a single compile:.
Call again after refreshPreview/rebuildPreview: the overlay is tied to the current top morph."

	| top map overlay world |
	top := rootPreviewPresenter adapter
		       ifNil: [ ^ self ]
		       ifNotNil: [ :a | a widget ].
	top ifNil: [ ^ self ].
	world := top world.
	world ifNil: [ ^ self ].
	map := DdCanvasMap
		       presenter: rootPreviewPresenter
		       model: designer componentTree rootNode.
	overlay := DdInteractionOverlayMorph canvasMap: map top: top.
	overlay
		onSelect: [ :path |
				Transcript
					show: 'selected ';
					show: path printString ];
		onDrop: [ :from :target |
				Transcript
					show: from printString , ' -> ';
					show: target printString ].
	world addMorphFront: overlay.
	overlay syncBounds
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

{ #category : 'selection' }
DdCanvasPresenter >> previewContainerMorph [
"The top morph of the current preview - the shield mirrors its bounds and sits right in front
of it, so nothing underneath (its widgets) ever sees a mouseDown."

	^ rootPreviewPresenter
		  ifNil: [ nil ]
		  ifNotNil: [ :p |
		  p adapter ifNil: [ nil ] ifNotNil: [ :a | a widget ] ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [

	| tmp1 tmp2 |
	tmp1 := editedPresenter class new.
	tmp1 build.
	rootPreviewPresenter := tmp1.
	tmp2 := SpBoxLayout new.
	tmp2
		spacing: 30;
		add: rootPreviewPresenter.
	self
		layout: tmp2 yourself;
		installClickHooks
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

	| tmp1 tmp2 tmp3 tmp4 |
	tmp3 := tmp1 := selectedPresenter.
	^ tmp3 ifNotNil: [
			  tmp4 := tmp2 := tmp1 adapter.
			  tmp4 ifNotNil: [ tmp2 widget ] ]
]

{ #category : 'selection' }
DdCanvasPresenter >> selectionOverlay [

	| tmp1 |
	^ selectionOverlay
		  ifNil: [
				  tmp1 := DdSelectionGlassMorph new.
				  tmp1 targetProvider: [ self selectedWidgetMorph ].
				  selectionOverlay := tmp1 yourself ]
		  ifNotNil: [ selectionOverlay ]
]

{ #category : 'selection' }
DdCanvasPresenter >> shieldMouseDown: anEvent [

	| point candidates best area bestArea |
	rootPreviewPresenter ifNil: [ ^ self ].
	point := anEvent position.
	candidates := rootPreviewPresenter allPresenters select: [ :p |
			              p adapter notNil and: [
					              p adapter widget notNil and: [
						              p adapter widget boundsInWorld containsPoint:
							              point ] ] ].
	candidates isEmpty ifTrue: [ ^ self ].
	best := candidates first.
	bestArea := best adapter widget boundsInWorld width
	            * best adapter widget boundsInWorld height.
	candidates do: [ :each |
			area := each adapter widget boundsInWorld width
			        * each adapter widget boundsInWorld height.
			area < bestArea ifTrue: [
					best := each.
					bestArea := area ] ].
	selectedPresenter := best.
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

{ #category : 'selection' }
DdCanvasPresenter >> updateContainerOutlineOverlay [
"Makes sure the container-outline overlay is on screen; it then follows the live preview by
itself, the same way updateSelectionOverlay does for the selection frame."

	| world |
	world := self adapter ifNotNil: [ :anAdapter |
		         anAdapter widget ifNotNil: [ :morph | morph world ] ].
	self containerOutlineOverlay showIn: world
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
	self selectionOverlay showIn: world.
	self updateContainerOutlineOverlay
]
