Class {
	#name : 'DdSelectionOverlayMorph',
	#superclass : 'BorderedMorph',
	#instVars : [
		'trackedMorph'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdSelectionOverlayMorph >> delete [
    self owner ifNotNil: [ super delete ].
    trackedMorph := nil

]

{ #category : 'event handling' }
DdSelectionOverlayMorph >> handlesMouseDown: anEvent [
    ^ false
]

{ #category : 'initialization' }
DdSelectionOverlayMorph >> initializeFor: aMorph [

	trackedMorph := aMorph.
	self
		fillStyle: Color transparent;
		borderStyle: (SimpleBorderStyle new
				 width: 1;
				 baseColor: (Color
						  r: 0.2
						  g: 0.5
						  b: 1.0
						  alpha: 1.0)).
	self on: #mouseDown send: #ignore to: self.
	^ self
]

{ #category : 'accessing' }
DdSelectionOverlayMorph >> trackedMorph [
    ^ trackedMorph
]

{ #category : 'accessing' }
DdSelectionOverlayMorph >> update [
    trackedMorph ifNil: [ ^ self delete ].
    trackedMorph world ifNil: [ ^ self delete ].
    self bounds: trackedMorph bounds
]
