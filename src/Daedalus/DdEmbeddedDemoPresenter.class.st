Class {
	#name : 'DdEmbeddedDemoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'inner'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdEmbeddedDemoPresenter >> defaultLayout [ 
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: titleLabel;
		add: inner;
		yourself
]

{ #category : 'initialization' }
DdEmbeddedDemoPresenter >> initializePresenters [ 
	super initializePresenters.
	titleLabel := self newLabel.
	titleLabel label: 'Embedded'.

	inner := DdInnerDemoPresenter new.
]
