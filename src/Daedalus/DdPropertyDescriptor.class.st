Class {
	#name : 'DdPropertyDescriptor',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdPropertyDescriptor class >> forPresenter: aPresenter [

	| mainP |
	mainP := (aPresenter respondsTo: #mainPresenter)
		         ifTrue: [ aPresenter mainPresenter ]
		         ifFalse: [ aPresenter ].
	(mainP isKindOf: SpLabelPresenter) ifTrue: [
		^ DdLabelPropertyDescriptor new ].
	(mainP isKindOf: SpButtonPresenter) ifTrue: [
		^ DdButtonPropertyDescriptor new ].
	(mainP isKindOf: SpCheckBoxPresenter) ifTrue: [
		^ DdCheckboxPropertyDescriptor new ].
	(mainP isKindOf: SpTextInputFieldPresenter) ifTrue: [
		^ DdTextInputPropertyDescriptor new ].
	(mainP isKindOf: SpProgressBarPresenter) ifTrue: [
		^ DdProgressBarPropertyDescriptor new ].
	(mainP isKindOf: SpSliderPresenter) ifTrue: [
		^ DdSliderPropertyDescriptor new ].
	(mainP isKindOf: SpDatePresenter) ifTrue: [
		^ DdDatePickerPropertyDescriptor new ].
	(mainP isKindOf: SpListPresenter) ifTrue: [
		^ DdListPropertyDescriptor new ].
	(mainP isKindOf: SpTextPresenter) ifTrue: [
		^ DdTextAreaPropertyDescriptor new ].
	aPresenter class name = 'RadioGroupPresenter' ifTrue: [
		^ DdRadioGroupPropertyDescriptor new ].
	aPresenter class name = 'CheckboxGroupPresenter' ifTrue: [
		^ DdCheckboxGroupPropertyDescriptor new ].
	aPresenter class name = 'ComboBoxPresenter' ifTrue: [
		^ DdComboboxPropertyDescriptor new ].
	aPresenter class name = 'TimePickerPresenter' ifTrue: [
		^ DdTimePickerPropertyDescriptor new ].
	aPresenter class name = 'PaginatedTablePresenter' ifTrue: [
		^ DdTablePropertyDescriptor new ].

	^ nil
]

{ #category : 'as yet unclassified' }
DdPropertyDescriptor >> buildPanelFor: aPresenter [ 
    "Підкласи реалізують — будують і повертають SpPresenter з полями"
    ^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DdPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
    "Зчитує значення з UI і повертає колекцію DdPresenterProperties"
    ^ self subclassResponsibility
]
