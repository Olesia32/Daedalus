"
I am the property descriptor for date picker widgets. I extend the common style fields with a single date input in YYYY-MM-DD format.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdDatePickerPropertyDescriptor` (this is me)

### Instance Variables
- _dateInput_: `SpTextInputFieldPresenter` — edits the selected date
"
Class {
	#name : 'DdDatePickerPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'dateInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdDatePickerPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 
    dateInput := SpTextInputFieldPresenter new.

    [ dateInput text: aPresenter date printString ] on: Error do: [ ].

    aPanel add: (self rowFor: 'Date (YYYY-MM-DD)' input: dateInput) expand: false.
]

{ #category : 'adding' }
DdDatePickerPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.

    dateInput text ifNotEmpty: [ :v |
        result add: (DdGenericProperties new
            varName: varName; selector: 'date:'; value: v; yourself) ].

    ^ result
]
