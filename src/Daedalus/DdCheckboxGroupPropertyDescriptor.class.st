Class {
	#name : 'DdCheckboxGroupPropertyDescriptor',
	#superclass : 'DdGroupPropertyDescriptor',
	#instVars : [
		'selectionCombo',
		'clearSelectionButton'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdCheckboxGroupPropertyDescriptor >> addSelectionFieldsTo: aPanel for: aPresenter [ 

    selectionCombo := SpListPresenter new.
    selectionCombo
        display: [ :each | each asString ];
        beMultipleSelection.

    "Відновлюємо вибір"
    [ 
        | selected |
        selected := aPresenter selectedItems.
        selected ifNotEmpty: [
            selectionCombo selectItems: selected ]
    ] on: Error do: [ ].

    clearSelectionButton := SpButtonPresenter new.
    clearSelectionButton
        label: 'Clear selection';
        action: [
            selectionCombo unselectAll.
            [ aPresenter clearSelection ] on: Error do: [ ] ].

    aPanel
        add: (self rowFor: 'Selected' input: selectionCombo)
            withConstraints: [ :c | c height: 80 ];
        add: clearSelectionButton expand: false.
]

{ #category : 'adding' }
DdCheckboxGroupPropertyDescriptor >> addSelectionPropertiesTo: result varName: varName [ 

    | indexes |
    indexes := selectionCombo selectedItems
        collect: [ :item | selectionCombo allItems indexOf: item ]
        thenSelect: [ :i | i > 0 ].
    indexes ifNotEmpty: [
        result add: (DdGenericProperties new
            varName: varName; selector: 'selectedIndexes:'; value: indexes asArray; yourself) ].
]

{ #category : 'as yet unclassified' }
DdCheckboxGroupPropertyDescriptor >> onItemsChanged: newItems [ 
    selectionCombo items: newItems.
]
