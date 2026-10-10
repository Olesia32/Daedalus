Class {
	#name : 'DdGridCellGeometry',
	#superclass : 'Object',
	#instVars : [
		'columnStarts',
		'columnWidths',
		'columnSpacing',
		'rowStarts',
		'rowHeights',
		'rowSpacing'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdGridCellGeometry class >> columns: columnStartArray widths: columnWidthArray columnSpacing: aColumnSpacing rows: rowStartArray heights: rowHeightArray rowSpacing: aRowSpacing [
"Starts are world coordinates, one per column (row); sizes are in pixels."

	^ self new
		  setColumns: columnStartArray
		  widths: columnWidthArray
		  columnSpacing: aColumnSpacing
		  rows: rowStartArray
		  heights: rowHeightArray
		  rowSpacing: aRowSpacing
]

{ #category : 'instance creation' }
DdGridCellGeometry class >> fromGridMorph: aMorph [

	| policy inner computation offset |
	policy := aMorph layoutPolicy.
	(policy isKindOf: SpMorphicGridLayout) ifFalse: [ ^ nil ].
	aMorph submorphs isEmpty ifTrue: [ ^ nil ].
	^ [
		  inner := aMorph layoutBounds insetBy: policy padding.
		  computation := (SpMorphicGridLayoutComputation layout: policy)
			                 computeMorphs: aMorph submorphs
			                 bounds: inner.
		  offset := aMorph boundsInWorld origin - aMorph bounds origin
		            + inner origin.
		  self
			  columns:
			  (computation columnPositions collect: [ :each | each + offset x ])
			  widths: computation columnWidths copy
			  columnSpacing: policy columnSpacing
			  rows:
			  (computation rowPositions collect: [ :each | each + offset y ])
			  heights: computation rowHeights copy
			  rowSpacing: policy rowSpacing ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'geometry' }
DdGridCellGeometry >> cellAt: aPoint in: aContainerRectangle [

	| column row strip left right top bottom |
	column := self indexAt: aPoint x horizontal: true.
	row := self indexAt: aPoint y horizontal: false.
	strip := DdGridGeometry edgeStrip.
	column second
		ifTrue: [
				left := aContainerRectangle right - strip.
				right := aContainerRectangle right ]
		ifFalse: [
				left := self startOf: column first horizontal: true.
				right := self endOf: column first horizontal: true ].
	row second
		ifTrue: [
				top := aContainerRectangle bottom - strip.
				bottom := aContainerRectangle bottom ]
		ifFalse: [
				top := self startOf: row first horizontal: false.
				bottom := self endOf: row first horizontal: false ].
	^ {
		  (column first @ row first).
		  (left @ top corner: (right max: left + 4) @ (bottom max: top + 4)) }
]

{ #category : 'geometry' }
DdGridCellGeometry >> cellsFor: aRectangle handle: aName position: aPosition span: aSpan [

	| left right top bottom |
	left := aPosition x.
	right := aPosition x + aSpan x - 1.
	top := aPosition y.
	bottom := aPosition y + aSpan y - 1.
	(#( #topRight #right #bottomRight ) includes: aName) ifTrue: [
			right := self
				         lastIndexBefore: aRectangle right
				         from: left
				         horizontal: true ].
	(#( #topLeft #left #bottomLeft ) includes: aName) ifTrue: [
			left := self
				        firstIndexAfter: aRectangle left
				        upTo: right
				        horizontal: true ].
	(#( #bottomLeft #bottom #bottomRight ) includes: aName) ifTrue: [
			bottom := self
				          lastIndexBefore: aRectangle bottom
				          from: top
				          horizontal: false ].
	(#( #topLeft #top #topRight ) includes: aName) ifTrue: [
			top := self
				       firstIndexAfter: aRectangle top
				       upTo: bottom
				       horizontal: false ].
	^ {
		  (left @ top).
		  (right - left + 1 @ (bottom - top + 1)) }
]

{ #category : 'accessing' }
DdGridCellGeometry >> centerOf: anIndex horizontal: aBoolean [

	^ (self startOf: anIndex horizontal: aBoolean)
	  + ((self sizeOf: anIndex horizontal: aBoolean) / 2)
]

{ #category : 'accessing' }
DdGridCellGeometry >> columnCount [

	^ columnStarts size
]

{ #category : 'accessing' }
DdGridCellGeometry >> endOf: anIndex horizontal: aBoolean [

	^ (self startOf: anIndex horizontal: aBoolean)
	  + (self sizeOf: anIndex horizontal: aBoolean)
]

{ #category : 'private' }
DdGridCellGeometry >> extraSizeHorizontal: aBoolean [
"The size assumed for a column (row) past the last one: the last real non-empty one."

	| sizes |
	sizes := aBoolean
		         ifTrue: [ columnWidths ]
		         ifFalse: [ rowHeights ].
	^ sizes reversed detect: [ :each | each > 0 ] ifNone: [ 24 ]
]

{ #category : 'geometry' }
DdGridCellGeometry >> firstIndexAfter: anEdge upTo: anEndIndex horizontal: aBoolean [
"The first column (row), going back from anEndIndex but never before 1, whose middle anEdge has
passed."

	| index |
	index := anEndIndex.
	[
		index > 1 and: [
			(self centerOf: index - 1 horizontal: aBoolean) > anEdge ] ]
		whileTrue: [ index := index - 1 ].
	^ index
]

{ #category : 'geometry' }
DdGridCellGeometry >> indexAt: aCoordinate horizontal: aBoolean [
"{ column (row) under aCoordinate. whether it is a new one after the last }. Half of the spacing
on each side belongs to a cell; the far edge of the last one means 'a new one after it'."

	| count spacing zone |
	count := aBoolean
		         ifTrue: [ columnStarts size ]
		         ifFalse: [ rowStarts size ].
	count = 0 ifTrue: [ ^ { 1. false } ].
	spacing := aBoolean
		           ifTrue: [ columnSpacing ]
		           ifFalse: [ rowSpacing ].
	zone := (self sizeOf: count horizontal: aBoolean) // 4 min:
		        DdGridGeometry edgeZone.
	aCoordinate >= ((self endOf: count horizontal: aBoolean) - zone)
		ifTrue: [
				^ {
					  (count + 1).
					  true } ].
	1 to: count do: [ :index |
			aCoordinate
			< ((self endOf: index horizontal: aBoolean) + (spacing / 2))
				ifTrue: [
						^ {
							  index.
							  false } ] ].
	^ {
		  count.
		  false }
]

{ #category : 'geometry' }
DdGridCellGeometry >> lastIndexBefore: anEdge from: aStartIndex horizontal: aBoolean [
"The last column (row), starting from aStartIndex, whose middle anEdge has passed."

	| index |
	index := aStartIndex.
	[
		index < (aStartIndex + 50) and: [
			(self centerOf: index + 1 horizontal: aBoolean) < anEdge ] ]
		whileTrue: [ index := index + 1 ].
	^ index
]

{ #category : 'geometry' }
DdGridCellGeometry >> rectangleFor: aCell span: aSpan [
"World area of the cells from aCell over aSpan, never thinner than 4 pixels so that it can be
seen even over zero-height rows."

	| left top right bottom |
	left := self startOf: aCell x horizontal: true.
	top := self startOf: aCell y horizontal: false.
	right := self endOf: aCell x + aSpan x - 1 horizontal: true.
	bottom := self endOf: aCell y + aSpan y - 1 horizontal: false.
	^ left @ top corner: (right max: left + 4) @ (bottom max: top + 4)
]

{ #category : 'accessing' }
DdGridCellGeometry >> rowCount [

	^ rowStarts size
]

{ #category : 'initialization' }
DdGridCellGeometry >> setColumns: columnStartArray widths: columnWidthArray columnSpacing: aColumnSpacing rows: rowStartArray heights: rowHeightArray rowSpacing: aRowSpacing [

	columnStarts := columnStartArray asArray.
	columnWidths := columnWidthArray asArray.
	columnSpacing := aColumnSpacing.
	rowStarts := rowStartArray asArray.
	rowHeights := rowHeightArray asArray.
	rowSpacing := aRowSpacing
]

{ #category : 'accessing' }
DdGridCellGeometry >> sizeOf: anIndex horizontal: aBoolean [
"Width (height) of column (row) anIndex. Spec gives an empty row of a non-homogeneous grid no
height at all - that zero is kept, it is what the grid really does."

	| sizes |
	sizes := aBoolean
		         ifTrue: [ columnWidths ]
		         ifFalse: [ rowHeights ].
	anIndex <= sizes size ifTrue: [ ^ sizes at: anIndex ].
	^ self extraSizeHorizontal: aBoolean
]

{ #category : 'accessing' }
DdGridCellGeometry >> startOf: anIndex horizontal: aBoolean [
"Where column (row) anIndex begins. One past the last is placed after it, one spacing away,
every further one a whole extra cell further."

	| starts sizes spacing last |
	starts := aBoolean
		          ifTrue: [ columnStarts ]
		          ifFalse: [ rowStarts ].
	sizes := aBoolean
		         ifTrue: [ columnWidths ]
		         ifFalse: [ rowHeights ].
	spacing := aBoolean
		           ifTrue: [ columnSpacing ]
		           ifFalse: [ rowSpacing ].
	anIndex <= starts size ifTrue: [ ^ starts at: anIndex ].
	last := starts size.
	^ (starts at: last) + (sizes at: last) + spacing
	  +
	  (anIndex - last - 1
	   * ((self extraSizeHorizontal: aBoolean) + spacing))
]
