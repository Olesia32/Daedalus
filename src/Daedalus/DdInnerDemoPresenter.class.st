Class {
	#name : 'DdInnerDemoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'button'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdInnerDemoPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: button ;
		  yourself
]

{ #category : 'initialization' }
DdInnerDemoPresenter >> initializePresenters [

	super initializePresenters.
	button := ButtonPresenter new.
	button label: 'Inner'.
	button fontSize: 12.
	button color: '#red'.
	button bold.
	button borderWidth: 2.
	button backgroundColor: '#white'.
	button borderColor: '#green'
]
