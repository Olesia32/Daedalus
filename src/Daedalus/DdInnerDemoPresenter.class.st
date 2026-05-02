Class {
	#name : 'DdInnerDemoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'label'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'layout' }
DdInnerDemoPresenter >> defaultLayout [ 
	^ SpBoxLayout newTopToBottom
		add: label;
		yourself
]

{ #category : 'initialization' }
DdInnerDemoPresenter >> initializePresenters [

	super initializePresenters.
	label := LabelPresenter new.
	label label: 'Inne'
]
