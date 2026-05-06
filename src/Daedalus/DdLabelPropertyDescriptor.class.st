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
    textInput := SpTextInputFieldPresenter new.
    [ textInput text: aPresenter label ] on: Error do: [ ].
    aPanel add: (self rowFor: 'Text' input: textInput) expand: false.

]

{ #category : 'as yet unclassified' }
DdLabelPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.
    textInput text ifNotEmpty: [ :v |
        result addFirst: (DdTextProperties new
            varName: varName; text: v; yourself) ].
    ^ result
]
