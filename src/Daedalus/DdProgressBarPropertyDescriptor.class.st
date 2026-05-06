Class {
	#name : 'DdProgressBarPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'valueInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdProgressBarPropertyDescriptor >> buildPanelFor: arg1 [

	| tmp1 |
	valueInput := SpTextInputFieldPresenter new.
	[ valueInput text: arg1 value asString ]
		on: Error
		do: [ ].
	tmp1 := super buildPanelFor: arg1.
	tmp1 layout
		add: (self rowFor: 'Value (0-100)' input: valueInput)
		expand: false.
	^ tmp1
]

{ #category : 'as yet unclassified' }
DdProgressBarPropertyDescriptor >> collectPropertiesWithVarName: arg1 [

	| tmp1 |
	tmp1 := super collectPropertiesWithVarName: arg1.
	valueInput text ifNotEmpty: [ :arg2 |
			| tmp3 |
			tmp3 := DdGenericProperties new.
			tmp3
				varName: arg1;
				selector: 'value:';
				value: arg2 asInteger.
			tmp1 add: tmp3 yourself ].
	^ tmp1
]
