"
I am the property descriptor for list widgets. I extend the items management panel with a button that loads items from a .txt file.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdItemsPropertyDescriptor`
`DdListPropertyDescriptor` (this is me)
"
Class {
	#name : 'DdListPropertyDescriptor',
	#superclass : 'DdItemsPropertyDescriptor',
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdListPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 
	self addItemsFieldsTo: aPanel for: aPresenter.
	
	aPanel
		add: (SpButtonPresenter new
			label: 'Load from file...';
			action: [ self loadFromFile ];
			yourself)
		expand: false
]

{ #category : 'adding' }
DdListPropertyDescriptor >> collectPropertiesWithVarName: varName [ 
	| result |
	result := super collectPropertiesWithVarName: varName.
	self collectItemsPropertiesWith: varName into: result.
	^ result
]

{ #category : 'as yet unclassified' }
DdListPropertyDescriptor >> loadFromFile [ 
"Opens a file picker for .txt files, reads non-empty lines, and loads them into the items list."

	| entries ref lines |
	[ 
		entries := StOpenFilePresenter new
			extensions: #('txt');
			openModal.
		entries ifNil: [ ^ self ].
		ref := entries first.
		lines := ref readStream contents lines
			reject: [ :l | l trim isEmpty ].
		itemsList items: lines asOrderedCollection.
		self onItemsChanged: lines asArray
	] on: Error do: [ self inform: 'Cannot open file' ]
]

{ #category : 'as yet unclassified' }
DdListPropertyDescriptor >> onItemsChanged: newItems [
]
