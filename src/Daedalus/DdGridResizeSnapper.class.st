Class {
	#name : 'DdGridResizeSnapper',
	#superclass : 'Object',
	#instVars : [
		'geometry',
		'grid',
		'node'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdGridResizeSnapper class >> geometry: aGridCellGeometry node: aGridChildNode [

	^ self new setGeometry: aGridCellGeometry node: aGridChildNode
]

{ #category : 'snapping' }
DdGridResizeSnapper >> cellsFor: aRectangle handle: aName [

	^ geometry
		  cellsFor: aRectangle
		  handle: aName
		  position: node gridPosition
		  span: node gridSpan
]

{ #category : 'snapping' }
DdGridResizeSnapper >> previewFor: aRectangle handle: aName [
"{ the area the widget would take. whether it may take it }."

	| cells |
	cells := self cellsFor: aRectangle handle: aName.
	^ {
		  (geometry rectangleFor: cells first span: cells second).
		  (grid childBlocking: cells first span: cells second ignoring: node)
			  isNil }
]

{ #category : 'initialization' }
DdGridResizeSnapper >> setGeometry: aGridCellGeometry node: aGridChildNode [

	geometry := aGridCellGeometry.
	node := aGridChildNode.
	grid := aGridChildNode parent
]
