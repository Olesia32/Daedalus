Class {
	#name : 'DdInputShieldMorph',
	#superclass : 'Morph',
	#instVars : [
		'canvas'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdInputShieldMorph >> canvas: aCanvasPresenter [
	canvas := aCanvasPresenter
]

{ #category : 'event handling' }
DdInputShieldMorph >> handlesMouseDown: anEvent [
"Claims every mouseDown over its bounds - unlike the selection glass and drop indicator, this
morph is deliberately NOT transparent to hit-testing: that is the whole point of it."

	^ true
]

{ #category : 'event handling' }
DdInputShieldMorph >> handlesMouseWheel: anEvent [
	^ true
]

{ #category : 'geometry' }
DdInputShieldMorph >> hasLiveTarget [

	| target |
	target := self targetMorph.
	^ target notNil and: [ target world notNil ]
]

{ #category : 'visibility' }
DdInputShieldMorph >> hideShield [

	self visible ifTrue: [ self visible: false ]
]

{ #category : 'initialization' }
DdInputShieldMorph >> initialize [

	super initialize.
	self color: Color transparent
]

{ #category : 'geometry' }
DdInputShieldMorph >> isFrontWindow: aTopMorph [
"Only the frontmost window gets shielded: it must not swallow clicks meant for other windows."

	| front |
	aTopMorph isSystemWindow ifFalse: [ ^ true ].
	front := aTopMorph owner submorphs
		         detect: [ :each | each isSystemWindow ]
		         ifNone: [ nil ].
	^ front == aTopMorph
]

{ #category : 'geometry' }
DdInputShieldMorph >> keepAbove: aTopMorph [
"Activating a window brings it in front of the shield; put the shield back on top."

	| siblings |
	(owner notNil and: [ aTopMorph notNil ]) ifFalse: [ ^ self ].
	siblings := owner submorphs.
	((siblings includes: aTopMorph) and: [
		 (siblings indexOf: self) > (siblings indexOf: aTopMorph) ])
		ifTrue: [ owner addMorphFront: self ]
]

{ #category : 'event handling' }
DdInputShieldMorph >> mouseDown: anEvent [

	[ canvas ifNotNil: [ :aCanvas | aCanvas shieldMouseDown: anEvent ] ]
		on: Error
		do: [ :error |  ]
]

{ #category : 'event handling' }
DdInputShieldMorph >> mouseWheel: anEvent [
	"The shield lies over the preview, so the wheel reaches it rather than the scroll pane under
	it: pass it on to the nearest scroll pane around the preview."
	| current |
	current := self targetMorph.
	[ current notNil ] whileTrue: [
		(current isKindOf: GeneralScrollPaneMorph) ifTrue: [ ^ current mouseWheel: anEvent ].
		current := current owner ]
]

{ #category : 'geometry' }
DdInputShieldMorph >> shieldRectangle [
	"The visible part of the preview only: over the scroll bars or a scrolled-away part the shield
	must not swallow clicks. nil when nothing of the preview is visible."
	| bounds clip |
	bounds := self targetMorph boundsInWorld.
	clip := DdCanvasMap clipRectangleOf: self targetMorph.
	clip ifNil: [ ^ bounds ].
	^ bounds intersect: clip ifNone: [ nil ]
]

{ #category : 'visibility' }
DdInputShieldMorph >> showShield [

	self visible ifFalse: [ self visible: true ]
]

{ #category : 'stepping and presenter' }
DdInputShieldMorph >> step [
"A stepping morph must never throw: it would fail again on every step and freeze the image."

	[ self syncWithCanvas ]
		on: Error
		do: [ :error | self hideShield ]
]

{ #category : 'stepping and presenter' }
DdInputShieldMorph >> stepTime [

	^ 100
]

{ #category : 'private' }
DdInputShieldMorph >> syncWithCanvas [
	| topMorph target |
	self hasLiveTarget ifFalse: [ ^ self hideShield ].
	topMorph := self topMorphOf: self targetMorph.
	(self isFrontWindow: topMorph) ifFalse: [ ^ self hideShield ].
	target := self shieldRectangle.
	(target isNil or: [ target hasPositiveExtent not ]) ifTrue: [ ^ self hideShield ].
	owner ifNil: [ topMorph world ifNotNil: [ :w | w addMorphFront: self ] ].
	self showShield.
	self bounds = target ifFalse: [ self bounds: target ].
	self keepAbove: topMorph
]

{ #category : 'geometry' }
DdInputShieldMorph >> targetMorph [

	^ canvas
		  ifNil: [ nil ]
		  ifNotNil: [ :aCanvas | aCanvas previewContainerMorph ]
]

{ #category : 'geometry' }
DdInputShieldMorph >> topMorphOf: aMorph [
"The morph directly under the world that contains aMorph: for the designer, its window."

	| current |
	current := aMorph.
	[ current owner notNil and: [ current owner isWorldMorph not ] ]
		whileTrue: [ current := current owner ].
	^ current
]

{ #category : 'stepping and presenter' }
DdInputShieldMorph >> wantsSteps [

	^ true
]
