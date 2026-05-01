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

	self initialize.
	presenters := aPresenter allPresenters asOrderedCollection. presenters
		              do: [ :p | self indexPresenter: p ].
	^ self
]

{ #category : 'accessing' }
DdPresenterIndex >> indexPresenter: aPresenter [ 
  | w |
  w := self widgetOf: aPresenter.
  w ifNil: [ ^ self ].
  widgetToPresenter at: w put: aPresenter.
]

{ #category : 'initialization' }
DdPresenterIndex >> initialize [

	super initialize.
	widgetToPresenter := IdentityDictionary new.
	presenters := OrderedCollection new
]

{ #category : 'as yet unclassified' }
DdPresenterIndex >> presenterAtClickedMorph: aMorph [ 
  | m |
  m := aMorph.
  [ m notNil ] whileTrue: [
    (widgetToPresenter includesKey: m) ifTrue: [ ^ widgetToPresenter at: m ].
    m := m owner ].
  ^ nil
]

{ #category : 'as yet unclassified' }
DdPresenterIndex >> presenterForWidget: aWidget [ 
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
