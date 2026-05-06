Class {
	#name : 'DdRadioGroupPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'titleInput',
		'columnCountInput',
		'showTitleCheckbox',
		'showFrameCheckbox'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdRadioGroupPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [
   
	titleInput := SpTextInputFieldPresenter new.
	columnCountInput := SpTextInputFieldPresenter new.
	showTitleCheckbox := SpCheckBoxPresenter new label: 'Show title'.
	aPresenter showTitle ifTrue: [ showTitleCheckbox state: true ].
	showFrameCheckbox := SpCheckBoxPresenter new label: 'Show frame'.
	aPresenter showFrame ifTrue: [ showFrameCheckbox state: true ].
	[ titleInput text: aPresenter title ]
		on: Error
		do: [ ].
	[ columnCountInput text: aPresenter columnCount asString ]
		on: Error
		do: [ ].
	aPanel
		add: (self rowFor: 'Title' input: titleInput) expand: false;
		add: (self rowFor: 'Columns' input: columnCountInput) expand: false;
		add: showTitleCheckbox expand: false;
		add: showFrameCheckbox expand: false
]

{ #category : 'as yet unclassified' }
DdRadioGroupPropertyDescriptor >> collectPropertiesWithVarName: varName [

	| result |
	result := super collectPropertiesWithVarName: varName.
	titleInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'title:';
					 value: v;
					 yourself) ].
	columnCountInput text ifNotEmpty: [ :v |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'сolumnCount:';
					 value: v asInteger;
					 yourself) ].
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'showTitle:';
					 value: showTitleCheckbox state;
					 yourself) .
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'showFrame:';
					 value: showFrameCheckbox state;
					 yourself).
	^ result
]
