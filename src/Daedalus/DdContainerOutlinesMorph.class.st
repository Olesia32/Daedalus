Class {
	#name : 'DdContainerOutlinesMorph',
	#superclass : 'Morph',
	#instVars : [
		'anchorProvider',
		'entriesProvider',
		'lastEntries',
		'idleSteps',
		'hoveredEntry',
		'clipProvider'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdContainerOutlinesMorph >> anchorProvider: aBlock [

	anchorProvider := aBlock
]

{ #category : 'accessing' }
DdContainerOutlinesMorph >> clipProvider: aBlock [
	"aBlock answers the rectangle (world coordinates) outside of which nothing is drawn, or nil."
	clipProvider := aBlock.
	self changed
]

{ #category : 'geometry testing' }
DdContainerOutlinesMorph >> containsPoint: aPoint [

	^ false
]

{ #category : 'private' }
DdContainerOutlinesMorph >> currentAnchorFromProvider [

	^ [ anchorProvider ifNotNil: [ :provider | provider value ] ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'private' }
DdContainerOutlinesMorph >> currentClip [
	^ [ clipProvider ifNotNil: [ :provider | provider value ] ]
		on: Error
		do: [ nil ]
]

{ #category : 'private' }
DdContainerOutlinesMorph >> currentEntriesFromProvider [

	^ [
		  entriesProvider
			  ifNotNil: [ :provider | provider value ]
			  ifNil: [ #(  ) ] ]
		  on: Error
		  do: [ #(  ) ]
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawOn: aCanvas [
	| clip |
	clip := self currentClip.
	clip ifNil: [ ^ self drawOutlinesOn: aCanvas ].
	aCanvas clipBy: clip during: [ :clipped | self drawOutlinesOn: clipped ]
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawOutline: arg1 on: arg2 [

	(arg1 height < 6 or: [ arg1 width < 6 ]) ifTrue: [
			^ arg2
				  fillRectangle: (arg1 origin extent: (arg1 width max: 60) @ 6)
				  color: (self outlineColor alpha: 0.6) ].
	nil.
	arg2 frameRectangle: arg1 width: 1 color: self outlineColor
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawOutlinesOn: aCanvas [
	"Thin outlines for every container, and a label only for the one under the mouse - labels on all
	of them overlapped the widgets they contain."
	lastEntries ifNil: [ ^ self ].
	lastEntries do: [ :entry | self drawOutline: entry key on: aCanvas ].
	hoveredEntry ifNotNil: [ :entry |
		self drawTag: entry value for: entry key on: aCanvas ]
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawTag: arg1 for: arg2 on: arg3 [

	| tmp1 tmp2 tmp3 |
	tmp1 := StandardFonts defaultFont.
	tmp2 := (tmp1 widthOfString: arg1) @ tmp1 height.
	tmp3 := arg2 topLeft - (0 @ (tmp2 y + 2)) extent: tmp2 + (8 @ 2).
	tmp3 top < self bounds top ifTrue: [
		tmp3 := tmp3 translateBy: 0 @ (tmp2 y + 2) ].
	arg3
		frameRectangle: arg2 width: 1 color: self tagColor;
		fillRectangle: tmp3 color: self tagColor;
		drawString: arg1
		at: tmp3 topLeft + (4 @ 1)
		font: tmp1
		color: DdDesignerTheme onAccent
]

{ #category : 'accessing' }
DdContainerOutlinesMorph >> entriesProvider: arg1 [

	entriesProvider := arg1.
	lastEntries := nil.
	self changed
]

{ #category : 'event handling' }
DdContainerOutlinesMorph >> handlesMouseDown: anEvent [

	^ false
]

{ #category : 'geometry' }
DdContainerOutlinesMorph >> hasLiveAnchor [
"A rebuilt preview leaves the old morph without a world: then there is nothing to outline."

	| anchor |
	anchor := self currentAnchorFromProvider.
	^ anchor notNil and: [ anchor world notNil ]
]

{ #category : 'visibility' }
DdContainerOutlinesMorph >> hideOutlines [

	self visible ifTrue: [ self visible: false ]
]

{ #category : 'initialization' }
DdContainerOutlinesMorph >> initialize [

	super initialize.
	self
		color: Color transparent;
		borderWidth: 0.
	idleSteps := 0
]

{ #category : 'geometry' }
DdContainerOutlinesMorph >> isFrontWindow: aTopMorph [
"Only the frontmost window gets outlined: it must not show through other windows."

	| front |
	aTopMorph isSystemWindow ifFalse: [ ^ true ].
	front := aTopMorph owner submorphs
		         detect: [ :each | each isSystemWindow ]
		         ifNone: [ nil ].
	^ front == aTopMorph
]

{ #category : 'geometry' }
DdContainerOutlinesMorph >> keepAbove: aTopMorph [
"Activating a window brings it in front of the overlay: put the overlay back on top."

	| siblings |
	(owner notNil and: [ aTopMorph notNil ]) ifFalse: [ ^ self ].
	siblings := owner submorphs.
	((siblings includes: aTopMorph) and: [
		 (siblings indexOf: self) > (siblings indexOf: aTopMorph) ])
		ifTrue: [ owner addMorphFront: self ]
]

{ #category : 'accessing' }
DdContainerOutlinesMorph >> lastEntries [

	^ lastEntries
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> outlineColor [

	^ DdDesignerTheme outline
]

{ #category : 'actions' }
DdContainerOutlinesMorph >> showIn: aWorld [
"Puts the overlay into the world (like a halo, not into a Spec layout) and syncs it."

	aWorld ifNil: [ ^ self ].
	owner == aWorld ifFalse: [ aWorld addMorphFront: self ].
	self syncWithProviders
]

{ #category : 'visibility' }
DdContainerOutlinesMorph >> showOutlines [

	self visible ifFalse: [ self visible: true ]
]

{ #category : 'stepping and presenter' }
DdContainerOutlinesMorph >> step [

	[
		self
			syncWithProviders;
			updateHover ]
		on: Error
		do: [ :arg1 |
				Transcript
					show: 'DdContainerOutlinesMorph stopped: ' , arg1 description;
					cr.
				anchorProvider := nil.
				entriesProvider := nil.
				self hideOutlines ]
]

{ #category : 'stepping and presenter' }
DdContainerOutlinesMorph >> stepTime [

	^ 100
]

{ #category : 'stepping' }
DdContainerOutlinesMorph >> syncWithProviders [

	| tmp1 tmp2 tmp3 |
	self hasLiveAnchor ifFalse: [
			idleSteps := idleSteps + 1.
			self hideOutlines.
			idleSteps > 50 ifTrue: [ self delete ].
			^ self ].
	idleSteps := 0.
	tmp2 := self currentAnchorFromProvider.
	tmp1 := self topMorphOf: tmp2.
	(self isFrontWindow: tmp1) ifFalse: [ ^ self hideOutlines ].
	self showOutlines.
	tmp1 fullBounds.
	self bounds = tmp1 bounds ifFalse: [ self bounds: tmp1 bounds ].
	self keepAbove: tmp1.
	tmp3 := self currentEntriesFromProvider.
	tmp3 = lastEntries ifTrue: [ ^ self ].
	nil.
	lastEntries := tmp3.
	self changed
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> tagColor [

	^ DdDesignerTheme accent
]

{ #category : 'geometry' }
DdContainerOutlinesMorph >> topMorphOf: aMorph [
"The morph directly under the world that contains aMorph: for the designer, its window."

	| current |
	current := aMorph.
	[ current owner notNil and: [ current owner isWorldMorph not ] ]
		whileTrue: [ current := current owner ].
	^ current
]

{ #category : 'stepping' }
DdContainerOutlinesMorph >> updateHover [
	"The deepest (smallest) container under the mouse, redrawn only when it changes. Nothing is
	hovered over a part of the canvas that is scrolled away."
	| point best clip |
	point := self world ifNotNil: [ :aWorld | aWorld activeHand position ].
	clip := self currentClip.
	(point notNil and: [ clip notNil and: [ (clip containsPoint: point) not ] ]) ifTrue: [ point := nil ].
	best := nil.
	(point notNil and: [ self visible and: [ lastEntries notNil ] ]) ifTrue: [
		lastEntries do: [ :entry |
			(entry key containsPoint: point) ifTrue: [
				(best isNil or: [ entry key area < best key area ]) ifTrue: [ best := entry ] ] ] ].
	best = hoveredEntry ifTrue: [ ^ self ].
	hoveredEntry := best.
	self changed
]
