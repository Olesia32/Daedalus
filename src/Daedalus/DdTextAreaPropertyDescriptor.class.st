Class {
	#name : 'DdTextAreaPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'contentInput',
		'wrapWordCheckbox'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdTextAreaPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 

	contentInput := SpTextInputFieldPresenter new.
	wrapWordCheckbox := SpCheckBoxPresenter new label: 'Wrap word'.

	[ contentInput text: aPresenter text ] on: Error do: [ ].
	[ wrapWordCheckbox state: aPresenter isWrapWord ] on: Error do: [ ].

	aPanel add: (self rowFor: 'Text' input: contentInput) expand: false.
	aPanel add: wrapWordCheckbox expand: false.
]

{ #category : 'adding' }
DdTextAreaPropertyDescriptor >> collectPropertiesWithVarName: varName [

	| result |
	result := super collectPropertiesWithVarName: varName.

	contentInput text ifNotEmpty: [ :v |
			result addFirst: (DdGenericProperties new
					 varName: varName;
					 selector: 'text:';
					 value: v;
					 yourself) ].

	result add: (DdUnaryProperties new
	varName: varName;
	selector: (wrapWordCheckbox state ifTrue: [ 'beWrapWord' ] ifFalse: [ 'beNotWrapWord' ]);
	yourself).

	^ result
]
