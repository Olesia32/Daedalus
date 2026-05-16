"
I am the property descriptor for text input widgets. I extend the common style fields with a content input and a placeholder input.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdTextInputPropertyDescriptor` (this is me)

### Instance Variables
- _contentInput_: `SpTextInputFieldPresenter` — edits the current text value
- _placeholderInput_: `SpTextInputFieldPresenter` — edits the placeholder hint
"
Class {
	#name : 'DdTextInputPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'contentInput',
		'placeholderInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdTextInputPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 
    contentInput := SpTextInputFieldPresenter new.
    placeholderInput := SpTextInputFieldPresenter new.
    [ contentInput text: aPresenter text ] on: Error do: [ ].
    [ placeholderInput text: aPresenter placeholder ] on: Error do: [ ].
    aPanel add: (self rowFor: 'Text' input: contentInput ) expand: false.
    aPanel add: (self rowFor: 'Placeholder' input: placeholderInput) expand: false
]

{ #category : 'as yet unclassified' }
DdTextInputPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.
    placeholderInput text ifNotEmpty: [ :v |
        result add: (DdGenericProperties new
            varName: varName; selector: 'placeholder:'; value: v; yourself) ].
    contentInput text ifNotEmpty: [ :v |
        result addFirst: (DdGenericProperties new
            varName: varName; selector: 'text:'; value: v; yourself) ].
    ^ result

]
