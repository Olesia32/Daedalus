Class {
	#name : 'DdWidgetPalettePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'tree'
	],
	#category : 'Daedalus',
	#package : 'Daedalus'
}

{ #category : 'layout' }
DdWidgetPalettePresenter >> defaultLayout [

	^ SpBoxLayout new add: tree; yourself 
]

{ #category : 'initialization' }
DdWidgetPalettePresenter >> initializePresenters [

	tree := SpTreePresenter new.
	tree display: [ :each | each name ].
	tree children: [ :each | each children ].
	tree roots: self widgetGroups
]

{ #category : 'as yet unclassified' }
DdWidgetPalettePresenter >> widgetGroups [

	^ {
		  (DdWidgetGroup new name: 'Standard Widgets' items: {
				   (DdWidgetItem new name: 'Button' presenterClass: SpButtonPresenter).
				   (DdWidgetItem new name: 'Label' presenterClass: SpLabelPresenter).
				   (DdWidgetItem new
					    name: 'TextInput'
					    presenterClass: TextInputPresenter) }).

		  (DdWidgetGroup new name: 'Layouts' items: {
				   (DdWidgetItem new name: 'VBox' presenterClass: SpBoxLayout).
				   (DdWidgetItem new name: 'HBox' presenterClass: SpBoxLayout) }).

		  (DdWidgetGroup new name: 'Advanced' items: {
				   (DdWidgetItem new name: 'List' presenterClass: SpListPresenter).
				   (DdWidgetItem new
					    name: 'Checkbox'
					    presenterClass: SpCheckBoxPresenter) }) }
]
