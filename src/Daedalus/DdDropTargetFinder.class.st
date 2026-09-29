Class {
	#name : 'DdDropTargetFinder',
	#superclass : 'Object',
	#instVars : [
		'root',
		'rectangleAt'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'constants' }
DdDropTargetFinder class >> defaultDropIndicatorExtent [
"A reasonable guess for a new widget's size before it has a morph of its own to measure -
only used to draw the drop indicator, never the widget's actual (natural) extent."

	^ 80 @ 25
]

{ #category : 'instance creation' }
DdDropTargetFinder class >> root: aRootNode rectangles: aOneArgBlock [
"aOneArgBlock answers the rectangle (world coordinates) of the node at a given path, or nil."

	^ self new setRoot: aRootNode rectangles: aOneArgBlock
]

{ #category : 'finding' }
DdDropTargetFinder >> canDropInto: aNode dragging: aDraggedNode point: aPoint [

	| rectangle |
	aNode isContainerNode ifFalse: [ ^ false ].
	rectangle := rectangleAt value: aNode path.
	(rectangle notNil and: [ rectangle containsPoint: aPoint ]) ifFalse: [
		^ false ].
	(aDraggedNode notNil and: [
		 aNode == aDraggedNode or: [ aNode isDescendantOf: aDraggedNode ] ])
		ifTrue: [ ^ false ].
	(aNode acceptsCellDrops or: [ aNode acceptsPointDrops ]) ifTrue: [
		^ true ].
	aDraggedNode ifNil: [ ^ aNode canAcceptChild ].
	^ aNode canAcceptChild or: [ aDraggedNode parent == aNode ]
]

{ #category : 'finding' }
DdDropTargetFinder >> cellTargetIn: aGrid at: aPoint dragging: aDragged [

	| entries found cell occupantEntry occupant swapPath isNoOp |
	entries := OrderedCollection new.
	entries addAll: (aGrid children select: [ :child |
				 | position rectangle |
				 position := child gridPosition.
				 rectangle := rectangleAt value: child path.
				 position notNil and: [ rectangle notNil ] ]).
	found := DdGridGeometry
		         cellAt: aPoint
		         entries: entries
		         in: (rectangleAt value: aGrid path).
	cell := found first.
	occupantEntry := DdGridGeometry
		                 entryCovering: cell
		                 in:
		                 (entries reject: [ :each | each fourth == aDragged ]).
	occupant := occupantEntry ifNotNil: [ occupantEntry fourth ].
	swapPath := nil.
	occupant
		ifNil: [
				isNoOp := aDragged notNil and: [
					          aDragged parent == aGrid and: [
						          aDragged gridPosition = cell ] ] ]
		ifNotNil: [
				(aDragged notNil and: [ aDragged parent == aGrid ])
					ifTrue: [
							swapPath := occupant path.
							isNoOp := false ]
					ifFalse: [ isNoOp := true ] ].
	^ DdDropTarget new
		  containerPath: aGrid path;
		  cell: cell;
		  swapWithPath: swapPath;
		  indicator: found second;
		  isNoOp: isNoOp;
		  yourself
]

{ #category : 'finding' }
DdDropTargetFinder >> pointTargetIn: aLayout at: aPoint dragging: aDragged [

	| rectangle localPoint size |
	rectangle := rectangleAt value: aLayout path.
	localPoint := aPoint - rectangle origin.
	size := (aDragged ifNotNil: [ rectangleAt value: aDragged path ])
		        ifNotNil: [ :draggedRectangle | draggedRectangle extent ]
		        ifNil: [ self class defaultDropIndicatorExtent ].
	^ DdDropTarget new
		  containerPath: aLayout path;
		  point: localPoint;
		  indicator: (aPoint corner: aPoint + size);
		  isNoOp: false;
		  yourself
]

{ #category : 'initialization' }
DdDropTargetFinder >> setRoot: aRootNode rectangles: aOneArgBlock [
	root := aRootNode.
	rectangleAt := aOneArgBlock
]

{ #category : 'finding' }
DdDropTargetFinder >> targetAt: aPoint dragging: aDraggedPathOrNil [

	| dragged best rectangles horizontal index |
	root ifNil: [ ^ nil ].
	dragged := aDraggedPathOrNil ifNotNil: [ :path |
		           root nodeAtPath: path ].
	best := nil.
	root allNodesDo: [ :node |
			(self canDropInto: node dragging: dragged point: aPoint) ifTrue: [
					(best isNil or: [ node path size > best path size ]) ifTrue: [
						best := node ] ] ].
	best ifNil: [ ^ nil ].
	best acceptsCellDrops ifTrue: [
		^ self cellTargetIn: best at: aPoint dragging: dragged ].
	best acceptsPointDrops ifTrue: [
		^ self pointTargetIn: best at: aPoint dragging: dragged ].
	rectangles := ((best children reject: [ :child | child == dragged ])
		               collect: [ :child | rectangleAt value: child path ])
		              select: [ :each | each notNil ].
	horizontal := best isHorizontal.
	index := DdDropGeometry
		         indexAt: aPoint
		         among: rectangles
		         horizontal: horizontal.
	^ DdDropTarget new
		  containerPath: best path;
		  index: index;
		  indicator: (DdDropGeometry
				   indicatorAt: index
				   among: rectangles
				   in: (rectangleAt value: best path)
				   horizontal: horizontal);
		  isNoOp: (dragged notNil and: [
						   dragged parent == best and: [
								   (best children identityIndexOf: dragged) = index ] ]);
		  yourself
]
