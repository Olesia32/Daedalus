"
I am the abstract root of the property descriptor hierarchy. I declare the two operations every descriptor must support: building
a UI panel for a given presenter, and collecting the edited properties as a list of DdPresenterProperties objects ready to be
compiled into source code.

### Hierarchy
`Object`
`DdPropertyDescriptor` (this is me)

### Public API
- `DdPropertyDescriptor class>>#forPresenter:` — factory method; inspects the presenter's type and returns the matching concrete
  descriptor, or nil if the type is unknown
"
Class {
	#name : 'DdPropertyDescriptor',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdPropertyDescriptor class >> forPresenter: aPresenter [
"Factory. Inspects the kind of aPresenter (or its mainPresenter) and returns the appropriate concrete DdPropertyDescriptor subclass
instance, or nil for unrecognised types."

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
	(mainP isKindOf: SpTablePresenter) ifTrue: [
		^ DdTablePropertyDescriptor new ].
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
	"Abstract. Subclasses build and return a SpPresenter populated with property input fields for the given presenter."

	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DdPropertyDescriptor >> collectPropertiesWithVarName: varName [
	"Abstract. Subclasses read their input fields and return a collection of DdPresenterProperties ready to patch and compile."

	^ self subclassResponsibility
]
