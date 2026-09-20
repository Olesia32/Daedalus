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
	aDraggedNode ifNil: [ ^ aNode canAcceptChild ].
	(aNode == aDraggedNode or: [ aNode isDescendantOf: aDraggedNode ])
		ifTrue: [ ^ false ].
	^ aNode canAcceptChild or: [ aDraggedNode parent == aNode ]
]

{ #category : 'initialization' }
DdDropTargetFinder >> setRoot: aRootNode rectangles: aOneArgBlock [
	root := aRootNode.
	rectangleAt := aOneArgBlock
]

{ #category : 'finding' }
DdDropTargetFinder >> targetAt: aPoint dragging: aDraggedPathOrNil [
"Where a node dragged from aDraggedPathOrNil (nil: a new widget) lands when released at aPoint:
the deepest container under the point that can take it. Answers nil when there is none."

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
