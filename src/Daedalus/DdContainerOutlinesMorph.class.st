Class {
	#name : 'DdContainerOutlinesMorph',
	#superclass : 'Morph',
	#instVars : [
		'anchorProvider',
		'entriesProvider',
		'lastEntries',
		'idleSteps',
		'hoveredEntry'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdContainerOutlinesMorph >> anchorProvider: aBlock [

	anchorProvider := aBlock
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
"Thin outlines for every container, and a label only for the one under the mouse - labels on all
of them overlapped the widgets they contain."

	lastEntries ifNil: [ ^ self ].
	lastEntries do: [ :entry | self drawOutline: entry key on: aCanvas ].
	hoveredEntry ifNotNil: [ :entry |
		self drawTag: entry value for: entry key on: aCanvas ]
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawOutline: aRectangle on: aCanvas [
"An empty container is (nearly) zero-high and would be invisible: it is shown as a short strip
instead, so it can be seen, hovered and dropped into."

	(aRectangle height < 6 or: [ aRectangle width < 6 ]) ifTrue: [
			^ aCanvas
				  fillRectangle:
				  (aRectangle origin extent: (aRectangle width max: 60) @ 6)
				  color: (self outlineColor alpha: 0.6) ].
	aCanvas frameRectangle: aRectangle width: 1 color: self outlineColor
]

{ #category : 'drawing' }
DdContainerOutlinesMorph >> drawTag: aLabel for: aRectangle on: aCanvas [
"A filled label just above the container's top edge (inside it when there is no room above),
plus a thin frame in the same color."

	| font textExtent tag |
	font := StandardFonts defaultFont.
	textExtent := (font widthOfString: aLabel) @ font height.
	tag := aRectangle topLeft - (0 @ (textExtent y + 2)) extent:
		       textExtent + (8 @ 2).
	tag top < self bounds top ifTrue: [
		tag := tag translateBy: 0 @ (textExtent y + 2) ].
	aCanvas frameRectangle: aRectangle width: 1 color: self tagColor.
	aCanvas fillRectangle: tag color: self tagColor.
	aCanvas
		drawString: aLabel
		at: tag topLeft + (4 @ 1)
		font: font
		color: DdDesignerTheme onAccent
]

{ #category : 'accessing' }
DdContainerOutlinesMorph >> entriesProvider: aBlock [
"aBlock is evaluated at every step and answers a collection of rectangle -> label associations
(world coordinates), one per container to outline."

	entriesProvider := aBlock.
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
"A stepping morph must never throw: it would fail again on every step and freeze the image."

	[
		self syncWithProviders.
		self updateHover ]
		on: Error
		do: [ :error |
				Transcript
					show: 'DdContainerOutlinesMorph stopped: ' , error description;
					cr.
				anchorProvider := nil.
				entriesProvider := nil.
				self hideOutlines ]
]

{ #category : 'stepping and presenter' }
DdContainerOutlinesMorph >> stepTime [
"Shorter than before so the hover label follows the mouse without a visible lag."

	^ 100
]

{ #category : 'stepping' }
DdContainerOutlinesMorph >> syncWithProviders [

	| topMorph anchor entries |
	self hasLiveAnchor ifFalse: [
			idleSteps := idleSteps + 1.
			self hideOutlines.
			idleSteps > 50 ifTrue: [ self delete ].
			^ self ].
	idleSteps := 0.
	anchor := self currentAnchorFromProvider.
	topMorph := self topMorphOf: anchor.
	(self isFrontWindow: topMorph) ifFalse: [ ^ self hideOutlines ].
	self showOutlines.
	topMorph fullBounds.
	self bounds = topMorph bounds ifFalse: [
		self bounds: topMorph bounds ].
	self keepAbove: topMorph.
	entries := self currentEntriesFromProvider.
	entries = lastEntries ifTrue: [ ^ self ].
	lastEntries := entries.
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
"The deepest (smallest) container under the mouse, redrawn only when it changes."

	| point best |
	point := self world ifNotNil: [ :aWorld | aWorld activeHand position ].
	best := nil.
	(point notNil and: [ self visible and: [ lastEntries notNil ] ])
		ifTrue: [
				lastEntries do: [ :entry |
						(entry key containsPoint: point) ifTrue: [
								(best isNil or: [ entry key area < best key area ]) ifTrue: [
									best := entry ] ] ] ].
	best = hoveredEntry ifTrue: [ ^ self ].
	hoveredEntry := best.
	self changed
]
