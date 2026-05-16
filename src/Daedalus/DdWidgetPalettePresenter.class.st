Class {
	#name : 'DdWidgetPalettePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'list',
		'filteredInput',
		'model',
		'designer'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdWidgetPalettePresenter >> connectFilter [

	filteredInput whenTextChangedDo: [ :arg1 |
			list items: (model select: [ :arg2 |
					 arg2 label asLowercase includesSubstring: arg1 asLowercase ]) ]
]

{ #category : 'layout' }
DdWidgetPalettePresenter >> defaultLayout [

	| tmp1 tmp2 |
	tmp1 := SpBoxLayout newLeftToRight.
	tmp2 := SpBoxLayout newTopToBottom.
	tmp2
		add: 'Standart Widgetes' expand: false;
		add: filteredInput expand: false.
	tmp1 add: (tmp2 add: list).
	^ tmp1 yourself
]

{ #category : 'accessing' }
DdWidgetPalettePresenter >> designer: aDesigner [ 
    designer := aDesigner
]

{ #category : 'accessing' }
DdWidgetPalettePresenter >> initializePresenters [ 
    model := DdWidgetRegistry all.
    list := SpListPresenter new.
    list
        items: model;
        display: [ :item | item label ];
        sortingBlock: [ :a :b | a label < b label ];
        dragEnabled: true;
        whenActivatedDo: [ :selection |
            selection selectedItem ifNotNil: [ :descriptor |
                designer ifNotNil: [ designer addWidget: descriptor ] ] ].
    filteredInput := TextInputPresenter new
        isValidationField: false;
        height: 25;
        placeholder: 'Choose widget...'.
    self connectFilter
]
