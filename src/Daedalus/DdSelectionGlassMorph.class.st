Class {
	#name : 'DdSelectionGlassMorph',
	#superclass : 'Morph',
	#instVars : [
		'targetMorph',
		'lastRectangle',
		'targetProvider',
		'idleSteps'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'events' }
DdSelectionGlassMorph >> containsPoint: arg1 [

	^ false
]

{ #category : 'events' }
DdSelectionGlassMorph >> containsPoint: arg1 event: arg2 [

	^ false
]

{ #category : 'private' }
DdSelectionGlassMorph >> currentTargetFromProvider [
	^ [ targetProvider ifNotNil: [ :provider | provider value ] ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'drawing' }
DdSelectionGlassMorph >> drawOn: arg1 [

	| tmp1 tmp2 |
	tmp2 := self frameRectangle.
	tmp2 ifNil: [ ^ self ].
	tmp1 := tmp2.
	arg1 frameRectangle: tmp1 width: 2 color: self frameColor
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> frameColor [

	^ Color r: 0.15 g: 0.5 b: 0.95
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> frameRectangle [
"Where to draw the frame, in world coordinates, or nil."

	self hasLiveTarget ifFalse: [ ^ nil ].
	^ targetMorph boundsInWorld
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> hasLiveTarget [
	"A rebuilt preview leaves the old morph without a world: then there is nothing to frame."

	^ targetMorph notNil and: [ targetMorph world notNil ]
]

{ #category : 'visibility' }
DdSelectionGlassMorph >> hideGlass [
	self visible ifTrue: [ self visible: false ]
]

{ #category : 'initialization' }
DdSelectionGlassMorph >> initialize [
	super initialize.
	self
		color: Color transparent;
		borderWidth: 0.
	idleSteps := 0
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> isFrontWindow: aTopMorph [
	"Only the frontmost window gets the frame: it must not show through other windows."

	| front |
	aTopMorph isSystemWindow ifFalse: [ ^ true ].
	front := aTopMorph owner submorphs
		         detect: [ :each | each isSystemWindow ]
		         ifNone: [ nil ].
	^ front == aTopMorph
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> keepAbove: aTopMorph [
	"Activating a window brings it in front of the glass: put the glass back on top."

	| siblings |
	(owner notNil and: [ aTopMorph notNil ]) ifFalse: [ ^ self ].
	siblings := owner submorphs.
	((siblings includes: aTopMorph) and: [
		 (siblings indexOf: self) > (siblings indexOf: aTopMorph) ])
		ifTrue: [ owner addMorphFront: self ]
]

{ #category : 'visibility' }
DdSelectionGlassMorph >> showGlass [
	self visible ifFalse: [ self visible: true ]
]

{ #category : 'actions' }
DdSelectionGlassMorph >> showIn: aWorld [
	"Puts the glass into the world (like a halo, not into a Spec layout) and syncs it with its target."

	aWorld ifNil: [ ^ self ].
	owner == aWorld ifFalse: [ aWorld addMorphFront: self ].
	self syncWithTarget
]

{ #category : 'stepping' }
DdSelectionGlassMorph >> step [	"A stepping morph must never throw: it would fail again on every step and freeze the image."

	[ self syncWithTarget ]
		on: Error
		do: [ :error |
				Transcript
					show: 'DdSelectionGlassMorph stopped: ' , error description;
					cr.
				targetProvider := nil.
				targetMorph := nil.
				self hideGlass ]
]

{ #category : 'stepping' }
DdSelectionGlassMorph >> stepTime [

	^ 100
]

{ #category : 'stepping' }
DdSelectionGlassMorph >> syncWithTarget [

	| topMorph rectangle |
	targetMorph := self currentTargetFromProvider.
	self hasLiveTarget ifFalse: [
			idleSteps := idleSteps + 1.
			self hideGlass.
			idleSteps > 50 ifTrue: [ self delete ].
			^ self ].
	idleSteps := 0.
	topMorph := self topMorphOf: targetMorph.
	(self isFrontWindow: topMorph) ifFalse: [ ^ self hideGlass ].
	self showGlass.
	self bounds = topMorph bounds ifFalse: [
		self bounds: topMorph bounds ].
	self keepAbove: topMorph.
	rectangle := self frameRectangle.
	rectangle = lastRectangle ifTrue: [ ^ self ].
	lastRectangle := rectangle.
	self changed
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetMorph [
	^ targetMorph
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetMorph: aMorphOrNil [
	"Frames a fixed morph (nil frames nothing)."

	self targetProvider: [ aMorphOrNil ]
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetProvider: aBlock [
	"aBlock is evaluated at every step and answers the morph to frame, or nil.
	This way the frame follows the selection even when the preview is rebuilt."

	targetProvider := aBlock.
	targetMorph := self currentTargetFromProvider.
	lastRectangle := nil.
	self changed
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> topMorphOf: aMorph [
"The morph directly under the world that contains aMorph: for the designer, its window."

	| current |
	current := aMorph.
	[ current owner notNil and: [ current owner isWorldMorph not ] ]
		whileTrue: [ current := current owner ].
	^ current
]

{ #category : 'stepping and presenter' }
DdSelectionGlassMorph >> wantsSteps [

	^ true
]
