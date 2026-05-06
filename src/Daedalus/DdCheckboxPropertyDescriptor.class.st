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
    labelInput := SpTextInputFieldPresenter new.
    stateCheckbox := SpCheckBoxPresenter new label: 'Checked'.
    [ labelInput text: aPresenter label ] on: Error do: [ ].
    [ stateCheckbox state: aPresenter state ] on: Error do: [ ].
    aPanel add: (self rowFor: 'Label' input: labelInput) expand: false.
    aPanel add: stateCheckbox expand: false.
]

{ #category : 'as yet unclassified' }
DdCheckboxPropertyDescriptor >> collectPropertiesWithVarName: arg1 [

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
					 varName: arg1 ;
					 text: v;
					 yourself) ].
	^ tmp1
]
