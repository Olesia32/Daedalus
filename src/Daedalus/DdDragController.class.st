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
		'resizeStartRect'
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

	| rectangle path |
	rectangle := designer selectedWidgetRectangle.
	path := designer selectedNodePath.
	(rectangle isNil or: [ path isNil ]) ifTrue: [ ^ self ].
	state := #resizing.
	resizeHandle := aHandleName.
	resizeStartRect := rectangle.
	draggedPath := path.
	indicator := DdDropIndicatorMorph new.
	indicator color: (Color
			 r: 0.15
			 g: 0.5
			 b: 0.95
			 alpha: 0.25).
	indicator openInWorld.
	indicator showAt: rectangle
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
	resizeStartRect := nil
]

{ #category : 'resizing' }
DdDragController >> finishResizeAt: aPoint [

	| path handle from to |
	path := draggedPath.
	handle := resizeHandle.
	from := resizeStartRect.
	to := self resizedRectangleAt: aPoint.
	self cancel.
	from = to ifTrue: [ ^ self ].
	designer
		resized: path
		handle: handle
		from: from
		to: to
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
	state == #resizing ifTrue: [
		^ indicator showAt: (self resizedRectangleAt: aPoint) ].
	(#( #pressed #pressedOnPalette ) includes: state) ifTrue: [
			(self isFarEnough: aPoint) ifFalse: [ ^ self ].
			self beginDrag.
			state == #dragging ifFalse: [ ^ self ] ].
	self updateDragAt: aPoint
]

{ #category : 'dragging' }
DdDragController >> pressAt: aPoint [

	self cancel.
	pressPoint := aPoint.
	(designer paletteContainsPoint: aPoint) ifTrue: [
		^ state := #pressedOnPalette ].
	(designer resizeHandleAt: aPoint) ifNotNil: [ :handle |
		self beginResize: handle ]
]

{ #category : 'dragging' }
DdDragController >> pressedOnPath: aPath [
"The click that grabbed a handle also reaches the canvas, which reports the widget under it:
that must not turn the resize into an ordinary drag."

	state == #resizing ifTrue: [ ^ self ].
	pressPoint ifNil: [ pressPoint := World primaryHand position ].
	draggedPath := aPath.
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
DdDragController >> release: aPoint [

	| target path descriptor |
	state == #resizing ifTrue: [ ^ self finishResizeAt: aPoint ].
	state == #dragging ifFalse: [ ^ self cancel ].
	target := map dropTargetAt: aPoint dragging: draggedPath.
	path := draggedPath.
	descriptor := draggedDescriptor.
	self cancel.
	(target notNil and: [ target isNoOp not ]) ifFalse: [ ^ self ].
	descriptor
		ifNil: [ designer dragDropped: path on: target ]
		ifNotNil: [ designer paletteDropped: descriptor on: target ]
]

{ #category : 'resizing' }
DdDragController >> resizedRectangleAt: aPoint [

	^ DdResizeHandles
		  resized: resizeStartRect
		  handle: resizeHandle
		  by: aPoint - pressPoint
		  minExtent: self class minResizeExtent
]

{ #category : 'initialization' }
DdDragController >> setDesigner: arg1 [

	designer := arg1
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
