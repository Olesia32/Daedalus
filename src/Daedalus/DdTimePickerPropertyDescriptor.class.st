Class {
	#name : 'DdTimePickerPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'hourInput',
		'minutesInput',
		'okLabelInput',
		'cancelLabelInput',
		'additionColorInput',
		'mainColorInput'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdTimePickerPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [

	hourInput := SpTextInputFieldPresenter new.
	minutesInput := SpTextInputFieldPresenter new.
	okLabelInput := SpTextInputFieldPresenter new.
	cancelLabelInput := SpTextInputFieldPresenter new.
	mainColorInput := SpTextInputFieldPresenter new.
	additionColorInput := SpTextInputFieldPresenter new.

	[ hourInput text: aPresenter hour asString ]
		on: Error
		do: [ ].
	[ minutesInput text: aPresenter minutes asString ]
		on: Error
		do: [ ].
	[ okLabelInput text: aPresenter okButtonLabel ]
		on: Error
		do: [ ].
	[ cancelLabelInput text: aPresenter cancelButtonLabel ]
		on: Error
		do: [ ].
	[ mainColorInput text: aPresenter color ]
		on: Error
		do: [ ].
	[ additionColorInput text: aPresenter additionColor ]
		on: Error
		do: [ ].

	aPanel
		add: (self rowFor: 'Hour (0-23)' input: hourInput) expand: false;
		add: (self rowFor: 'Minutes (0-59)' input: minutesInput)
		expand: false;
		add: (self rowFor: 'Ok label' input: okLabelInput) expand: false;
		add: (self rowFor: 'Cancel label' input: cancelLabelInput)
		expand: false;
		add: (self rowFor: 'Main color' input: mainColorInput) expand: false;
		add: (self rowFor: 'Addition color' input: additionColorInput)
		expand: false
]

{ #category : 'as yet unclassified' }
DdTimePickerPropertyDescriptor >> collectPropertiesWithVarName: varName [

	| result |
	result := super collectPropertiesWithVarName: varName.

	hourInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'hour:';
					 value: v asInteger;
					 yourself) ].

	minutesInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'minutes:';
					 value: v asInteger;
					 yourself) ].

	okLabelInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'okButtonLabel:';
					 value: v;
					 yourself) ].

	cancelLabelInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'cancelButtonLabel:';
					 value: v;
					 yourself) ].
	mainColorInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'color:';
					 value: v;
					 yourself) ].
	additionColorInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'additionColor:';
					 value: v;
					 yourself) ].

	^ result
]
