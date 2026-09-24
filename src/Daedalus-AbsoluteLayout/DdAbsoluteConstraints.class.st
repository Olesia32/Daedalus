"
I am the constraints of a child placed in a DdAbsoluteLayout. position is the top-left corner of the child in pixels, relative to the top-left corner of the layout. extent is the size of the child in pixels; when it is nil the child keeps its natural extent.
"
Class {
	#name : 'DdAbsoluteConstraints',
	#superclass : 'SpLayoutConstraints',
	#instVars : [
		'position',
		'extent'
	],
	#category : 'Daedalus-AbsoluteLayout',
	#package : 'Daedalus-AbsoluteLayout'
}

{ #category : 'instance creation' }
DdAbsoluteConstraints class >> atPoint: aPoint [
	^ self new
		  position: aPoint;
		  yourself
]

{ #category : 'instance creation' }
DdAbsoluteConstraints class >> atPoint: aPoint extent: anExtent [
	^ self new
		  position: aPoint;
		  extent: anExtent;
		  yourself
]

{ #category : 'instance creation' }
DdAbsoluteConstraints class >> bounds: aRectangle [
	^ self new
		  bounds: aRectangle;
		  yourself
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> bottom [
	^ extent ifNotNil: [ :anExtent | position y + anExtent y ]
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> bounds [
"The rectangle occupied by the child, or nil when the child keeps its natural extent."

	^ extent ifNotNil: [ :anExtent | position extent: anExtent ]
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> bounds: aRectangle [
	self position: aRectangle origin.
	self extent: aRectangle extent
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> extent [
"Size of the child in pixels. Answers nil when the child keeps its natural extent."

	^ extent
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> extent: aPointOrNil [
"Set the size of the child in pixels. Use nil to let the child keep its natural extent."

	| newExtent |
	aPointOrNil ifNil: [
			extent := nil.
			^ self ].
	newExtent := aPointOrNil asPoint.
	(newExtent x < 0 or: [ newExtent y < 0 ]) ifTrue: [
		^ self error: 'The extent of a child cannot be negative' ].
	extent := newExtent
]

{ #category : 'testing' }
DdAbsoluteConstraints >> hasExtent [
"Answer whether the extent was set explicitly (otherwise the child keeps its natural extent)."

	^ extent isNotNil
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> height [

	^ extent ifNotNil: [ :anExtent | anExtent y ]
]

{ #category : 'initialization' }
DdAbsoluteConstraints >> initialize [
	super initialize.
	position := 0 @ 0
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> left [
	^ position x
]

{ #category : 'moving' }
DdAbsoluteConstraints >> moveBy: aPoint [
	position := position + aPoint asPoint
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> position [
"Top-left corner of the child, in pixels, relative to the top-left corner of the layout."

	^ position
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> position: aPoint [
	position := aPoint asPoint
]

{ #category : 'printing' }
DdAbsoluteConstraints >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		print: position;
		nextPutAll: ' extent: ';
		print: extent;
		nextPut: $)
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> right [
	^ extent ifNotNil: [ :anExtent | position x + anExtent x ]
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> top [
	^ position y
]

{ #category : 'accessing' }
DdAbsoluteConstraints >> width [
	^ extent ifNotNil: [ :anExtent | anExtent x ]
]
