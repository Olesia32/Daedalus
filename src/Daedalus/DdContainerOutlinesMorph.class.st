Class {
	#name : 'DdContainerOutlinesMorph',
	#superclass : 'Morph',
	#instVars : [
		'anchorProvider',
		'entriesProvider',
		'lastEntries',
		'idleSteps',
		'pendingEntries'
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

	lastEntries ifNil: [ ^ self ].
	lastEntries do: [ :entry |
			| rectangle |
			rectangle := entry key.
			aCanvas frameRectangle: rectangle width: 1 color: self outlineColor.
			aCanvas
				drawString: entry value
				at: rectangle topLeft + (3 @ 1)
				font: nil
				color: self outlineColor ]
]

{ #category : 'stepping' }
DdContainerOutlinesMorph >> entries: newEntries lookSuspiciousComparedTo: oldEntries [

	(oldEntries isNil or: [ oldEntries size ~= newEntries size ])
		ifTrue: [ ^ false ].
	1 to: newEntries size do: [ :i |
			| new old |
			new := newEntries at: i.
			old := oldEntries at: i.
			(new value = old value and: [
				 self rectangle: new key isCollapsedComparedTo: old key ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'accessing' }
DdContainerOutlinesMorph >> entriesProvider: aBlock [
"aBlock is evaluated at every step and answers a collection of rectangle -> label associations
(world coordinates), one per container to outline."

	entriesProvider := aBlock.
	lastEntries := nil.
	pendingEntries := nil.
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
	idleSteps := 0.
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

	^ Color r: 0.55 g: 0.55 b: 0.6
]

{ #category : 'stepping' }
DdContainerOutlinesMorph >> rectangle: newRect isCollapsedComparedTo: oldRect [

	| oldArea newArea |
	oldArea := oldRect width * oldRect height.
	oldArea = 0 ifTrue: [ ^ false ].
	newArea := newRect width * newRect height.
	^ newArea < (oldArea / 2)
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

	[ self syncWithProviders ]
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

	^ 200
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
	self bounds = topMorph bounds ifFalse: [
		self bounds: topMorph bounds ].
	self keepAbove: topMorph.
	entries := self currentEntriesFromProvider.
	(self entries: entries lookSuspiciousComparedTo: lastEntries)
		ifTrue: [
				entries = pendingEntries
					ifTrue: [
							lastEntries := entries.
							pendingEntries := nil.
							self changed ]
					ifFalse: [ pendingEntries := entries ] ]
		ifFalse: [
				pendingEntries := nil.
				entries = lastEntries ifFalse: [
						lastEntries := entries.
						self changed ] ]
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
