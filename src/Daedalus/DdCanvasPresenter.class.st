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
		'selectedContainerPath',
		'scrollPane',
		'lastFormExtent',
		'lastPreviewLayout'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry' }
DdCanvasPresenter class >> defaultFormExtent [
	"The size the form is shown at while its content fits in it."
	^ 480 @ 360
]

{ #category : 'geometry' }
DdCanvasPresenter class >> farthestCornerOf: aMorph [
	"The bottom-right corner of what really needs room inside aMorph.
	- A side that is #spaceFill only follows its owner's size: it does not count, its content does.
	- An empty morph (no width or no height) needs no room: Spec's empty end panel of a box
	  (SpMorphicBoxAdapter>>newVertical) sits one spacing below the last child.
	- Every Spec layout panel clips its submorphs (SpMorphicLayoutAdapter>>newPanelWith:), and what
	  sticks out of it is exactly what gets cut off - so clipping morphs are looked into. Only a
	  TransformMorph (the scrolled contents of lists and text) is not: there it is on purpose."
	| corner |
	corner := (aMorph width > 0 and: [ aMorph height > 0 ])
		ifTrue: [
			(aMorph hResizing = #spaceFill ifTrue: [ aMorph left ] ifFalse: [ aMorph right ])
				@ (aMorph vResizing = #spaceFill ifTrue: [ aMorph top ] ifFalse: [ aMorph bottom ]) ]
		ifFalse: [ SmallInteger minVal @ SmallInteger minVal ].
	(aMorph isKindOf: TransformMorph) ifTrue: [ ^ corner ].
	aMorph submorphsDo: [ :each |
		each visible ifTrue: [ corner := corner max: (self farthestCornerOf: each) ] ].
	^ corner
]

{ #category : 'geometry' }
DdCanvasPresenter class >> maxFormExtent [
	"A guard: a widget that always outgrows whatever room it gets must not grow the form forever."
	^ 3000 @ 3000
]

{ #category : 'instance creation' }
DdCanvasPresenter class >> onPresenter: arg1 [

	| tmp1 |
	tmp1 := self new.
	tmp1
		whenBuiltDo: [ tmp1 applyCanvasColors ];
		editedPresenter: arg1.
	^ tmp1
]

{ #category : 'geometry' }
DdCanvasPresenter class >> overflowOf: aMorph [
	"How far the content of aMorph sticks out of it to the right and below (0 @ 0 when it fits).
	Its own children are always looked at, even when it clips them - that is exactly the content
	that would be cut off."
	| corner |
	corner := aMorph bounds corner.
	aMorph submorphsDo: [ :each |
		each visible ifTrue: [ corner := corner max: (self farthestCornerOf: each) ] ].
	^ (corner - aMorph bounds corner) max: 0 @ 0
]

{ #category : 'appearance' }
DdCanvasPresenter >> applyCanvasColors [

	
]

{ #category : 'selection' }
DdCanvasPresenter >> clearContainerSelection [

	selectedContainerPath := nil
]

{ #category : 'selection' }
DdCanvasPresenter >> containerMorphAt: arg1 [

	| tmp1 |
	(designer isNil or: [ rootPreviewPresenter isNil ]) ifTrue: [ ^ nil ].
	nil.
	tmp1 := designer componentTree rootNode.
	tmp1 ifNil: [ ^ nil ] ifNotNil: [ tmp1 ].
	^ [
		  (DdCanvasMap presenter: rootPreviewPresenter model: tmp1)
			  morphAt: arg1 ]
		  on: Error
		  do: [ ]
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
	selectionOverlay, not in the layout of the preview; it is cut to the visible part of the canvas."
	^ containerOutlineOverlay ifNil: [
		containerOutlineOverlay := DdContainerOutlinesMorph new
			anchorProvider: [ self adapter ifNotNil: [ :anAdapter | anAdapter widget ] ];
			entriesProvider: [ self containerOutlineEntries ];
			clipProvider: [ self visibleCanvasRectangle ];
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

	| tmp1 |
	surfacePresenter ifNotNil: [ ^ self ].
	surfacePresenter := self newMorph.
	surfacePresenter morph: self surfaceScrollPane.
	tmp1 := SpBoxLayout new.
	tmp1 add: surfacePresenter.
	self layout: tmp1 yourself
]

{ #category : 'appearance' }
DdCanvasPresenter >> fittedFormExtent [

	| layout preview needed padding overflow |
	layout := rootPreviewPresenter ifNotNil: [ :aPresenter |
		          aPresenter layout ].
	layout == lastPreviewLayout ifFalse: [
			lastPreviewLayout := layout.
			lastFormExtent := nil ].
	needed := lastFormExtent ifNil: [ self class defaultFormExtent ].
	padding := self surfaceMorph sheetPadding.
	preview := self previewContainerMorph.
	(preview notNil and: [
		 preview world notNil and: [
			 preview extent = (needed - (2 * padding)) ] ]) ifTrue: [
			overflow := [
				            preview fullBounds.
				            self class overflowOf: preview ]
				            on: Error
				            do: [ 0 @ 0 ].
			(overflow x > 2 or: [ overflow y > 2 ]) ifTrue: [
				needed := (needed + overflow + (4 @ 4)) rounded ] ].
	needed := needed min: self class maxFormExtent.
	needed = lastFormExtent ifFalse: [
			lastFormExtent := needed.
			self formExtentChanged ].
	^ needed
]

{ #category : 'appearance' }
DdCanvasPresenter >> formExtent [

	^ formExtent ifNil: [ self fittedFormExtent ] ifNotNil: [ formExtent ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> formExtent: arg1 [

	| tmp1 tmp2 |
	formExtent := arg1.
	tmp2 := tmp1 := surfaceMorph.
	tmp2 ifNotNil: [ tmp1 syncPreview ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> formExtentChanged [
	"The surface's minimum size follows the form: let the scroll pane lay it out again and
	update its scroll bars (on the next UI cycle, once the new size is known)."
	UIManager default defer: [
		[
			surfaceMorph ifNotNil: [ :surface | surface layoutChanged ].
			scrollPane ifNotNil: [ :pane |
				pane fullBounds.
				(pane respondsTo: #updateScrollbars) ifTrue: [ pane updateScrollbars ] ] ]
			on: Error
			do: [ :error | ] ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> heldPresenterAt: aPoint [
	"Among the presenters held in the root preview's instance variables, the one whose morph
	is the smallest containing aPoint, or nil."

	| best bestArea |
	best := nil.
	1 to: rootPreviewPresenter class instSize do: [ :i |
		| held morph bounds |
		held := rootPreviewPresenter instVarAt: i.
		held == rootPreviewPresenter ifFalse: [
			morph := self morphOfHeld: held.
			(morph notNil and: [ morph world notNil ]) ifTrue: [
				bounds := morph boundsInWorld.
				((bounds containsPoint: aPoint) and: [
					 bestArea isNil or: [ bounds area < bestArea ] ]) ifTrue: [
					best := held.
					bestArea := bounds area ] ] ] ].
	^ best
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
DdCanvasPresenter >> morphOfHeld: anObject [
	"The morph shown for an object held in a root variable: the widget of the outermost presenter
	in its chain of mainPresenters (decorator, library component, inner Spec presenter) that has one."

	| current seen |
	(anObject isKindOf: SpPresenter) ifFalse: [ ^ nil ].
	current := anObject.
	seen := IdentitySet new.
	[ current notNil and: [ (seen includes: current) not ] ] whileTrue: [
		seen add: current.
		((current respondsTo: #adapter) and: [ current adapter notNil ])
			ifTrue: [ current adapter widget ifNotNil: [ :morph | ^ morph ] ].
		current := (current respondsTo: #mainPresenter)
			           ifTrue: [ current mainPresenter ]
			           ifFalse: [ nil ] ].
	^ nil
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

	self applyCanvasColors.
	UIManager default defer: [ self applyCanvasColors ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [
	"A fresh preview instance, laid on the grid surface at its own size."

	self withoutStyleReset: [
		| preview |
		preview := editedPresenter class new.
		preview build.
		rootPreviewPresenter := preview.
		self ensureSurfaceLayout.
		self surfaceMorph syncPreview.
		self installClickHooks.
		self reapplyCanvasColors ].
	designer ifNotNil: [ :aDesigner | aDesigner recordHistory ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [

	| tmp1 tmp2 tmp3 tmp4 |
	tmp1 := selectedPresenter ifNotNil: [
		        self instVarNameForPresenterInRoot: selectedPresenter ].
	SpNullApplication skipReset: true.
	[
		rootPreviewPresenter
			initializePresenters;
			layout: rootPreviewPresenter defaultLayout ] ensure: [
		SpNullApplication skipReset: false ].
	tmp1 ifNotNil: [
			tmp2 := rootPreviewPresenter class allInstVarNames indexOf: tmp1.
			tmp2 > 0 ifTrue: [
				selectedPresenter := rootPreviewPresenter instVarAt: tmp2 ] ].
	self surfaceMorph syncPreview.
	self
		installClickHooks;
		reapplyCanvasColors.
	designer ifNotNil: [ designer onSelectionChanged ].
	tmp4 := tmp3 := designer.
	tmp4 ifNotNil: [ tmp3 recordHistory ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'selection' }
DdCanvasPresenter >> selectContainerAt: arg1 [

	selectedContainerPath := arg1
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

	| tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 |
	designer ifNil: [ ^ #(  ) ] ifNotNil: [ designer ].
	tmp1 := designer componentTree rootNode.
	tmp1 ifNil: [ ^ #(  ) ] ifNotNil: [ tmp1 ].
	tmp6 := tmp4 := selectedContainerPath.
	tmp6 ifNotNil: [
			^ [ (tmp1 nodeAtPath: tmp4) resizeHandles ]
				  on: Error
				  do: [ #(  ) ] ].
	selectedPresenter ifNil: [ ^ #(  ) ] ifNotNil: [ selectedPresenter ].
	tmp2 := self instVarNameForPresenterInRoot: selectedPresenter.
	tmp2 ifNil: [ ^ #(  ) ] ifNotNil: [ tmp2 ].
	tmp3 := tmp1 findWidgetNamed: tmp2.
	^ (tmp5 := tmp3) ifNil: [ #(  ) ] ifNotNil: [ tmp5 resizeHandles ]
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
				  tmp1
					  targetProvider: [ self selectionTargetMorph ];
					  handlesProvider: [ self selectedResizeHandles ].
				  selectionOverlay := tmp1 yourself ]
		  ifNotNil: [ selectionOverlay ]
]

{ #category : 'selection' }
DdCanvasPresenter >> selectionTargetMorph [

	| tmp1 tmp2 |
	tmp2 := tmp1 := selectedContainerPath.
	tmp2 ifNotNil: [ ^ self containerMorphAt: tmp1 ].
	^ self selectedWidgetMorph
]

{ #category : 'appearance' }
DdCanvasPresenter >> sheetColor [

	| tmp1 |
	tmp1 := Smalltalk ui theme backgroundColor.
	^ tmp1 luminance > 0.5
		  ifTrue: [ Color gray: 0.88 ]
		  ifFalse: [ tmp1 ]
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
		(self heldPresenterAt: point) ifNotNil: [ :held |
		selectedPresenter := held ].
	designer ifNotNil: [
			designer
				onSelectionChanged;
				onCanvasClicked ].
	(anEvent respondsTo: #wasHandled:) ifTrue: [
		anEvent wasHandled: true ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> surfaceMorph [

	^ surfaceMorph
		  ifNil: [
				  surfaceMorph := DdCanvasSurfaceMorph new.
				  surfaceMorph
					  previewProvider: [ self previewContainerMorph ];
					  extentProvider: [ self formExtent ];
					  hResizing: #spaceFill;
					  vResizing: #spaceFill.
				  surfaceMorph ]
		  ifNotNil: [ surfaceMorph ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> surfaceScrollPane [
	"The surface lies in a scroll pane, built the way SpMorphicScrollableAdapter builds one: the
	surface fills it, but never below its minExtent - a bigger form makes the pane scroll.
	The surface is also given its size straight from fittedFormExtent here, so the form follows
	its content whatever DdCanvasPresenter>>formExtent says."
	^ scrollPane ifNil: [
		self surfaceMorph extentProvider: [ self fittedFormExtent ].
		scrollPane := GeneralScrollPaneMorph new
			changeScrollerTableLayout;
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			color: Color transparent;
			borderColor: Color transparent;
			scrollTarget: self surfaceMorph;
			yourself ]
]

{ #category : 'appearance' }
DdCanvasPresenter >> surroundColor [

	| tmp1 |
	tmp1 := self sheetColor.
	^ tmp1 mixed: 0.8 with: (tmp1 luminance > 0.5
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

{ #category : 'appearance' }
DdCanvasPresenter >> visibleCanvasRectangle [
	"Where the canvas shows the preview right now (world coordinates), or nil."
	^ self previewContainerMorph ifNotNil: [ :morph | DdCanvasMap clipRectangleOf: morph ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> withoutStyleReset: aBlock [
	"Runs aBlock with SpNullApplication's reset switched off: it closes every window, the designer
	included. The switch goes back on only after the current UI cycle, because components finish
	styling themselves in callbacks deferred to that cycle, and those must not reset either."

	SpNullApplication skipReset: true.
	^ aBlock ensure: [
		  UIManager default defer: [ SpNullApplication skipReset: false ] ]
]
