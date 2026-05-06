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
	titleLabel := LabelPresenter new.
	titleLabel label: 'Embedde'.
	inner := DdInnerDemoPresenter new.
	titleLabel fontSize: 12.
	titleLabel backgroundColor: '#red'.
	titleLabel color: '#green'
]

{ #category : 'accessing' }
DdEmbeddedDemoPresenter >> inner [

	^ inner
]

{ #category : 'accessing' }
DdEmbeddedDemoPresenter >> titleLabel [

	^ titleLabel
]
