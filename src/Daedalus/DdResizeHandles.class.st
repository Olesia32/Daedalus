Class {
	#name : 'DdResizeHandles',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'constants' }
DdResizeHandles class >> allHandleNames [

	^ #( #topLeft #top #topRight #left #right #bottomLeft #bottom #bottomRight )
]

{ #category : 'geometry' }
DdResizeHandles class >> centerOf: aName in: aRectangle [

	| x y |
	x := (#( #topLeft #left #bottomLeft ) includes: aName)
		     ifTrue: [ aRectangle left ]
		     ifFalse: [
				     (#( #topRight #right #bottomRight ) includes: aName)
					     ifTrue: [ aRectangle right ]
					     ifFalse: [ aRectangle center x ] ].
	y := (#( #topLeft #top #topRight ) includes: aName)
		     ifTrue: [ aRectangle top ]
		     ifFalse: [
				     (#( #bottomLeft #bottom #bottomRight ) includes: aName)
					     ifTrue: [ aRectangle bottom ]
					     ifFalse: [ aRectangle center y ] ].
	(self allHandleNames includes: aName) ifFalse: [
		^ self error: 'Unknown resize handle: ' , aName printString ].
	^ x @ y
]

{ #category : 'geometry' }
DdResizeHandles class >> handleAt: aPoint for: aRectangle names: aCollection [
	"The name of the handle under aPoint, or nil."

	(self rectanglesFor: aRectangle names: aCollection) keysAndValuesDo: [
			:name
			:square |
			((square expandBy: self hitMargin) containsPoint: aPoint) ifTrue: [
				^ name ] ].
	^ nil
]

{ #category : 'constants' }
DdResizeHandles class >> handleSize [

	^ 7
]

{ #category : 'constants' }
DdResizeHandles class >> hitMargin [
"Extra pixels around a handle that still count as grabbing it - a 7px square is hard to hit."

	^ 2
]

{ #category : 'geometry' }
DdResizeHandles class >> rectanglesFor: aRectangle names: aCollection [
"Handle name -> the small square drawn for it, centred on the edge or corner it moves."

	| half result |
	half := self handleSize // 2.
	result := Dictionary new.
	aCollection do: [ :each |
			| center |
			center := self centerOf: each in: aRectangle.
			result
				at: each
				put: (center - half corner: center - half + self handleSize) ].
	^ result
]

{ #category : 'geometry' }
DdResizeHandles class >> resized: aRectangle handle: aName by: aDelta minExtent: aMinExtent [
"The rectangle after dragging handle aName by aDelta: each edge the handle touches follows the
mouse, the opposite edges stay put, and the result is never smaller than aMinExtent."

	| left top right bottom |
	left := aRectangle left.
	top := aRectangle top.
	right := aRectangle right.
	bottom := aRectangle bottom.
	(#( #topLeft #left #bottomLeft ) includes: aName) ifTrue: [
		left := aRectangle left + aDelta x min: right - aMinExtent x ].
	(#( #topRight #right #bottomRight ) includes: aName) ifTrue: [
		right := aRectangle right + aDelta x max: left + aMinExtent x ].
	(#( #topLeft #top #topRight ) includes: aName) ifTrue: [
		top := aRectangle top + aDelta y min: bottom - aMinExtent y ].
	(#( #bottomLeft #bottom #bottomRight ) includes: aName) ifTrue: [
		bottom := aRectangle bottom + aDelta y max: top + aMinExtent y ].
	^ left @ top corner: right @ bottom
]
