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

	itemsList := SpListPresenter new.
itemsList
    display: self itemDisplayBlock;
    items: ([ aPresenter items asOrderedCollection ]
        on: Error do: [ OrderedCollection new ]).

	addItemInput := SpTextInputFieldPresenter new.

	addItemButton := SpButtonPresenter new.
	addItemButton
		label: 'Add';
		action: [
				| text currentItems |
				text := addItemInput text.
				text ifNotEmpty: [
							currentItems := itemsList items asOrderedCollection.
							currentItems add: text.
							[ aPresenter items: currentItems asArray ]
								on: Error
								do: [ ].
							itemsList items: currentItems.
							addItemInput text: ''.
							self onItemsChanged: currentItems asArray ] ].

	removeItemButton := SpButtonPresenter new.
	removeItemButton
		label: 'Remove';
		action: [
				| sel currentItems |
				sel := itemsList selectedItem.
				sel ifNotNil: [
							currentItems := itemsList items asOrderedCollection.
							currentItems remove: sel ifAbsent: [ ].
							[ aPresenter items: currentItems asArray ]
								on: Error
								do: [ ].
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

    itemsList items ifNotEmpty: [ :items |
        result add: (DdGenericProperties new
            varName: varName;
            selector: 'items:';
            value: items asArray;
            yourself) ].
]

{ #category : 'as yet unclassified' }
DdItemsPropertyDescriptor >> itemDisplayBlock [ 
    ^ [ :item | item printString ]
]

{ #category : 'as yet unclassified' }
DdItemsPropertyDescriptor >> onItemsChanged: newItems [ 
]
