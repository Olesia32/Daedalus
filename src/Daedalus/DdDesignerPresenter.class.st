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
		'dragController'
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

	| varName |
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
		(DdLayoutEditor forClass: presenter)
			insertWidget: varName into: aContainerPath at: anIndex;
			applyTo: presenter ]
		on: Error
		do: [ :error | ^ componentTree notifyUser: error messageText ].
	codeEditor refreshCode.
	componentTree refresh.
	componentTree selectNodeAtPath: aContainerPath , { anIndex }.
	workArea refreshPreview
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

{ #category : 'layout' }
DdDesignerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 20;
				   add: widgetPalette width: 150;
				   add: workArea;
				   add: (SpBoxLayout newTopToBottom
						    spacing: 10;
						    add: componentTree height: 220;
						    add: propertyPanel;
						    yourself)
				   width: 250;
				   yourself);
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
			componentTree
				moveNodeAt: aPath
				into: aDropTarget containerPath
				at: aDropTarget index ]
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
	"listens to the mouse from the start, so that a drag from the palette is possible before any canvas click"
	self dragController
]

{ #category : 'selection' }
DdDesignerPresenter >> keepSyncingWhile: aBlock [
	"Selection events caused by the synchronisation itself must not start it again."

	syncingSelection := true.
	aBlock ensure: [ syncingSelection := false ]
]

{ #category : 'selection' }
DdDesignerPresenter >> onCanvasClicked [
"canvas -> tree: after a click on the canvas, select the matching widget in the tree.
The pressed widget also becomes a candidate for dragging."

	| varName node |
	workArea selectedPresenter ifNil: [ ^ self ].
	varName := workArea instVarNameForPresenterInRoot:
		           workArea selectedPresenter.
	varName ifNil: [ ^ self ].
	node := componentTree rootNode ifNotNil: [ :root |
		        root findWidgetNamed: varName ].
	node ifNil: [ ^ self ].
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
	propertyPanel := DdPropertyPanelPresenter new.
	propertyPanel
		target: tmp1 owner
		subPresenter: tmp1
		onClass: tmp1 owner class
		canvas: workArea.
	tmp2 := workArea instVarNameForPresenterInRoot: tmp1.
	self rebuildLayout.
	codeEditor highlightVarName: tmp2.
	workArea updateSelectionOverlay
]

{ #category : 'selection' }
DdDesignerPresenter >> onTreeNodeSelected: aNode [
	"tree -> canvas: a widget selected in the tree becomes the canvas selection.
	Containers and unsupported nodes do not exist on the canvas, so they change nothing."

	| path varName |
	syncingSelection == true ifTrue: [ ^ self ].
	(aNode notNil and: [ aNode isWidgetNode ]) ifFalse: [ ^ self ].
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
			self
				addPaletteWidget: aDescriptor
				into: aDropTarget containerPath
				at: aDropTarget index ]
]

{ #category : 'initialization' }
DdDesignerPresenter >> presenterClass: aClass [
	"Initialises all sub-presenters, wires the canvas, the code editor and the component tree to this designer."

	presenter := aClass.
	workArea := DdCanvasPresenter onPresenter: presenter new.
	workArea designer: self.
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

{ #category : 'accessing' }
DdDesignerPresenter >> workArea [
  ^workArea 
]
