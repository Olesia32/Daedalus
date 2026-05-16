"
I am a class-side registry that enumerates all widget types available in the palette. I return a fixed array of
DdWidgetDescriptor instances, one per supported widget type.

### Hierarchy
`Object`
`DdWidgetRegistry` (this is me)

### Public API
- `DdWidgetRegistry class>>#all` — returns the full array of available widget descriptors

### Usage
```smalltalk
DdWidgetRegistry all do: [ :descriptor |
    Transcript showln: descriptor label ].
```
"
Class {
	#name : 'DdWidgetRegistry',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'accessing' }
DdWidgetRegistry class >> all [

	^ {
		  (DdWidgetDescriptor new
			   label: 'Button'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpButtonPresenter).

		  (DdWidgetDescriptor new
			   label: 'Label'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpLabelPresenter).

		  (DdWidgetDescriptor new
			   label: 'Text Input'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: TextInputPresenter).

		  (DdWidgetDescriptor new
			   label: 'Text Area'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpTextPresenter).

		  (DdWidgetDescriptor new
			   label: 'List'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpListPresenter).

		  (DdWidgetDescriptor new
			   label: 'Combobox'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: ComboBoxPresenter).

		  (DdWidgetDescriptor new
			   label: 'Checkbox'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpCheckBoxPresenter).

		  (DdWidgetDescriptor new
			   label: 'Group of radiobuttons'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: RadioGroupPresenter).

		  (DdWidgetDescriptor new
			   label: 'Group of checkboxes'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: CheckboxGroupPresenter).

		  (DdWidgetDescriptor new
			   label: 'Progress bar'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpProgressBarPresenter).

		  (DdWidgetDescriptor new
			   label: 'Slider'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpSliderPresenter).

		  (DdWidgetDescriptor new
			   label: 'Date picker'
			   icon: (Smalltalk ui icons iconNamed: #calendar)
			   presenter: SpDatePresenter).

		  (DdWidgetDescriptor new
			   label: 'Time picker'
			   icon: (Smalltalk ui icons iconNamed: #calendar)
			   presenter: TimePickerPresenter).

		  (DdWidgetDescriptor new
			   label: 'Table'
			   icon: (Smalltalk ui icons iconNamed: #table)
			   presenter: PaginatedTablePresenter).

		  (DdWidgetDescriptor new
			   label: 'Tree'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: SpTreePresenter) }
]
