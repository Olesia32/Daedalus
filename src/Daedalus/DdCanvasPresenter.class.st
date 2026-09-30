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
		'selectedPresenter',
		'designer',
		'selectionOverlay',
		'shieldMorph',
		'containerOutlineOverlay',
		'surfaceMorph',
		'surfacePresenter',
		'formExtent',
		'selectedContainerPath'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdCanvasPresenter class >> onPresenter: aPresenter [
"The colors are applied once the canvas has a morph of its own; rebuildPreview/refreshPreview
apply them again whenever the preview morphs are replaced."

	| canvas |
	canvas := self new.
	canvas whenBuiltDo: [ canvas applyCanvasColors ].
	canvas editedPresenter: aPresenter.
	^ canvas
]

{ #category : 'appearance' }
DdCanvasPresenter >> applyCanvasColors [

	
]

{ #category : 'selection' }
DdCanvasPresenter >> clearContainerSelection [

	selectedContainerPath := nil
]

{ #category : 'selection' }
DdCanvasPresenter >> containerMorphAt: aPath [

	| root |
	(designer isNil or: [ rootPreviewPresenter isNil ]) ifTrue: [ ^ nil ].
	root := designer componentTree rootNode.
	root ifNil: [ ^ nil ].
	^ [
		  (DdCanvasMap presenter: rootPreviewPresenter model: root)
			  morphAt: aPath ]
		  on: Error
		  do: [ nil ]
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

{ #category : 'appearance' }
DdCanvasPresenter >> ensureSurfaceLayout [
"The canvas's own layout is built once: a single morph presenter holding the surface. Rebuilding
the preview after that only swaps the morph lying on the surface."

	surfacePresenter ifNotNil: [ ^ self ].
	surfacePresenter := self newMorph.
	surfacePresenter morph: self surfaceMorph.
	self layout: (SpBoxLayout new
			 add: surfacePresenter;
			 yourself)
]

{ #category : 'appearance' }
DdCanvasPresenter >> formExtent [
"The size the form is shown at. A fixed default for now; a resize handle on the form can set it."

	^ formExtent ifNil: [ 480 @ 360 ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> formExtent: aPoint [

	formExtent := aPoint.
	surfaceMorph ifNotNil: [ :surface | surface syncPreview ]
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

{ #category : 'selection' }
DdCanvasPresenter >> previewContainerMorph [
"The top morph of the current preview - the shield mirrors its bounds and sits right in front
of it, so nothing underneath (its widgets) ever sees a mouseDown."

	^ rootPreviewPresenter
		  ifNil: [ nil ]
		  ifNotNil: [ :p |
		  p adapter ifNil: [ nil ] ifNotNil: [ :a | a widget ] ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> reapplyCanvasColors [
"Now and once more on the next UI cycle, in case Spec builds the new morphs a little later."

	self applyCanvasColors.
	UIManager default defer: [ self applyCanvasColors ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [
"A fresh preview instance, laid on the grid surface at its own size."

	| preview |
	preview := editedPresenter class new.
	preview build.
	rootPreviewPresenter := preview.
	self ensureSurfaceLayout.
	self surfaceMorph syncPreview.
	self installClickHooks.
	self reapplyCanvasColors.
	designer ifNotNil: [ :aDesigner | aDesigner recordHistory ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [
"Re-runs initializePresenters and defaultLayout on the existing root preview instance, restores
the selection by variable name, puts the (possibly new) preview morph back on the surface and
reinstalls click hooks."

	| subVarName |
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
	self surfaceMorph syncPreview.
	self installClickHooks.
	self reapplyCanvasColors.
	designer ifNotNil: [ designer onSelectionChanged ].
	designer ifNotNil: [ :aDesigner | aDesigner recordHistory ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'selection' }
DdCanvasPresenter >> selectContainerAt: aPath [
"A container is selected instead of a widget: the frame and the resize handles follow it."

	selectedContainerPath := aPath
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

{ #category : 'selection' }
DdCanvasPresenter >> selectedContainerPath [

	^ selectedContainerPath
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [

	^ selectedPresenter
]

{ #category : 'selection' }
DdCanvasPresenter >> selectedResizeHandles [
	"The resize handles of the selection (a container or a widget), from its node in the tree's model."

	| root varName node |
	designer ifNil: [ ^ #(  ) ].
	root := designer componentTree rootNode.
	root ifNil: [ ^ #(  ) ].
	selectedContainerPath ifNotNil: [ :path |
			^ [ (root nodeAtPath: path) resizeHandles ]
				  on: Error
				  do: [ #(  ) ] ].
	selectedPresenter ifNil: [ ^ #(  ) ].
	varName := self instVarNameForPresenterInRoot: selectedPresenter.
	varName ifNil: [ ^ #(  ) ].
	node := root findWidgetNamed: varName.
	^ node ifNil: [ #(  ) ] ifNotNil: [ :aNode | aNode resizeHandles ]
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

	^ selectionOverlay ifNil: [
			  selectionOverlay := DdSelectionGlassMorph new
				                      targetProvider: [ self selectionTargetMorph ];
				                      handlesProvider: [
					                      self selectedResizeHandles ];
				                      yourself ]
]

{ #category : 'selection' }
DdCanvasPresenter >> selectionTargetMorph [
"What the selection frame goes around: the selected container, or else the selected widget."

	selectedContainerPath ifNotNil: [ :path |
		^ self containerMorphAt: path ].
	^ self selectedWidgetMorph
]

{ #category : 'appearance' }
DdCanvasPresenter >> sheetColor [
"The form's own background: light grey like a window pane on a light theme, so white fields and
lists stand out on it."

	| base |
	base := Smalltalk ui theme backgroundColor.
	^ base luminance > 0.5
		  ifTrue: [ Color gray: 0.88 ]
		  ifFalse: [ base ]
]

{ #category : 'selection' }
DdCanvasPresenter >> shieldMouseDown: anEvent [

	| point candidates best area bestArea |
	rootPreviewPresenter ifNil: [ ^ self ].
	(designer notNil and: [ designer isResizing ]) ifTrue: [ ^ self ].
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

{ #category : 'appearance' }
DdCanvasPresenter >> surfaceMorph [

	^ surfaceMorph ifNil: [
			  surfaceMorph := DdCanvasSurfaceMorph new.
			  surfaceMorph
				  previewProvider: [ self previewContainerMorph ];
				  extentProvider: [ self formExtent ];
				  hResizing: #spaceFill;
				  vResizing: #spaceFill.
			  surfaceMorph ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> surroundColor [
"The work surface around the form: the sheet color pushed towards black on a light theme and
towards white on a dark one, so the edge of the form is always visible."

	| base |
	base := self sheetColor.
	^ base mixed: 0.8 with: (base luminance > 0.5
			   ifTrue: [ Color black ]
			   ifFalse: [ Color white ])
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

{ #category : 'selection' }
DdCanvasPresenter >> updateSelectionOverlay [
"Makes sure the selection frame is on screen; it then follows the selection by itself."

	| world |
	world := self adapter ifNotNil: [ :anAdapter |
		         anAdapter widget ifNotNil: [ :morph | morph world ] ].
	self selectionOverlay showIn: world.
	self updateContainerOutlineOverlay
]
