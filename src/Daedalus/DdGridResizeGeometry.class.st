Class {
	#name : 'DdGridResizeGeometry',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry' }
DdGridResizeGeometry class >> cellsFor: aRectangle handle: aName position: aPosition span: aSpan columns: columnRanges rows: rowRanges [
"{ newPosition. newSpan } after resizing the widget at aPosition/aSpan to aRectangle with
handle aName. An axis with no known columns (or rows) is left unchanged."

	| left right top bottom |
	left := aPosition x.
	right := aPosition x + aSpan x - 1.
	top := aPosition y.
	bottom := aPosition y + aSpan y - 1.
	columnRanges isEmpty ifFalse: [
			(#( #topRight #right #bottomRight ) includes: aName) ifTrue: [
					right := self
						         lastIndexBefore: aRectangle right
						         from: left
						         ranges: columnRanges ].
			(#( #topLeft #left #bottomLeft ) includes: aName) ifTrue: [
					left := self
						        firstIndexAfter: aRectangle left
						        upTo: right
						        ranges: columnRanges ] ].
	rowRanges isEmpty ifFalse: [
			(#( #bottomLeft #bottom #bottomRight ) includes: aName) ifTrue: [
					bottom := self
						          lastIndexBefore: aRectangle bottom
						          from: top
						          ranges: rowRanges ].
			(#( #topLeft #top #topRight ) includes: aName) ifTrue: [
					top := self
						       firstIndexAfter: aRectangle top
						       upTo: bottom
						       ranges: rowRanges ] ].
	^ {
		  (left @ top).
		  (right - left + 1 @ (bottom - top + 1)) }
]

{ #category : 'private' }
DdGridResizeGeometry class >> center: anIndex ranges: ranges [

	| known first last pitch |
	known := ranges
		         detect: [ :each | each key = anIndex ]
		         ifNone: [ nil ].
	known ifNotNil: [ ^ known value first + known value last / 2 ].
	first := ranges first.
	last := ranges last.
	pitch := first key = last key
		         ifTrue: [ first value last - first value first ]
		         ifFalse: [
				         last value first + last value last / 2
				         - (first value first + first value last / 2)
				         / (last key - first key) ].
	^ first value first + first value last / 2
	  + (anIndex - first key * pitch)
]

{ #category : 'geometry' }
DdGridResizeGeometry class >> firstIndexAfter: anEdge upTo: anEndIndex ranges: ranges [
"The first column, going back from anEndIndex (never below 1), whose centre lies after anEdge."

	| index |
	index := anEndIndex.
	[
	index > 1 and: [ (self center: index - 1 ranges: ranges) > anEdge ] ]
		whileTrue: [ index := index - 1 ].
	^ index
]

{ #category : 'geometry' }
DdGridResizeGeometry class >> lastIndexBefore: anEdge from: aStartIndex ranges: ranges [
"The last column, starting from aStartIndex, whose centre lies before anEdge."

	| index |
	index := aStartIndex.
	[
		index < (aStartIndex + 50) and: [
			(self center: index + 1 ranges: ranges) < anEdge ] ] whileTrue: [
		index := index + 1 ].
	^ index
]
