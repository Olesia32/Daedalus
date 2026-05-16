"
I am the property descriptor for radio button group widgets. I extend the group descriptor with a selected-index input that controls which
radio button is pre-selected.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdItemsPropertyDescriptor`
`DdGroupPropertyDescriptor`
`DdRadioGroupPropertyDescriptor` (this is me)

### Instance Variables
- _selectedIndexInput_: `SpTextInputFieldPresenter` — edits the index of the pre-selected radio button
"
Class {
	#name : 'DdRadioGroupPropertyDescriptor',
	#superclass : 'DdGroupPropertyDescriptor',
	#instVars : [
		'selectedIndexInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdRadioGroupPropertyDescriptor >> addSelectionFieldsTo: aPanel for: aPresenter [ 

    selectedIndexInput := SpTextInputFieldPresenter new.
    [ selectedIndexInput text: aPresenter indexSelected asString ]
        on: Error do: [ ].

    aPanel add: (self rowFor: 'Selected index' input: selectedIndexInput) expand: false.
]

{ #category : 'adding' }
DdRadioGroupPropertyDescriptor >> addSelectionPropertiesTo: result varName: varName [ 

    selectedIndexInput text ifNotEmpty: [ :v |
        | idx |
        idx := v asInteger.
        idx > 0 ifTrue: [
            result add: (DdGenericProperties new
                varName: varName; selector: 'itemSelected:'; value: idx; yourself) ] ]
]
