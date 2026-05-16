"
I maintain a bidirectional index between presenters and their underlying Morphic widgets. I am rebuilt whenever the canvas
preview is refreshed and used to resolve a clicked morph back to the presenter that owns it.

### Hierarchy
`Object`
`DdPresenterIndex` (this is me)

### Instance Variables
- _widgetToPresenter_: `IdentityDictionary` — maps each widget morph to its presenter
- _presenters_: `OrderedCollection` — all presenters found in the
  root presenter tree
"
Class {
	#name : 'DdPresenterIndex',
	#superclass : 'Object',
	#instVars : [
		'widgetToPresenter',
		'presenters'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'as yet unclassified' }
DdPresenterIndex >> buildFromRootPresenter: aPresenter [ 
"Walks all presenters reachable from aPresenter, populates the presenters collection, and fills widgetToPresenter for each
presenter that has a live adapter widget."

	self initialize.
	presenters := aPresenter allPresenters asOrderedCollection.
	
	presenters do: [ :p |
		(p adapter notNil and: [ p adapter widget notNil ]) ifTrue: [
			widgetToPresenter at: p adapter widget put: p ] ].
	^ self
]

{ #category : 'accessing' }
DdPresenterIndex >> indexPresenter: aPresenter [

	| w |
	w := self widgetOf: aPresenter.
	w ifNil: [ ^ self ].

	widgetToPresenter at: w put: aPresenter.

	(w respondsTo: #setProperty:toValue:) ifTrue: [
		w setProperty: #ddPresenter toValue: aPresenter ]
]

{ #category : 'initialization' }
DdPresenterIndex >> initialize [

	super initialize.
	widgetToPresenter := IdentityDictionary new.
	presenters := OrderedCollection new
]

{ #category : 'as yet unclassified' }
DdPresenterIndex >> presenterAtClickedMorph: aMorph [ 
"Walks up the morph ownership chain from aMorph until it finds a morph registered in widgetToPresenter, returning the associated
presenter or nil."

	| m |
	m := aMorph.
	[ m notNil ] whileTrue: [
		(widgetToPresenter includesKey: m) ifTrue: [
			^ widgetToPresenter at: m ].
		m := m owner ].
	^ nil
]

{ #category : 'as yet unclassified' }
DdPresenterIndex >> presenterForWidget: aWidget [ 
"Returns the presenter registered for aWidget, or nil if not found."

  ^ widgetToPresenter at: aWidget ifAbsent: [ nil ]
]

{ #category : 'accessing' }
DdPresenterIndex >> presenters [ 
	^ presenters
]

{ #category : 'as yet unclassified' }
DdPresenterIndex >> widgetOf: aPresenter [

  aPresenter adapter ifNil: [ aPresenter build ].
  ^ aPresenter adapter widget
]

{ #category : 'accessing' }
DdPresenterIndex >> widgetToPresenter [ 
  ^ widgetToPresenter
]
