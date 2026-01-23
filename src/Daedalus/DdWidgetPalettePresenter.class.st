Class {
	#name : 'DdWidgetPalettePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'list',
		'filteredInput',
		'model'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdWidgetPalettePresenter >> connectFilter [

    filteredInput whenTextChangedDo: [ :text |
        list items: (model select: [ :each |
            each label asLowercase includesSubstring: text asLowercase ]) ].
]

{ #category : 'layout' }
DdWidgetPalettePresenter >> defaultLayout [

	| tmp2 tmp4 |
	tmp2 := SpBoxLayout newLeftToRight.
	tmp4 := SpBoxLayout newTopToBottom.
	tmp4
		add: 'Standart Widgetes' expand: false;
		add: filteredInput expand: false.
	tmp2 add: (tmp4 add: list).
	^ tmp2 yourself
]

{ #category : 'initialization' }
DdWidgetPalettePresenter >> initializePresenters [

	model := DdWidgetRegistry all.
	list := SpListPresenter new.
	list
		items: model;
		display: [ :item | item label ];
		sortingBlock: [ :a :b | a label < b label ];
		displayIcon: [ :item | item icon ];
		dragEnabled: true.
	filteredInput := TextInputPresenter new
		                 isValidationField: false;
		                 height: 25;
		                 placeholder: 'Choose widget...'.
	self connectFilter 
]
