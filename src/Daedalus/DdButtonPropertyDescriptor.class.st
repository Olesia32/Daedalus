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
    labelInput := SpTextInputFieldPresenter new.
    [ labelInput text: aPresenter label ] on: Error do: [ ].
    aPanel add: (self rowFor: 'Label' input: labelInput ) expand: false.
]

{ #category : 'as yet unclassified' }
DdButtonPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    | result |
    result := super collectPropertiesWithVarName: varName.
    labelInput text ifNotEmpty: [ :v |
        result addFirst: (DdTextProperties new
            varName: varName; text: v; yourself) ].
    ^ result
]
