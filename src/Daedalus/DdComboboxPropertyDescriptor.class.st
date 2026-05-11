Class {
	#name : 'DdComboboxPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'itemsInput',
		'selectedIndexInput',
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
DdComboboxPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [

	itemsList := SpListPresenter new.
	itemsList display: [ :each | each asString ].

	[ itemsList items: aPresenter allItems asOrderedCollection ]
		on: Error
		do: [ itemsList items: #(  ) ].
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
							addItemInput text: '' ] ].

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
							itemsList items: currentItems ] ].

	selectedIndexInput := SpTextInputFieldPresenter new.
	[ selectedIndexInput text: aPresenter selectedIndex asString ]
		on: Error
		do: [ ].

	aPanel
		add: (self rowFor: 'Items' input: itemsList)
		withConstraints: [ :c | c height: 50 ];
		add: (self rowFor: 'New item' input: addItemInput) expand: false;
		add: (SpBoxLayout newLeftToRight
				 spacing: 4;
				 add: addItemButton;
				 add: removeItemButton;
				 yourself)
		expand: false;
		add: (self rowFor: 'Selected index' input: selectedIndexInput)
		expand: false
]

{ #category : 'as yet unclassified' }
DdComboboxPropertyDescriptor >> collectPropertiesWithVarName: varName [ 

    | result |
    result := super collectPropertiesWithVarName: varName.

    itemsList items ifNotEmpty: [ :items |
        result add: (DdGenericProperties new
            varName: varName;
            selector: 'items:';
            value: items asArray;
            yourself) ].

    selectedIndexInput text ifNotEmpty: [ :v |
        result add: (DdGenericProperties new
            varName: varName;
            selector: 'selectIndex:';
            value: v asInteger;
            yourself) ].

    ^ result
]
