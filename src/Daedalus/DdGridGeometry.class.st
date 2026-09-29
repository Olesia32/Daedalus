Class {
	#name : 'DdGridGeometry',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry' }
DdGridGeometry class >> cellAt: aPoint entries: entries in: aContainerRectangle [

	| columns rows strip left right top bottom |
	entries isEmpty ifTrue: [
			^ {
				  (1 @ 1).
				  (aContainerRectangle insetBy: 3) } ].
	columns := self
		           lookup: aPoint x
		           in: (self rangesFor: entries horizontal: true).
	rows := self
		        lookup: aPoint y
		        in: (self rangesFor: entries horizontal: false).
	strip := self edgeStrip.
	left := columns fourth
		        ifTrue: [ aContainerRectangle right - strip ]
		        ifFalse: [
		        columns second ifNil: [ aContainerRectangle left ] ].
	right := columns fourth
		         ifTrue: [ aContainerRectangle right ]
		         ifFalse: [
		         columns third ifNil: [ aContainerRectangle right ] ].
	top := rows fourth
		       ifTrue: [ aContainerRectangle bottom - strip ]
		       ifFalse: [ rows second ifNil: [ aContainerRectangle top ] ].
	bottom := rows fourth
		          ifTrue: [ aContainerRectangle bottom ]
		          ifFalse: [
		          rows third ifNil: [ aContainerRectangle bottom ] ].
	^ {
		  (columns first @ rows first).
		  (left @ top corner: right @ bottom) }
]

{ #category : 'constants' }
DdGridGeometry class >> edgeStrip [
"Thickness of the strip highlighted for a new column/row."

	^ 6
]

{ #category : 'constants' }
DdGridGeometry class >> edgeZone [
"Pixels at the far edge of the last column/row that mean 'a new column/row after this one'."

	^ 14
]

{ #category : 'geometry' }
DdGridGeometry class >> entryCovering: aCell in: entries [
"The entry that occupies aCell, spans included, or nil."

	^ entries
		  detect: [ :each |
				  | position span |
				  position := each first.
				  span := each second.
				  (aCell x between: position x and: position x + span x - 1) and: [
					  aCell y between: position y and: position y + span y - 1 ] ]
		  ifNone: [ nil ]
]

{ #category : 'private' }
DdGridGeometry class >> lookup: aCoordinate in: ranges [

	| last zone |
	ranges isEmpty ifTrue: [ ^ { 1. nil. nil. false } ].
	last := ranges last.
	zone := last value last - last value first // 4 min: self edgeZone.
	aCoordinate >= (last value last - zone) ifTrue: [
			^ {
				  (last key + 1).
				  nil.
				  nil.
				  true } ].
	aCoordinate < ranges first value first ifTrue: [
			^ {
				  (ranges first key - 1 max: 1).
				  nil.
				  nil.
				  false } ].
	1 to: ranges size do: [ :i |
			| each |
			each := ranges at: i.
			(aCoordinate between: each value first and: each value last)
				ifTrue: [
						^ {
							  each key.
							  each value first.
							  each value last.
							  false } ].
			i < ranges size ifTrue: [
					| next |
					next := ranges at: i + 1.
					(aCoordinate > each value last and: [
						 aCoordinate < next value first ]) ifTrue: [
						^ self numberInGapFrom: each to: next at: aCoordinate ] ] ].
	^ self nearestRangeTo: aCoordinate in: ranges
]

{ #category : 'private' }
DdGridGeometry class >> nearestRangeTo: aCoordinate in: ranges [

	| nearest bestDistance |
	nearest := nil.
	bestDistance := nil.
	ranges do: [ :each |
			| distance |
			distance := (aCoordinate - (each value first + each value last / 2))
				            abs.
			(bestDistance isNil or: [ distance < bestDistance ]) ifTrue: [
					nearest := each.
					bestDistance := distance ] ].
	^ {
		  nearest key.
		  nearest value first.
		  nearest value last.
		  false }
]

{ #category : 'private' }
DdGridGeometry class >> numberInGapFrom: lowEntry to: highEntry at: aCoordinate [

	| missing low high slotWidth index slotLow slotHigh |
	missing := highEntry key - lowEntry key - 1.
	missing <= 0 ifTrue: [
			^ {
				  highEntry key.
				  highEntry value first.
				  highEntry value last.
				  false } ].
	low := lowEntry value last.
	high := highEntry value first.
	slotWidth := high - low / missing.
	index := (aCoordinate - low / slotWidth) truncated + 1.
	index := (index max: 1) min: missing.
	slotLow := low + (index - 1 * slotWidth).
	slotHigh := low + (index * slotWidth).
	^ {
		  (lowEntry key + index).
		  slotLow rounded.
		  slotHigh rounded.
		  false }
]

{ #category : 'private' }
DdGridGeometry class >> rangesFor: entries horizontal: aBoolean [
"Column (or row) number -> { low. high } extent, taken from the entries that span exactly one of them."

	| ranges |
	ranges := Dictionary new.
	entries do: [ :each |
			| position span rectangle key low high current |
			position := each first.
			span := each second.
			rectangle := each third.
			(aBoolean
				 ifTrue: [ span x ]
				 ifFalse: [ span y ]) = 1 ifTrue: [
					key := aBoolean
						       ifTrue: [ position x ]
						       ifFalse: [ position y ].
					low := aBoolean
						       ifTrue: [ rectangle left ]
						       ifFalse: [ rectangle top ].
					high := aBoolean
						        ifTrue: [ rectangle right ]
						        ifFalse: [ rectangle bottom ].
					current := ranges at: key ifAbsent: [ nil ].
					ranges at: key put: (current
							 ifNil: [
									 {
										 low.
										 high } ]
							 ifNotNil: [
									 {
										 (current first min: low).
										 (current last max: high) } ]) ] ].
	^ (ranges associations asSortedCollection: [ :a :b | a key <= b key ])
		  asArray
]
