"
I am the property descriptor for checkbox widgets. I extend the common style fields with a label input and a checked-state checkbox.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdCheckboxPropertyDescriptor` (this is me)

### Instance Variables
- _labelInput_: `SpTextInputFieldPresenter` — edits the checkbox label
- _stateCheckbox_: `SpCheckBoxPresenter` — reflects the checked state
"
Class {
	#name : 'DdCheckboxPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'labelInput',
		'stateCheckbox'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdCheckboxPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [
"Adds label and state fields to aPanel, pre-populated from aPresenter's current label and state."

	labelInput := SpTextInputFieldPresenter new.
	stateCheckbox := SpCheckBoxPresenter new label: 'Checked'.
	[ labelInput text: aPresenter label ]
		on: Error
		do: [ ].
	[ stateCheckbox state: aPresenter state ]
		on: Error
		do: [ ].
	aPanel add: (self rowFor: 'Label' input: labelInput) expand: false.
	aPanel add: stateCheckbox expand: false
]

{ #category : 'as yet unclassified' }
DdCheckboxPropertyDescriptor >> collectPropertiesWithVarName: arg1 [
"Collects style properties from super, appends a DdGenericProperties for state:, and prepends a DdTextProperties for the label if present."

	| tmp1 tmp2 |
	tmp1 := super collectPropertiesWithVarName: arg1.
	tmp2 := DdGenericProperties new.
	tmp2
		varName: arg1;
		selector: 'state:';
		value: stateCheckbox state.
	tmp1 add: tmp2 yourself.
	labelInput text ifNotEmpty: [ :v |
			tmp1 addFirst: (DdTextProperties new
					 varName: arg1;
					 text: v;
					 yourself) ].
	^ tmp1
]
