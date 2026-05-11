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
