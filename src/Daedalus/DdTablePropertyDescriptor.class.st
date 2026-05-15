Class {
	#name : 'DdTablePropertyDescriptor',
	#superclass : 'DdItemsPropertyDescriptor',
	#instVars : [
		'columnLabelInput',
		'columnKeyInput',
		'columnsList',
		'addColumnButton',
		'removeColumnButton'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdTablePropertyDescriptor >> addColumn [ 
	| label key items |
	label := columnLabelInput text.
	key := columnKeyInput text.
	(label isEmpty or: [ key isEmpty ]) ifTrue: [ ^ self ].
	items := columnsList items asOrderedCollection.
	items add: label -> key asSymbol.
	columnsList items: items.
	columnLabelInput text: ''.
	columnKeyInput text: ''.
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 

	"Секція колонок"
	columnsList := SpListPresenter new.
	columnsList
		display: [ :assoc | assoc key , ' → ' , assoc value asString ];
		items: ([ aPresenter columns asOrderedCollection ]
			on: Error do: [ OrderedCollection new ]).

	columnLabelInput := SpTextInputFieldPresenter new.
	columnKeyInput := SpTextInputFieldPresenter new.

	columnsList whenSelectionChangedDo: [ :sel |
		sel selectedItem ifNotNil: [ :assoc |
			columnLabelInput text: assoc key.
			columnKeyInput text: assoc value asString ] ].

	addColumnButton := SpButtonPresenter new
		label: 'Add';
		action: [ self addColumn ];
		yourself.

	removeColumnButton := SpButtonPresenter new
		label: 'Remove';
		action: [ self removeColumn ];
		yourself.

	aPanel
		add: 'Columns' expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 4;
			add: (self rowFor: 'Label' input: columnLabelInput);
			add: (self rowFor: 'Key' input: columnKeyInput);
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 4;
			add: addColumnButton;
			add: removeColumnButton;
			yourself) expand: false;
		add: columnsList
			withConstraints: [ :c | c height: 80 ].

	"Секція даних — з DdItemsPropertyDescriptor"
	aPanel add: 'Items' expand: false.
	self addItemsFieldsTo: aPanel for: aPresenter.
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> collectPropertiesWithVarName: varName [ 
	| result |
	result := super collectPropertiesWithVarName: varName.

	columnsList items ifNotEmpty: [ :cols |
		result add: (DdGenericProperties new
			varName: varName;
			selector: 'columns:';
			value: cols asArray;
			yourself) ].

	^ result
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> onItemsChanged: newItems [ 
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> removeColumn [ 
	| sel items |
	sel := columnsList selectedItem.
	sel ifNil: [ ^ self ].
	items := columnsList items asOrderedCollection.
	items remove: sel ifAbsent: [ ].
	columnsList items: items.
]
