Class {
	#name : 'DdCanvasSurfaceMorph',
	#superclass : 'Morph',
	#instVars : [
		'previewProvider',
		'extentProvider'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'colors' }
DdCanvasSurfaceMorph >> backgroundColor [

	^ Color r: 0.60 g: 0.66 b: 0.74
]

{ #category : 'private' }
DdCanvasSurfaceMorph >> currentPreview [

	^ [ previewProvider ifNotNil: [ :provider | provider value ] ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'drawing' }
DdCanvasSurfaceMorph >> drawGridOn: aCanvas anchoredAt: anOrigin [
"Lines are counted from the form's top-left corner, so the grid matches the form's own pixel
coordinates (useful later for an absolute layout and snapping)."

	| r step x y |
	r := self bounds.
	step := self minorStep.
	x := anOrigin x - (anOrigin x - r left // step * step).
	[ x <= r right ] whileTrue: [
			aCanvas
				fillRectangle: (x @ r top extent: 1 @ r height)
				color: (self isMajorOffset: x - anOrigin x).
			x := x + step ].
	y := anOrigin y - (anOrigin y - r top // step * step).
	[ y <= r bottom ] whileTrue: [
			aCanvas
				fillRectangle: (r left @ y extent: r width @ 1)
				color: (self isMajorOffset: y - anOrigin y).
			y := y + step ]
]

{ #category : 'drawing' }
DdCanvasSurfaceMorph >> drawOn: aCanvas [
"Background, grid, shadow, frame, then the sheet itself; the preview is drawn on top of the
sheet as a submorph, inset by sheetPadding."

	| formRect |
	aCanvas fillRectangle: self bounds color: self backgroundColor.
	formRect := self formBounds.
	self drawGridOn: aCanvas anchoredAt: self previewBounds origin.
	aCanvas
		fillRectangle: (formRect translateBy: 3 @ 4)
		color: (Color black alpha: 0.18).
	aCanvas
		fillRectangle: (formRect expandBy: 1)
		color: (Color black alpha: 0.4).
	aCanvas fillRectangle: formRect color: self sheetColor
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> extent: aPoint [

	super extent: aPoint.
	[ self syncPreview ]
		on: Error
		do: [ :error |  ]
]

{ #category : 'accessing' }
DdCanvasSurfaceMorph >> extentProvider: aBlock [
"aBlock answers the size the form should be shown at."

	extentProvider := aBlock
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> formBounds [
"The form keeps its own size and lies centered on the surface; it only shrinks when the surface
is too small to hold it with the margin around."

	| available extent |
	available := self bounds insetBy: self margin.
	extent := (self formExtent min: available extent) max: 50 @ 50.
	^ Rectangle center: available center extent: extent
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> formExtent [

	^ ([ extentProvider ifNotNil: [ :provider | provider value ] ]
		   on: Error
		   do: [ nil ]) ifNil: [ 480 @ 360 ]
]

{ #category : 'initialization' }
DdCanvasSurfaceMorph >> initialize [

	super initialize.
	self
		color: self backgroundColor;
		borderWidth: 0;
		clipSubmorphs: true
]

{ #category : 'drawing' }
DdCanvasSurfaceMorph >> isMajorOffset: anOffset [
"Answers the line color for a line anOffset pixels away from the form's origin."

	^ anOffset // self minorStep \\ self majorEvery = 0
		  ifTrue: [ self majorLineColor ]
		  ifFalse: [ self minorLineColor ]
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> majorEvery [
"Every how many thin lines a stronger one is drawn (here: every 50 px)."

	^ 5
]

{ #category : 'colors' }
DdCanvasSurfaceMorph >> majorLineColor [

	^ Color r: 0.72 g: 0.78 b: 0.86
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> margin [
"Minimum strip of surface kept visible around the form."

	^ 24
]

{ #category : 'colors' }
DdCanvasSurfaceMorph >> minorLineColor [

	^ Color r: 0.65 g: 0.71 b: 0.79
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> minorStep [
"Pixels between two thin lines."

	^ 10
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> previewBounds [
"Where the preview morph itself goes: the sheet minus its padding."

	^ self formBounds insetBy: self sheetPadding
]

{ #category : 'accessing' }
DdCanvasSurfaceMorph >> previewProvider: aBlock [
"aBlock answers the current top morph of the preview (it is replaced on every rebuild)."

	previewProvider := aBlock
]

{ #category : 'colors' }
DdCanvasSurfaceMorph >> sheetColor [
"The preview's own color when it has one, otherwise the color of the first opaque morph above
the surface (the window pane) - what a transparent form is really shown on."

	| preview current |
	preview := self currentPreview.
	(preview notNil and: [ preview color isTransparent not ]) ifTrue: [
		^ preview color ].
	current := owner.
	[ current notNil ] whileTrue: [
			(current color isColor and: [ current color isTransparent not ])
				ifTrue: [ ^ current color ].
			current := current owner ].
	^ Smalltalk ui theme backgroundColor
]

{ #category : 'geometry' }
DdCanvasSurfaceMorph >> sheetPadding [
"Inner margin of the sheet, like the inset of a real window's content."

	^ 8
]

{ #category : 'stepping and presenter' }
DdCanvasSurfaceMorph >> step [
"A stepping morph must never throw: it would fail again on every step and freeze the image."

	[ self syncPreview ]
		on: Error
		do: [ :error |  ]
]

{ #category : 'stepping and presenter' }
DdCanvasSurfaceMorph >> stepTime [

	^ 100
]

{ #category : 'layout' }
DdCanvasSurfaceMorph >> syncPreview [

	| preview target |
	preview := self currentPreview.
	self submorphs copy do: [ :each |
		each == preview ifFalse: [ each delete ] ].
	preview ifNil: [ ^ self ].
	preview owner == self ifFalse: [ self addMorph: preview ].
	target := self previewBounds.
	preview bounds = target ifTrue: [ ^ self ].
	preview bounds: target.
	self changed
]

{ #category : 'stepping and presenter' }
DdCanvasSurfaceMorph >> wantsSteps [

	^ true
]
