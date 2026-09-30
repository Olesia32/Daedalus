"
I am the widget palette shown on the left side of the designer. I display the full list of available widgets, support filtering
by name, and notify the designer when the user activates a widget to add it to the canvas.

### Hierarchy
`SpPresenter`
`DdWidgetPalettePresenter` (this is me)

### Instance Variables
- _list_: `SpListPresenter` — displays the filtered widget descriptors
- _filteredInput_: `SpTextInputFieldPresenter` — the search/filter field
- _model_: `Array` — the full unfiltered list of `DdWidgetDescriptor` instances
- _designer_: `DdDesignerPresenter` — notified when a widget is activated
"
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
"Wires the filter input so that typing narrows the list to descriptors whose label contains the typed substring
case-insensitively."

	filteredInput whenTextChangedDo: [ :arg1 |
			list items: (model select: [ :arg2 |
					 arg2 label asLowercase includesSubstring: arg1 asLowercase ]) ]
]

{ #category : 'dragging' }
DdWidgetPalettePresenter >> containsWorldPoint: aPoint [
"True when aPoint (world coordinates) is over the list of widgets. A list on a hidden tab keeps
its old bounds but has left the world - it must not claim presses meant for the tree."

	^ list adapter ifNil: [ false ] ifNotNil: [ :anAdapter |
			  anAdapter widget ifNil: [ false ] ifNotNil: [ :morph |
				  morph world notNil and: [
					  morph boundsInWorld containsPoint: aPoint ] ] ]
]

{ #category : 'layout' }
DdWidgetPalettePresenter >> defaultLayout [
"The tab title names this list now, so there is no header label of its own."

	^ SpBoxLayout newTopToBottom
		  add: filteredInput expand: false;
		  add: list;
		  yourself
]

{ #category : 'accessing' }
DdWidgetPalettePresenter >> designer: aDesigner [ 
    designer := aDesigner
]

{ #category : 'initialization' }
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

{ #category : 'dragging' }
DdWidgetPalettePresenter >> selectedDescriptor [
	^ list selectedItem
]
