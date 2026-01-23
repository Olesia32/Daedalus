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
			   presenter: (PresenterDecorator wrap: SpTextPresenter)).

		  (DdWidgetDescriptor new
			   label: 'List'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: ListPresenter).

		  (DdWidgetDescriptor new
			   label: 'Combobox'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: ComboBoxPresenter).

		  (DdWidgetDescriptor new
			   label: 'Checkbox'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpCheckBoxPresenter)).

		  (DdWidgetDescriptor new
			   label: 'Radio button'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: RadioGroupPresenter).

		  (DdWidgetDescriptor new
			   label: 'Group of checkboxes'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: CheckboxGroupPresenter).

		  (DdWidgetDescriptor new
			   label: 'Toggle button'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpToggleButtonPresenter)).

		  (DdWidgetDescriptor new
			   label: 'Image'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpImagePresenter)).

		  (DdWidgetDescriptor new
			   label: 'Progress bar'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpProgressBarPresenter)).

		  (DdWidgetDescriptor new
			   label: 'Slider'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpSliderPresenter)).

		  (DdWidgetDescriptor new
			   label: 'Date picker'
			   icon: (Smalltalk ui icons iconNamed: #calendar)
			   presenter: (PresenterDecorator wrap: SpDatePresenter)).

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
			   presenter: (PresenterDecorator wrap: SpTreePresenter)).

		  (DdWidgetDescriptor new
			   label: 'Notebook'
			   icon: (Smalltalk ui icons iconNamed: #add)
			   presenter: (PresenterDecorator wrap: SpNotebookPresenter)). }
]
