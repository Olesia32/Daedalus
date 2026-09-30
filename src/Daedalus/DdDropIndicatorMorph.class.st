Class {
	#name : 'DdDropIndicatorMorph',
	#superclass : 'Morph',
	#instVars : [
		'indicatorRect'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry testing' }
DdDropIndicatorMorph >> containsPoint: aPoint [
	"A ghost: it never takes part in hit testing, events reach the widgets under it."

	^ false
]

{ #category : 'events - processing' }
DdDropIndicatorMorph >> containsPoint: aPoint event: anEvent [
	^ false
]

{ #category : 'drawing' }
DdDropIndicatorMorph >> drawLine: aRectangle on: aCanvas [
"3px line through the middle of aRectangle, with a round cap at each end."

	| color center line ends |
	color := DdDesignerTheme selection.
	center := aRectangle center.
	aRectangle width >= aRectangle height
		ifTrue: [
				line := aRectangle left @ (center y - 1) corner:
					        aRectangle right @ (center y + 2).
				ends := {
					        (aRectangle left @ center y).
					        (aRectangle right @ center y) } ]
		ifFalse: [
				line := center x - 1 @ aRectangle top corner:
					        center x + 2 @ aRectangle bottom.
				ends := {
					        (center x @ aRectangle top).
					        (center x @ aRectangle bottom) } ].
	aCanvas fillRectangle: line color: color.
	ends do: [ :each |
		aCanvas fillOval: (each - 4 extent: 9 @ 9) color: color ]
]

{ #category : 'drawing' }
DdDropIndicatorMorph >> drawOn: aCanvas [
"An insertion point between siblings is a line; an empty container, a grid cell or an absolute
position is a tinted area with a crisp edge."

	indicatorRect ifNil: [ ^ self ].
	(self isLine: indicatorRect) ifTrue: [
		^ self drawLine: indicatorRect on: aCanvas ].
	aCanvas
		fillRectangle: indicatorRect
		color: DdDesignerTheme selectionSoft.
	aCanvas
		frameRectangle: indicatorRect
		width: 2
		color: DdDesignerTheme selection
]

{ #category : 'actions' }
DdDropIndicatorMorph >> hideIndicator [
	self visible ifTrue: [ self visible: false ]
]

{ #category : 'initialization' }
DdDropIndicatorMorph >> initialize [

	super initialize.
	self color: Color transparent.
	self visible: false
]

{ #category : 'testing' }
DdDropIndicatorMorph >> isLine: aRectangle [

	^ (aRectangle width min: aRectangle height) <= 4
]

{ #category : 'actions' }
DdDropIndicatorMorph >> showAt: aRectangle [
"aRectangle is what the drop geometry computed. A thin insertion line gets a few extra pixels of
morph around it, so the round caps are not clipped."

	indicatorRect := aRectangle.
	self bounds: ((self isLine: aRectangle)
			 ifTrue: [ aRectangle expandBy: 5 ]
			 ifFalse: [ aRectangle ]).
	self changed.
	self visible ifFalse: [ self visible: true ]
]
