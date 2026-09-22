Class {
	#name : 'DdInteractionOverlayMorph',
	#superclass : 'Morph',
	#instVars : [
		'canvasMap',
		'dragThreshold',
		'state',
		'pressPoint',
		'draggedPath',
		'currentTarget',
		'onSelect',
		'onDrop',
		'targetTopMorph'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdInteractionOverlayMorph class >> canvasMap: aMap top: aTopMorph [
"Creates an overlay covering aTopMorph's bounds, hit-testing through aMap."

	^ self new
		  canvasMap: aMap;
		  targetTopMorph: aTopMorph;
		  yourself
]

{ #category : 'accessing' }
DdInteractionOverlayMorph >> canvasMap: aMap [
	canvasMap := aMap
]

{ #category : 'drawing' }
DdInteractionOverlayMorph >> drawOn: aCanvas [
"The drop indicator is drawn in world coordinates by DdDropGeometry; translate into
my own coordinate system before drawing."

	| rect |
	state = #dragging ifFalse: [ ^ self ].
	currentTarget ifNil: [ ^ self ].
	rect := currentTarget indicator.
	rect ifNil: [ ^ self ].
	aCanvas
		frameAndFillRectangle:
		(rect translatedBy: self bounds origin negated)
		fillColor: (Color blue alpha: 0.25)
		borderWidth: 1
		borderColor: Color blue
]

{ #category : 'event handling' }
DdInteractionOverlayMorph >> handlesMouseDown: anEvent [
	^ true
]

{ #category : 'event handling' }
DdInteractionOverlayMorph >> handlesMouseOver: anEvent [
"Never let hover/click reach the live widgets underneath: clicking a button in the
preview must select it, not press it."

	^ false
]

{ #category : 'initialization' }
DdInteractionOverlayMorph >> initialize [
	super initialize.
	self
		color: Color transparent;
		borderWidth: 0.
	dragThreshold := 4.
	state := #idle
]

{ #category : 'event handling' }
DdInteractionOverlayMorph >> mouseDown: anEvent [
	pressPoint := anEvent position.
	draggedPath := canvasMap nodeAtPoint: pressPoint.
	state := #pressed
]

{ #category : 'event handling' }
DdInteractionOverlayMorph >> mouseMove: anEvent [

	state = #idle ifTrue: [ ^ self ].
	draggedPath ifNil: [ ^ self ].
	(state = #pressed and: [
		 (anEvent position dist: pressPoint) > dragThreshold ]) ifTrue: [
		state := #dragging ].
	state = #dragging ifFalse: [ ^ self ].
	currentTarget := canvasMap
		                 dropTargetAt: anEvent position
		                 dragging: draggedPath.
	self changed
]

{ #category : 'event handling' }
DdInteractionOverlayMorph >> mouseUp: anEvent [
	state = #dragging
		ifTrue: [
				(currentTarget notNil and: [ currentTarget isNoOp not ]) ifTrue: [
					onDrop ifNotNil: [ :b |
						b value: draggedPath value: currentTarget ] ] ]
		ifFalse: [
				draggedPath ifNotNil: [
					onSelect ifNotNil: [ :b | b value: draggedPath ] ] ].
	state := #idle.
	draggedPath := nil.
	currentTarget := nil.
	self changed
]

{ #category : 'accessing' }
DdInteractionOverlayMorph >> onDrop: aBlock [
"aBlock is evaluated with (sourcePath, aDdDropTarget) when a real (non no-op) drop completes."

	onDrop := aBlock
]

{ #category : 'accessing' }
DdInteractionOverlayMorph >> onSelect: aBlock [
"aBlock is evaluated with the model path (an Array) when a plain click (no drag) lands on a node."

	onSelect := aBlock
]

{ #category : 'stepping and presenter' }
DdInteractionOverlayMorph >> step [
	self syncBounds
]

{ #category : 'stepping and presenter' }
DdInteractionOverlayMorph >> stepTime [
	^ 200
]

{ #category : 'geometry' }
DdInteractionOverlayMorph >> syncBounds [
"Cover exactly the area canvasMap was built over."

	targetTopMorph ifNil: [ ^ self ].
	self bounds = targetTopMorph boundsInWorld ifFalse: [
		self bounds: targetTopMorph boundsInWorld ]
]

{ #category : 'accessing' }
DdInteractionOverlayMorph >> targetTopMorph: aMorph [
	targetTopMorph := aMorph
]

{ #category : 'stepping and presenter' }
DdInteractionOverlayMorph >> wantsSteps [
	^ true
]
