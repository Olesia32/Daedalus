Class {
	#name : 'DdDropIndicatorMorph',
	#superclass : 'Morph',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'events' }
DdDropIndicatorMorph >> containsPoint: aPoint [
	"A ghost: it never takes part in hit testing, events reach the widgets under it."

	^ false
]

{ #category : 'events' }
DdDropIndicatorMorph >> containsPoint: aPoint event: anEvent [
	^ false
]

{ #category : 'actions' }
DdDropIndicatorMorph >> hideIndicator [
	self visible ifTrue: [ self visible: false ]
]

{ #category : 'initialization' }
DdDropIndicatorMorph >> initialize [
	super initialize.
	self color: (Color orange alpha: 0.7).
	self visible: false
]

{ #category : 'actions' }
DdDropIndicatorMorph >> showAt: aRectangle [
	self bounds: aRectangle.
	self visible ifFalse: [ self visible: true ]
]
