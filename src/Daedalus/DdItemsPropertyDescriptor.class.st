"
I am the base class for descriptors that manage a list of items. I provide a reusable items list with add and remove buttons, and
a hook for subclasses to react when the item collection changes.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdItemsPropertyDescriptor` (this is me)
"
Class {
	#name : 'DdItemsPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'itemsList',
		'addItemInput',
		'addItemButton',
		'removeItemButton'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdItemsPropertyDescriptor >> addItemsFieldsTo: aPanel for: aPresenter [
"Builds the items list, add/remove buttons and new-item input field, wires their actions, and adds all of them to aPanel."

	itemsList := SpListPresenter new.
	itemsList
		display: self itemDisplayBlock;
		items: ([ aPresenter items asOrderedCollection ]
				 on: Error
				 do: [ OrderedCollection new ]).

	addItemInput := SpTextInputFieldPresenter new.

	addItemButton := SpButtonPresenter new.
	removeItemButton := SpButtonPresenter new.
	addItemButton
		label: 'Add';
		action: [
				| text currentItems |
				text := addItemInput text.
				text ifNotEmpty: [
							currentItems := itemsList items asOrderedCollection.
							currentItems add: text.
							itemsList items: currentItems.
							addItemInput text: ''.
							self onItemsChanged: currentItems asArray ] ].

	removeItemButton
		label: 'Remove';
		action: [
				| sel currentItems |
				sel := itemsList selectedItem.
				sel ifNotNil: [
							currentItems := itemsList items asOrderedCollection.
							currentItems remove: sel ifAbsent: [ ].
							itemsList items: currentItems.
							self onItemsChanged: currentItems asArray ] ].

	aPanel
		add: (self rowFor: 'Items' input: itemsList)
		withConstraints: [ :c | c height: 80 ];
		add: (self rowFor: 'New item' input: addItemInput) expand: false;
		add: (SpBoxLayout newLeftToRight
				 spacing: 4;
				 add: addItemButton;
				 add: removeItemButton;
				 yourself)
		expand: false
]

{ #category : 'as yet unclassified' }
DdItemsPropertyDescriptor >> collectItemsPropertiesWith: varName into: result [
"Appends a DdGenericProperties for items: to result if the items list is non-empty."

	itemsList items ifNotEmpty: [ :items |
			result add: (DdKeywordProperties new
					 varName: varName;
					 selector: 'items:';
					 value: items asArray;
					 yourself) ]
]

{ #category : 'as yet unclassified' }
DdItemsPropertyDescriptor >> itemDisplayBlock [
"Returns the block used to display each item in the list. Subclasses may override to customise the display string."

	^ [ :item | item printString ]
]

{ #category : 'as yet unclassified' }
DdItemsPropertyDescriptor >> onItemsChanged: newItems [
"Called after the item collection changes. Empty by default; subclasses override to propagate the new list to dependent UI."

	
]
