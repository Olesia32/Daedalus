"
I am the property descriptor for button widgets. I extend the common style fields with a label input specific to `SpButtonPresenter`.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdButtonPropertyDescriptor` (this is me)

### Instance Variables
- _labelInput_: `SpTextInputFieldPresenter` — edits the button's label text
"
Class {
	#name : 'DdButtonPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'labelInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdButtonPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [
"Adds a label text input field to aPanel, pre-populated from aPresenter's current label."

	labelInput := SpTextInputFieldPresenter new.
	[ labelInput text: aPresenter label ]
		on: Error
		do: [ ].
	aPanel add: (self rowFor: 'Label' input: labelInput) expand: false
]

{ #category : 'as yet unclassified' }
DdButtonPropertyDescriptor >> collectPropertiesWithVarName: varName [
"Collects style properties from super, then prepends a DdTextProperties for the label if the label input is non-empty."

	| result |
	result := super collectPropertiesWithVarName: varName.
	labelInput text ifNotEmpty: [ :v |
			result addFirst: (DdTextProperties new
					 varName: varName;
					 text: v;
					 yourself) ].
	^ result
]
