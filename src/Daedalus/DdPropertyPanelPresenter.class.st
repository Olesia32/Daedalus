Class {
	#name : 'DdPropertyPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetPresenter',
		'labelInput'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdPropertyPanelPresenter >> connectSignals [
    labelInput whenTextChangedDo: [ :text |
        targetPresenter label: text ]
]

{ #category : 'layout' }
DdPropertyPanelPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: 'Properties' expand: false;
        add: labelInput expand: false;
        yourself
]

{ #category : 'initialization' }
DdPropertyPanelPresenter >> initializePresenters [

	super initializePresenters.

	labelInput := TextInputPresenter new
		              placeholder: '';
		              yourself
]

{ #category : 'accessing' }
DdPropertyPanelPresenter >> loadProperties [
    targetPresenter ifNil: [ ^ self ].

    labelInput text: targetPresenter label
]

{ #category : 'accessing' }
DdPropertyPanelPresenter >> target: aPresenter [
    targetPresenter := aPresenter.
    self loadProperties
]
