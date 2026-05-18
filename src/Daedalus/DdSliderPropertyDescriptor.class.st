"
I am the property descriptor for slider widgets. I extend the common style fields with inputs for label, min, max, value, and quantum.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdSliderPropertyDescriptor` (this is me)

### Instance Variables
- _labelInput_: `SpTextInputFieldPresenter` — edits the slider label
- _minInput_: `SpTextInputFieldPresenter` — edits the minimum value
- _maxInput_: `SpTextInputFieldPresenter` — edits the maximum value
- _valueInput_: `SpTextInputFieldPresenter` — edits the current value
- _quantumInput_: `SpTextInputFieldPresenter` — edits the step size
"
Class {
	#name : 'DdSliderPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'minInput',
		'maxInput',
		'valueInput',
		'labelInput',
		'quantumInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdSliderPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 
    | safeString |
    safeString := [ :v | (v isNil or: [ v isString not and: [ v isNumber not ] ]) 
        ifTrue: [ '' ] ifFalse: [ v asString ] ].
    
    labelInput := SpTextInputFieldPresenter new.
    minInput := SpTextInputFieldPresenter new.
    maxInput := SpTextInputFieldPresenter new.
    valueInput := SpTextInputFieldPresenter new.
    quantumInput := SpTextInputFieldPresenter new.

    [ labelInput text: (safeString value: aPresenter label) ] on: Error do: [ ].
    [ minInput text: (safeString value: aPresenter min) ] on: Error do: [ ].
    [ maxInput text: (safeString value: aPresenter max) ] on: Error do: [ ].
    [ valueInput text: (safeString value: aPresenter value) ] on: Error do: [ ].
    [ quantumInput text: (safeString value: aPresenter quantum) ] on: Error do: [ ].

    aPanel 
        add: (self rowFor: 'Label' input: labelInput) expand: false;
        add: (self rowFor: 'Min' input: minInput) expand: false;
        add: (self rowFor: 'Max' input: maxInput) expand: false;
        add: (self rowFor: 'Value' input: valueInput) expand: false;
        add: (self rowFor: 'Quantum' input: quantumInput) expand: false.
]

{ #category : 'as yet unclassified' }
DdSliderPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.
    labelInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'label:'; value: v; yourself) ].
    minInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'min:'; value: v asNumber; yourself) ].
    maxInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'max:'; value: v asNumber; yourself) ].
    valueInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'value:'; value: v asNumber; yourself) ].
    quantumInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'quantum:'; value: v asNumber; yourself) ].
    ^ result
]
