Class {
	#name : 'DdSelectionGlassMorph',
	#superclass : 'Morph',
	#instVars : [
		'targetMorph',
		'lastRectangle',
		'targetProvider',
		'idleSteps',
		'handlesProvider'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry testing' }
DdSelectionGlassMorph >> containsPoint: arg1 [

	^ false
]

{ #category : 'events - processing' }
DdSelectionGlassMorph >> containsPoint: arg1 event: arg2 [

	^ false
]

{ #category : 'private' }
DdSelectionGlassMorph >> currentHandleNames [

	^ [
		  handlesProvider
			  ifNil: [ #(  ) ]
			  ifNotNil: [ :provider | provider value ifNil: [ #(  ) ] ] ]
		  on: Error
		  do: [ #(  ) ]
]

{ #category : 'private' }
DdSelectionGlassMorph >> currentTargetFromProvider [

	^ [
		  | tmp1 tmp3 |
		  tmp3 := tmp1 := targetProvider.
		  tmp3 ifNotNil: [ tmp1 value ] ]
		  on: Error
		  do: [ ]
]

{ #category : 'drawing' }
DdSelectionGlassMorph >> drawOn: aCanvas [

	| rectangle |
	rectangle := self frameRectangle.
	rectangle ifNil: [ ^ self ].
	aCanvas frameRectangle: rectangle width: 1 color: self frameColor.
	(DdResizeHandles
		 rectanglesFor: rectangle
		 names: self currentHandleNames) do: [ :square |
			aCanvas fillRectangle: square color: Color white.
			aCanvas frameRectangle: square width: 1 color: self frameColor ]
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> frameColor [

	^ DdDesignerTheme selection
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> frameRectangle [

	self hasLiveTarget ifFalse: [ ^ nil ].
	^ targetMorph boundsInWorld
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> handlesProvider: aBlock [
"aBlock answers the names of the resize handles to draw on the frame (see DdResizeHandles)."

	handlesProvider := aBlock.
	self changed
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> hasLiveTarget [

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
DdSelectionGlassMorph >> isFrontWindow: arg1 [

	| tmp1 |
	arg1 isSystemWindow ifFalse: [ ^ true ].
	tmp1 := arg1 owner submorphs
		        detect: [ :arg2 | arg2 isSystemWindow ]
		        ifNone: [ ].
	^ tmp1 == arg1
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> keepAbove: arg1 [

	| tmp1 |
	(owner notNil and: [ arg1 notNil ]) ifFalse: [ ^ self ].
	tmp1 := owner submorphs.
	((tmp1 includes: arg1) and: [
		 (tmp1 indexOf: self) > (tmp1 indexOf: arg1) ]) ifTrue: [
		owner addMorphFront: self ]
]

{ #category : 'visibility' }
DdSelectionGlassMorph >> showGlass [

	self visible ifFalse: [ self visible: true ]
]

{ #category : 'actions' }
DdSelectionGlassMorph >> showIn: arg1 [

	arg1 ifNil: [ ^ self ] ifNotNil: [ arg1 ].
	owner == arg1 ifFalse: [ arg1 addMorphFront: self ].
	self syncWithTarget
]

{ #category : 'stepping and presenter' }
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

{ #category : 'stepping and presenter' }
DdSelectionGlassMorph >> stepTime [

	^ 100
]

{ #category : 'stepping' }
DdSelectionGlassMorph >> syncWithTarget [

	| tmp1 tmp2 |
	targetMorph := self currentTargetFromProvider.
	self hasLiveTarget ifFalse: [
			idleSteps := idleSteps + 1.
			self hideGlass.
			idleSteps > 50 ifTrue: [ self delete ].
			^ self ].
	idleSteps := 0.
	tmp1 := self topMorphOf: targetMorph.
	(self isFrontWindow: tmp1) ifFalse: [ ^ self hideGlass ].
	self showGlass.
	self bounds = tmp1 bounds ifFalse: [ self bounds: tmp1 bounds ].
	self keepAbove: tmp1.
	tmp2 := self frameRectangle.
	tmp2 = lastRectangle ifTrue: [ ^ self ].
	nil.
	lastRectangle := tmp2.
	self changed
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetMorph [

	^ targetMorph
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetMorph: arg1 [

	self targetProvider: [ arg1 ]
]

{ #category : 'accessing' }
DdSelectionGlassMorph >> targetProvider: arg1 [

	targetProvider := arg1.
	targetMorph := self currentTargetFromProvider.
	lastRectangle := nil.
	self changed
]

{ #category : 'geometry' }
DdSelectionGlassMorph >> topMorphOf: arg1 [

	| tmp1 |
	tmp1 := arg1.
	[ tmp1 owner notNil and: [ tmp1 owner isWorldMorph not ] ]
		whileTrue: [ tmp1 := tmp1 owner ].
	^ tmp1
]

{ #category : 'stepping and presenter' }
DdSelectionGlassMorph >> wantsSteps [

	^ true
]
