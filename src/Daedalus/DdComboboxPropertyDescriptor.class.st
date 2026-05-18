"
I am the property descriptor for combobox widgets. I extend the common style fields with an items list, add/remove buttons, and a selected-index input.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdComboboxPropertyDescriptor` (this is me)

### Instance Variables
- _itemsList_: `SpListPresenter` — displays the current list of items
- _addItemInput_: `SpTextInputFieldPresenter` — input for a new item
- _addItemButton_: `SpButtonPresenter` — adds the typed item to the list
- _removeItemButton_: `SpButtonPresenter` — removes the selected item
- _selectedIndexInput_: `SpTextInputFieldPresenter` — edits the pre-selected index
"
Class {
	#name : 'DdComboboxPropertyDescriptor',
	#superclass : 'DdItemsPropertyDescriptor',
	#instVars : [
		'selectedIndexInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdComboboxPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 
    self addItemsFieldsTo: aPanel for: aPresenter.
    
    [ itemsList items: aPresenter allItems asOrderedCollection ] on: Error do: [ ].
    
    selectedIndexInput := SpTextInputFieldPresenter new.
    [ selectedIndexInput text: aPresenter selectedIndex asString ] on: Error do: [ ].
    
    aPanel add: (self rowFor: 'Selected index' input: selectedIndexInput) expand: false.
]

{ #category : 'as yet unclassified' }
DdComboboxPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.
    
    self collectItemsPropertiesWith: varName into: result.
    
    selectedIndexInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName;
            selector: 'selectIndex:';
            value: v asInteger;
            yourself) ].
    
    ^ result
]
