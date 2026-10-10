Class {
	#name : 'DdDragController',
	#superclass : 'Object',
	#instVars : [
		'designer',
		'state',
		'pressPoint',
		'draggedPath',
		'map',
		'indicator',
		'draggedDescriptor',
		'resizeHandle',
		'resizeStartRect',
		'resizeSnapper'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'constants' }
DdDragController class >> dragThreshold [

	^ 6
]

{ #category : 'instance creation' }
DdDragController class >> for: arg1 [

	^ self new setDesigner: arg1
]

{ #category : 'constants' }
DdDragController class >> minResizeExtent [

	^ 10 @ 10
]

{ #category : 'constants' }
DdDragController class >> refusedResizeColor [

	^ Color
		  r: 0.9
		  g: 0.2
		  b: 0.15
		  alpha: 0.3
]

{ #category : 'constants' }
DdDragController class >> resizeColor [

	^ Color
		  r: 0.15
		  g: 0.5
		  b: 0.95
		  alpha: 0.25
]

{ #category : 'dragging' }
DdDragController >> beginDrag [
	"By now the list has handled the press, so its selection is the row being dragged.
	Without that row, or without a complete map of the preview, there is no drag."

	state == #pressedOnPalette ifTrue: [
			draggedDescriptor := designer paletteDragDescriptor.
			draggedDescriptor ifNil: [ ^ self cancel ] ].
	map := designer canvasMap.
	map ifNil: [ ^ self cancel ].
	state := #dragging.
	indicator := DdDropIndicatorMorph new.
	indicator openInWorld
]

{ #category : 'resizing' }
DdDragController >> beginResize: aHandleName [
"A grid child gets a snapper: from the first moment the indicator shows the cells the widget
covers, and while dragging the cells it would cover."

	| rectangle path |
	rectangle := designer selectedWidgetRectangle.
	path := designer selectedNodePath.
	(rectangle isNil or: [ path isNil ]) ifTrue: [ ^ self ].
	state := #resizing.
	resizeHandle := aHandleName.
	resizeStartRect := rectangle.
	draggedPath := path.
	resizeSnapper := designer resizeSnapperFor: path.
	indicator := DdDropIndicatorMorph new.
	indicator color: self class resizeColor.
	indicator openInWorld.
	self showResizeAt: pressPoint
]

{ #category : 'dragging' }
DdDragController >> cancel [

	state := #idle.
	indicator ifNotNil: [ :morph | morph delete ].
	indicator := nil.
	map := nil.
	draggedPath := nil.
	draggedDescriptor := nil.
	resizeHandle := nil.
	resizeStartRect := nil.
	resizeSnapper := nil
]

{ #category : 'resizing' }
DdDragController >> finishResizeAt: arg1 [

	| tmp1 tmp2 tmp3 tmp4 |
	tmp1 := draggedPath.
	tmp2 := resizeHandle.
	tmp3 := resizeStartRect.
	tmp4 := self resizedRectangleAt: arg1.
	self cancel.
	tmp3 = tmp4 ifTrue: [ ^ self ].
	nil.
	designer
		resized: tmp1
		handle: tmp2
		from: tmp3
		to: tmp4
]

{ #category : 'events' }
DdDragController >> handleListenEvent: arg1 [

	[ self processEvent: arg1 ]
		on: Error
		do: [ :arg2 |
				Transcript
					show: 'DdDragController: ' , arg2 description;
					cr.
				self cancel ]
]

{ #category : 'accessing' }
DdDragController >> indicatorMorph [

	^ indicator
]

{ #category : 'initialization' }
DdDragController >> initialize [

	super initialize.
	state := #idle
]

{ #category : 'initialization' }
DdDragController >> install [

	[ World primaryHand addMouseListener: self ]
		on: Error
		do: [ :arg1 |
				Transcript
					show: 'DdDragController could not install: ' , arg1 description;
					cr ]
]

{ #category : 'dragging' }
DdDragController >> isFarEnough: arg1 [

	| tmp1 tmp2 tmp3 |
	tmp1 := arg1 x - pressPoint x.
	tmp2 := arg1 y - pressPoint y.
	tmp3 := self class dragThreshold.
	^ tmp1 * tmp1 + (tmp2 * tmp2) >= (tmp3 * tmp3)
]

{ #category : 'testing' }
DdDragController >> isResizing [

	^ state == #resizing
]

{ #category : 'dragging' }
DdDragController >> moveTo: aPoint [

	state == #idle ifTrue: [ ^ self ].
	state == #resizing ifTrue: [ ^ self showResizeAt: aPoint ].
	(#( #pressed #pressedOnPalette ) includes: state) ifTrue: [
			(self isFarEnough: aPoint) ifFalse: [ ^ self ].
			self beginDrag.
			state == #dragging ifFalse: [ ^ self ] ].
	self updateDragAt: aPoint
]

{ #category : 'dragging' }
DdDragController >> pressAt: arg1 [

	| tmp1 tmp3 |
	self cancel.
	pressPoint := arg1.
	(designer paletteContainsPoint: arg1) ifTrue: [
		^ state := #pressedOnPalette ].
	nil.
	tmp3 := tmp1 := designer resizeHandleAt: arg1.
	tmp3 ifNotNil: [ self beginResize: tmp1 ]
]

{ #category : 'dragging' }
DdDragController >> pressedOnPath: arg1 [

	state == #resizing ifTrue: [ ^ self ].
	nil.
	pressPoint
		ifNil: [ pressPoint := World primaryHand position ]
		ifNotNil: [ pressPoint ].
	draggedPath := arg1.
	state := #pressed
]

{ #category : 'events' }
DdDragController >> processEvent: arg1 [

	arg1 isMouse ifFalse: [ ^ self ].
	arg1 isMouseDown ifTrue: [ ^ self pressAt: arg1 position ].
	nil.
	arg1 isMouseUp ifTrue: [ ^ self release: arg1 position ].
	nil.
	arg1 isMouseMove ifTrue: [ ^ self moveTo: arg1 position ].
	nil
]

{ #category : 'dragging' }
DdDragController >> release: arg1 [

	| tmp1 tmp2 tmp3 |
	state == #resizing ifTrue: [ ^ self finishResizeAt: arg1 ].
	nil.
	state == #dragging ifFalse: [ ^ self cancel ].
	tmp1 := map dropTargetAt: arg1 dragging: draggedPath.
	tmp2 := draggedPath.
	tmp3 := draggedDescriptor.
	self cancel.
	(tmp1 notNil and: [ tmp1 isNoOp not ]) ifFalse: [ ^ self ].
	tmp3
		ifNil: [ designer dragDropped: tmp2 on: tmp1 ]
		ifNotNil: [ designer paletteDropped: tmp3 on: tmp1 ]
]

{ #category : 'resizing' }
DdDragController >> resizedRectangleAt: arg1 [

	^ DdResizeHandles
		  resized: resizeStartRect
		  handle: resizeHandle
		  by: arg1 - pressPoint
		  minExtent: self class minResizeExtent
]

{ #category : 'initialization' }
DdDragController >> setDesigner: arg1 [

	designer := arg1
]

{ #category : 'resizing' }
DdDragController >> showResizeAt: aPoint [
"Free resizing shows the dragged rectangle; a snapped one shows the cells, red when another
widget is in the way."

	| rectangle preview |
	rectangle := self resizedRectangleAt: aPoint.
	preview := resizeSnapper ifNotNil: [ :snapper |
			           [ snapper previewFor: rectangle handle: resizeHandle ]
				           on: Error
				           do: [ nil ] ].
	preview ifNil: [
			indicator color: self class resizeColor.
			^ indicator showAt: rectangle ].
	indicator color: (preview second
			 ifTrue: [ self class resizeColor ]
			 ifFalse: [ self class refusedResizeColor ]).
	indicator showAt: preview first
]

{ #category : 'accessing' }
DdDragController >> state [

	^ state
]

{ #category : 'dragging' }
DdDragController >> updateDragAt: arg1 [

	| tmp1 |
	tmp1 := map dropTargetAt: arg1 dragging: draggedPath.
	(tmp1 isNil or: [ tmp1 isNoOp ])
		ifTrue: [ indicator hideIndicator ]
		ifFalse: [ indicator showAt: tmp1 indicator ]
]
