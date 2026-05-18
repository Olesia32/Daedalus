"
I am the property descriptor for label widgets. I extend the common style fields with a single text input that sets the label's content.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdLabelPropertyDescriptor` (this is me)

### Instance Variables
- _textInput_: `SpTextInputFieldPresenter` — edits the displayed text
"
Class {
	#name : 'DdLabelPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'textInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdLabelPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [
"Adds a text input field to aPanel, pre-populated from aPresenter's current label."

	textInput := SpTextInputFieldPresenter new.
	[ textInput text: aPresenter label ]
		on: Error
		do: [ ].
	aPanel add: (self rowFor: 'Text' input: textInput) expand: false
]

{ #category : 'as yet unclassified' }
DdLabelPropertyDescriptor >> collectPropertiesWithVarName: varName [
	"Collects style properties from super, then prepends a DdTextProperties for the label text if the input is non-empty."

	| result |
	result := super collectPropertiesWithVarName: varName.
	textInput text ifNotEmpty: [ :v |
    result addFirst: (DdKeywordProperties new
        varName: varName; selector: 'label:'; value: v; yourself) ].
	^ result
]
