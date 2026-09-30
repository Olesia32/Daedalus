"
I am the main designer window. I coordinate the widget palette, the canvas, the property panel, and the code editor. I react to
selection changes on the canvas and route widget-add requests from the palette to the appropriate service.

### Hierarchy
`SpPresenter`
`DdDesignerPresenter` (this is me)

### Instance Variables
- _presenter_: `Class` — the presenter class being designed
- _widgetPalette_: `DdWidgetPalettePresenter`
- _workArea_: `DdCanvasPresenter`
- _propertyPanel_: `DdPropertyPanelPresenter`
- _codeEditor_: `DdLayoutCodeEditorPresenter`
"
Class {
	#name : 'DdDesignerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'presenter',
		'widgetPalette',
		'workArea',
		'propertyPanel',
		'codeEditor',
		'footerBar',
		'componentTree',
		'syncingSelection',
		'dragController',
		'history',
		'undoButton',
		'redoButton',
		'leftTabs',
		'layoutPanel',
		'showingLayout'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdDesignerPresenter class >> onPresenter: aPresenterClass [
    
   ^ self new
     presenterClass: aPresenterClass;
     yourself 
]

{ #category : 'dragging' }
DdDesignerPresenter >> addPaletteWidget: aDescriptor into: aContainerPath at: anIndex [
	"Adds a new widget of aDescriptor at that place of the layout."

	| varName editor |
	"a dry run first: a refusal must not leave a new variable behind"
	[
		(DdLayoutEditor forClass: presenter)
			insertWidget: 'dryRunWidget'
			into: aContainerPath
			at: anIndex ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	varName := DdAddWidgetService new
		           presenterClass: presenter;
		           addVariableFor: aDescriptor.
	[
		editor := DdLayoutEditor forClass: presenter.
		editor insertWidget: varName into: aContainerPath at: anIndex.
		editor applyTo: presenter ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	codeEditor refreshCode.
	componentTree showModelFrom: editor.
	workArea rebuildPreview.
	componentTree selectNodeAtPath: aContainerPath , { anIndex }
]

{ #category : 'dragging' }
DdDesignerPresenter >> addPaletteWidget: aDescriptor intoAbsolute: anAbsolutePath at: aPoint [
"Adds a new widget of aDescriptor at point aPoint inside the absolute layout at anAbsolutePath."

	| varName editor newIndex |
	"a dry run first: a refusal must not leave a new variable behind"
	[
		(DdLayoutEditor forClass: presenter)
			insertAbsoluteWidget: 'dryRunWidget'
			into: anAbsolutePath
			atPoint: aPoint
			extent: nil ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	varName := DdAddWidgetService new
		           presenterClass: presenter;
		           addVariableFor: aDescriptor.
	[
		editor := DdLayoutEditor forClass: presenter.
		editor
			insertAbsoluteWidget: varName
			into: anAbsolutePath
			atPoint: aPoint
			extent: nil.
		editor applyTo: presenter ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	newIndex := (editor nodeAt: anAbsolutePath) children size.
	codeEditor refreshCode.
	componentTree showModelFrom: editor.
	"a widget the preview instance has never had needs the full rebuild, as in addPaletteWidget:into:at:"
	workArea rebuildPreview.
	componentTree selectNodeAtPath: anAbsolutePath , { newIndex }
]

{ #category : 'dragging' }
DdDesignerPresenter >> addPaletteWidget: aDescriptor intoGrid: aGridPath cell: aCell [
"Adds a new widget of aDescriptor to cell aCell of the grid at aGridPath."

	| varName editor newIndex |
	"a dry run first: a refusal must not leave a new variable behind"
	[
		(DdLayoutEditor forClass: presenter)
			insertGridWidget: 'dryRunWidget'
			into: aGridPath
			atPosition: aCell
			span: nil ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	varName := DdAddWidgetService new
		           presenterClass: presenter;
		           addVariableFor: aDescriptor.
	[
		editor := DdLayoutEditor forClass: presenter.
		editor
			insertGridWidget: varName
			into: aGridPath
			atPosition: aCell
			span: nil.
		editor applyTo: presenter ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	newIndex := (editor nodeAt: aGridPath) children size.
	codeEditor refreshCode.
	componentTree showModelFrom: editor.
	"a widget the preview instance has never had needs the full rebuild, as in addPaletteWidget:into:at:"
	workArea rebuildPreview.
	componentTree selectNodeAtPath: aGridPath , { newIndex }
]

{ #category : 'adding' }
DdDesignerPresenter >> addWidget: aDescriptor [
	"Delegates to DdAddWidgetService, then refreshes the code editor, the component tree and the canvas preview."

	DdAddWidgetService new
		presenterClass: presenter;
		addWidget: aDescriptor.
	codeEditor refreshCode.
	componentTree refresh.
	workArea refreshPreview
]

{ #category : 'history' }
DdDesignerPresenter >> afterHistoryChange [
"The class now has other methods: everything shown from it is rebuilt. rebuildPreview (not
refreshPreview) because initializePresenters may have changed too."

	codeEditor refreshCode.
	componentTree refresh.
	workArea rebuildPreview.
	self updateHistoryButtons
]

{ #category : 'resizing' }
DdDesignerPresenter >> applyResizeAt: aPath with: aOneArgBlock [
"Runs aOneArgBlock on a fresh editor of the edited class, compiles, and refreshes everything
shown from it - the common tail of every kind of resize."

	| editor |
	[
		editor := DdLayoutEditor forClass: presenter.
		aOneArgBlock value: editor.
		editor applyTo: presenter ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	codeEditor refreshCode.
	componentTree showModelFrom: editor.
	workArea refreshPreview.
	componentTree selectNodeAtPath: aPath
]

{ #category : 'dragging' }
DdDesignerPresenter >> canvasMap [
	"The map of the current preview, or nil when it cannot be trusted (it would mislead a drop)."

	| root map |
	root := componentTree rootNode.
	root ifNil: [ ^ nil ].
	map := DdCanvasMap
		       presenter: workArea rootPreviewPresenter
		       model: root.
	^ map isComplete ifTrue: [ map ]
]

{ #category : 'accessing' }
DdDesignerPresenter >> codeEditor [ 
^ codeEditor 
]

{ #category : 'accessing' }
DdDesignerPresenter >> componentTree [

	^ componentTree
]

{ #category : 'layout properties' }
DdDesignerPresenter >> currentPropertyPanel [
"The panel on the right: the Layout tab while a container is selected, the widget's own
properties otherwise."

	^ (showingLayout == true and: [ layoutPanel notNil ])
		  ifTrue: [ layoutPanel ]
		  ifFalse: [ propertyPanel ]
]

{ #category : 'layout' }
DdDesignerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: self historyToolbar expand: false;
		  add: self mainRowLayout;
		  add: codeEditor height: 150;
		  yourself
]

{ #category : 'dragging' }
DdDesignerPresenter >> dragController [

	^ dragController ifNil: [
			  dragController := DdDragController for: self.
			  dragController install.
			  dragController ]
]

{ #category : 'dragging' }
DdDesignerPresenter >> dragDropped: aPath on: aDropTarget [
"The hand is still reporting the mouse up when this is called: the move rebuilds the preview,
so it waits for the next UI cycle."

	UIManager default defer: [
			aDropTarget isSwap
				ifTrue: [
				componentTree swapNodesAt: aPath with: aDropTarget swapWithPath ]
				ifFalse: [
						aDropTarget isCellTarget
							ifTrue: [
									componentTree
										moveNodeAt: aPath
										intoGrid: aDropTarget containerPath
										cell: aDropTarget cell ]
							ifFalse: [
									aDropTarget isPointTarget
										ifTrue: [
												componentTree
													moveNodeAt: aPath
													intoAbsolute: aDropTarget containerPath
													at: aDropTarget point ]
										ifFalse: [
												componentTree
													moveNodeAt: aPath
													into: aDropTarget containerPath
													at: aDropTarget index ] ] ] ]
]

{ #category : 'history' }
DdDesignerPresenter >> historyToolbar [
"Two small square icon buttons instead of two wide text buttons."

	^ SpBoxLayout newLeftToRight
		  spacing: 2;
		  add: self undoButton width: 30;
		  add: self redoButton width: 30;
		  yourself
]

{ #category : 'initialization' }
DdDesignerPresenter >> initializePresenters [

	widgetPalette := DdWidgetPalettePresenter new.
	codeEditor := DdLayoutCodeEditorPresenter new.
	workArea := SpPresenter new.
	propertyPanel := SpPresenter new.
	componentTree := DdComponentTreePresenter new.
	componentTree whenNodeSelectedDo: [ :node |
		self onTreeNodeSelected: node ].
	syncingSelection := false.
	self dragController
]

{ #category : 'history' }
DdDesignerPresenter >> installHistoryShortcuts [

	self whenBuiltDo: [ :announcement |
			| morph |
			morph := announcement widget.
			morph bindKeyCombination: $z meta toAction: [ self undo ].
			morph bindKeyCombination: $z meta shift toAction: [ self redo ].
			morph bindKeyCombination: $y meta toAction: [ self redo ] ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> isResizing [

	^ dragController notNil and: [ dragController isResizing ]
]

{ #category : 'selection' }
DdDesignerPresenter >> keepSyncingWhile: aBlock [
	"Selection events caused by the synchronisation itself must not start it again."

	syncingSelection := true.
	aBlock ensure: [ syncingSelection := false ]
]

{ #category : 'history' }
DdDesignerPresenter >> layoutHistory [
"Undo/redo of the edited class. Must be created before the first edit (presenterClass: does it),
since it starts from the class as it is at that moment."

	(history isNil or: [ history targetClass ~~ presenter ]) ifTrue: [
		history := DdLayoutHistory forClass: presenter ].
	^ history
]

{ #category : 'layout properties' }
DdDesignerPresenter >> layoutPageForPath: aPath [
"The Layout page of the widget property panel: how the selected widget sits in its container."

	| page |
	page := [
	        DdLayoutPropertiesPresenter
		        embeddedForClass: presenter
		        path: aPath ]
		        on: Error
		        do: [ :error |
				        ^ SpLabelPresenter new
					          label: error messageText;
					          yourself ].
	page whenAppliedDo: [ :editor |
		self layoutPropertiesApplied: editor at: aPath ].
	^ page
]

{ #category : 'layout properties' }
DdDesignerPresenter >> layoutPropertiesApplied: anEditor at: aPath [

	codeEditor refreshCode.
	componentTree showModelFrom: anEditor.
	workArea refreshPreview.
	componentTree selectNodeAtPath: aPath
]

{ #category : 'layout' }
DdDesignerPresenter >> leftTabs [
"Palette and component tree share the left column as two tabs. Widgets are dragged from the
palette onto the canvas, not into the tree, so both never need to be visible at once."

	^ leftTabs ifNil: [
			  leftTabs := self newNotebook.
			  leftTabs
				  addPage:
					  (SpNotebookPage title: 'Widgets' provider: [ widgetPalette ]);
				  addPage:
					  (SpNotebookPage title: 'Structure' provider: [ componentTree ]).
			  leftTabs ]
]

{ #category : 'layout' }
DdDesignerPresenter >> mainRowLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: self leftTabs width: 220;
		  add: workArea;
		  add: (SpBoxLayout newTopToBottom
				   add: self currentPropertyPanel;
				   yourself)
		  width: 280;
		  yourself
]

{ #category : 'selection' }
DdDesignerPresenter >> onCanvasClicked [

	| varName node |
	varName := workArea selectedPresenter ifNotNil: [ :selected |
		           workArea instVarNameForPresenterInRoot: selected ].
	node := varName ifNotNil: [
			        componentTree rootNode ifNotNil: [ :root |
				        root findWidgetNamed: varName ] ].
	node ifNil: [
		^ self selectContainerAtPoint: World primaryHand position ].
	self showWidgetProperties.
	workArea updateSelectionOverlay.
	self keepSyncingWhile: [ componentTree selectNodeAtPath: node path ].
	self dragController pressedOnPath: node path
]

{ #category : 'actions' }
DdDesignerPresenter >> onLayoutEdited [
	"Called by the component tree after it has recompiled defaultLayout of the edited class."

	codeEditor refreshCode.
	workArea refreshPreview
]

{ #category : 'accessing' }
DdDesignerPresenter >> onSelectionChanged [

	| tmp1 tmp2 |
	tmp1 := workArea selectedPresenter.
	tmp1 ifNil: [ ^ self ] ifNotNil: [ tmp1 ].
	propertyPanel
		target: tmp1 owner
		subPresenter: tmp1
		onClass: tmp1 owner class
		canvas: workArea.
	tmp2 := workArea instVarNameForPresenterInRoot: tmp1.
	codeEditor highlightVarName: tmp2.
	workArea updateSelectionOverlay
]

{ #category : 'selection' }
DdDesignerPresenter >> onTreeNodeSelected: aNode [
"tree -> canvas: a widget selected in the tree becomes the canvas selection; a container shows
its Layout tab. Unsupported nodes change nothing."

	| path varName |
	syncingSelection == true ifTrue: [ ^ self ].
	aNode ifNil: [ ^ self ].
	aNode isContainerNode ifTrue: [
		^ self showLayoutPropertiesFor: aNode ].
	aNode isWidgetNode ifFalse: [ ^ self ].
	self showWidgetProperties.
	path := aNode path.
	varName := aNode varName.
	UIManager default defer: [
			self keepSyncingWhile: [
					(workArea selectWidgetNamed: varName) ifTrue: [
							self onSelectionChanged.
							componentTree selectNodeAtPath: path ] ] ]
]

{ #category : 'dragging' }
DdDesignerPresenter >> paletteContainsPoint: aPoint [
	^ widgetPalette containsWorldPoint: aPoint
]

{ #category : 'dragging' }
DdDesignerPresenter >> paletteDragDescriptor [

	^ widgetPalette selectedDescriptor
]

{ #category : 'dragging' }
DdDesignerPresenter >> paletteDropped: aDescriptor on: aDropTarget [
"Like dragDropped:on:, the hand is still busy: the work waits for the next UI cycle."

	UIManager default defer: [
			aDropTarget isCellTarget
				ifTrue: [
						self
							addPaletteWidget: aDescriptor
							intoGrid: aDropTarget containerPath
							cell: aDropTarget cell ]
				ifFalse: [
						aDropTarget isPointTarget
							ifTrue: [
									self
										addPaletteWidget: aDescriptor
										intoAbsolute: aDropTarget containerPath
										at: aDropTarget point ]
							ifFalse: [
									self
										addPaletteWidget: aDescriptor
										into: aDropTarget containerPath
										at: aDropTarget index ] ] ]
]

{ #category : 'initialization' }
DdDesignerPresenter >> presenterClass: aClass [
	"Initialises all sub-presenters, wires the canvas, the code editor and the component tree to this designer."

	presenter := aClass.
	self layoutHistory.
	self installHistoryShortcuts.
	workArea := DdCanvasPresenter onPresenter: presenter new.
	workArea designer: self.
	workArea ensureShieldInstalled.
	codeEditor classToEdit: presenter.
	codeEditor designer: self.
	widgetPalette designer: self.
	componentTree presenterClass: presenter.
	componentTree whenLayoutChangedDo: [ self onLayoutEdited ].
	propertyPanel := DdPropertyPanelPresenter new.
	propertyPanel
		target: nil
		subPresenter: nil
		onClass: nil
		canvas: workArea
]

{ #category : 'private' }
DdDesignerPresenter >> rebuildLayout [
	"Rebuilds the top-level layout (palette, canvas, component tree, property panel, code editor), then reinstalls click hooks."

	self layout: self defaultLayout.
	workArea installClickHooks
]

{ #category : 'history' }
DdDesignerPresenter >> recordHistory [

	presenter ifNil: [ ^ self ].
	self layoutHistory checkpoint.
	self updateHistoryButtons
]

{ #category : 'history' }
DdDesignerPresenter >> redo [

	presenter ifNil: [ ^ self ].
	self layoutHistory redo ifTrue: [ self afterHistoryChange ]
]

{ #category : 'history' }
DdDesignerPresenter >> redoButton [

	^ redoButton ifNil: [
			  | icon |
			  redoButton := self newButton.
			  icon := self toolbarIconNamed: #redo or: #smallRedo.
			  icon
				  ifNil: [ redoButton label: 'Redo' ]
				  ifNotNil: [ redoButton icon: icon ].
			  redoButton
				  help: 'Redo the undone change (Ctrl+Shift+Z or Ctrl+Y)';
				  action: [ self redo ].
			  redoButton ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> resizeAbsoluteChildAt: aPath to: aRectangle [
"aRectangle is in world coordinates; the layout wants the position relative to its own panel -
the same translation a drop into an absolute layout uses."

	| map containerRectangle position |
	map := self canvasMap.
	map ifNil: [
			^ componentTree notifyUser:
				  'The canvas is out of date - press Refresh' ].
	containerRectangle := map boundsAt: aPath allButLast.
	containerRectangle ifNil: [ ^ self ].
	position := (aRectangle origin - containerRectangle origin) rounded.
	self applyResizeAt: aPath with: [ :editor |
			editor
				setAbsoluteBoundsAt: aPath
				position: position
				extent: aRectangle extent rounded ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> resizeBoxChildAt: aPath in: aBoxNode to: aRectangle [

	| size |
	size := aBoxNode isHorizontal
		        ifTrue: [ aRectangle width ]
		        ifFalse: [ aRectangle height ].
	self
		applyResizeAt: aPath
		with: [ :editor | editor setBoxSizeAt: aPath size: size rounded ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> resizeGridChild: aNode handle: aHandleName to: aRectangle [
"Snaps the dragged edge to the grid's columns/rows, measured from the widgets on the canvas
(the same measurements a drop into the grid uses)."

	| map grid entries result |
	map := self canvasMap.
	map ifNil: [
			^ componentTree notifyUser:
				  'The canvas is out of date - press Refresh' ].
	aNode gridPosition ifNil: [ ^ self ].
	grid := aNode parent.
	entries := OrderedCollection new.
	grid children do: [ :child |
			| position rectangle |
			position := child gridPosition.
			rectangle := map boundsAt: child path.
			(position notNil and: [ rectangle notNil ]) ifTrue: [
					entries add: {
							position.
							child gridSpan.
							rectangle.
							child } ] ].
	result := DdGridResizeGeometry
		          cellsFor: aRectangle
		          handle: aHandleName
		          position: aNode gridPosition
		          span: aNode gridSpan
		          columns:
		          (DdGridGeometry rangesFor: entries horizontal: true)
		          rows:
		          (DdGridGeometry rangesFor: entries horizontal: false).
	(result first = aNode gridPosition and: [
		 result second = aNode gridSpan ]) ifTrue: [ ^ self ].
	self applyResizeAt: aNode path with: [ :editor |
			editor
				setGridCellAt: aNode path
				position: result first
				span: result second ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> resizeHandleAt: aPoint [
"The name of the selected widget's resize handle under aPoint, or nil."

	| rectangle names |
	rectangle := self selectedWidgetRectangle.
	rectangle ifNil: [ ^ nil ].
	names := workArea selectedResizeHandles.
	names isEmpty ifTrue: [ ^ nil ].
	^ DdResizeHandles handleAt: aPoint for: rectangle names: names
]

{ #category : 'resizing' }
DdDesignerPresenter >> resizePanedChildAt: aPath in: aPanedNode to: aRectangle [
"The dragged edge is where the slider goes; stored as a fraction of the paned layout's size."

	| map panedRectangle horizontal first edge fraction |
	map := self canvasMap.
	map ifNil: [
			^ componentTree notifyUser:
				  'The canvas is out of date - press Refresh' ].
	panedRectangle := map boundsAt: aPanedNode path.
	panedRectangle ifNil: [ ^ self ].
	horizontal := aPanedNode isHorizontal.
	first := aPath last = 1.
	edge := horizontal
		        ifTrue: [
				        first
					        ifTrue: [ aRectangle right ]
					        ifFalse: [ aRectangle left ] ]
		        ifFalse: [
				        first
					        ifTrue: [ aRectangle bottom ]
					        ifFalse: [ aRectangle top ] ].
	fraction := horizontal
		            ifTrue: [
		            edge - panedRectangle left / panedRectangle width ]
		            ifFalse: [
		            edge - panedRectangle top / panedRectangle height ].
	fraction := (fraction max: 0.05) min: 0.95.
	fraction := (fraction * 100) rounded / 100.0.
	self applyResizeAt: aPath with: [ :editor |
		editor setPanedSliderAt: aPanedNode path position: fraction ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> resized: aPath handle: aHandleName from: anOldRectangle to: aNewRectangle [
"Turns a resize on the canvas into code, according to the container the widget sits in."

	| node container |
	node := componentTree rootNode ifNotNil: [ :root |
			        [ root nodeAtPath: aPath ]
				        on: Error
				        do: [ nil ] ].
	node ifNil: [
		^ componentTree notifyUser:
			  'The tree is out of date - press Refresh' ].
	container := node parent.
	(container isKindOf: DdAbsoluteNode) ifTrue: [
		^ self resizeAbsoluteChildAt: aPath to: aNewRectangle ].
	(container isKindOf: DdPanedNode) ifTrue: [
		^ self resizePanedChildAt: aPath in: container to: aNewRectangle ].
	(container isKindOf: DdGridNode) ifTrue: [
		^ self resizeGridChild: node handle: aHandleName to: aNewRectangle ].
	container class == DdBoxNode ifTrue: [
		^ self resizeBoxChildAt: aPath in: container to: aNewRectangle ].
	Transcript
		show:
			'Resizing inside ' , container kindLabel , ' is not supported yet';
		cr
]

{ #category : 'selection' }
DdDesignerPresenter >> selectContainerAtPoint: aPoint [
"A click on the canvas that hit no widget of the tree: select the deepest container there."

	| map root path |
	root := componentTree rootNode.
	root ifNil: [ ^ self ].
	map := self canvasMap.
	map ifNil: [ ^ self ].
	path := root
		        deepestContainerContaining: aPoint
		        rectangles: [ :each | map boundsAt: each ].
	path ifNil: [ ^ self ].
	self keepSyncingWhile: [ componentTree selectNodeAtPath: path ].
	self showLayoutPropertiesFor: (root nodeAtPath: path)
]

{ #category : 'resizing' }
DdDesignerPresenter >> selectedNodePath [

	| varName node |
	workArea selectedContainerPath ifNotNil: [ :path | ^ path ].
	workArea selectedPresenter ifNil: [ ^ nil ].
	varName := workArea instVarNameForPresenterInRoot:
		           workArea selectedPresenter.
	varName ifNil: [ ^ nil ].
	node := componentTree rootNode ifNotNil: [ :root |
		        root findWidgetNamed: varName ].
	^ node ifNotNil: [ :aNode | aNode path ]
]

{ #category : 'resizing' }
DdDesignerPresenter >> selectedWidgetRectangle [
"World bounds of the selection (a container or a widget), or nil when there is no live one."

	^ workArea selectionTargetMorph ifNotNil: [ :morph |
		  morph world ifNotNil: [ morph boundsInWorld ] ]
]

{ #category : 'layout properties' }
DdDesignerPresenter >> showLayoutPropertiesFor: aNode [

	| path |
	path := aNode path.
	layoutPanel := [
	               DdLayoutPropertiesPresenter
		               forClass: presenter
		               path: path ]
		               on: Error
		               do: [ :error |
		               ^ componentTree notifyUser: error messageText ].
	layoutPanel whenAppliedDo: [ :editor |
		self layoutPropertiesApplied: editor at: path ].
	showingLayout := true.
	workArea selectContainerAt: path.
	self rebuildLayout.
	workArea updateSelectionOverlay
]

{ #category : 'layout properties' }
DdDesignerPresenter >> showWidgetProperties [

	workArea clearContainerSelection.
	showingLayout == true ifFalse: [ ^ self ].
	showingLayout := false.
	self rebuildLayout
]

{ #category : 'history' }
DdDesignerPresenter >> toolbarIconNamed: aSymbol or: aFallbackSymbol [
"Icon names differ between Pharo versions: try both, answer nil when neither exists."

	^ Smalltalk ui icons
		  iconNamed: aSymbol
		  ifNone: [
		  Smalltalk ui icons iconNamed: aFallbackSymbol ifNone: [ nil ] ]
]

{ #category : 'history' }
DdDesignerPresenter >> undo [

	presenter ifNil: [ ^ self ].
	self layoutHistory undo ifTrue: [ self afterHistoryChange ]
]

{ #category : 'history' }
DdDesignerPresenter >> undoButton [

	^ undoButton ifNil: [
			  | icon |
			  undoButton := self newButton.
			  icon := self toolbarIconNamed: #undo or: #smallUndo.
			  icon
				  ifNil: [ undoButton label: 'Undo' ]
				  ifNotNil: [ undoButton icon: icon ].
			  undoButton
				  help: 'Undo the last layout change (Ctrl+Z)';
				  action: [ self undo ].
			  undoButton ]
]

{ #category : 'history' }
DdDesignerPresenter >> updateHistoryButtons [

	| canUndo canRedo |
	canUndo := presenter notNil and: [ self layoutHistory canUndo ].
	canRedo := presenter notNil and: [ self layoutHistory canRedo ].
	undoButton ifNotNil: [ :button | button enabled: canUndo ].
	redoButton ifNotNil: [ :button | button enabled: canRedo ]
]

{ #category : 'accessing' }
DdDesignerPresenter >> workArea [
  ^workArea 
]
