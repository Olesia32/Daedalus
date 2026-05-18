"
I am the property descriptor for checkbox group widgets. I extend the group descriptor with a multi-selection list and a clear button
that lets the user control which checkboxes are pre-checked.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdItemsPropertyDescriptor`
`DdGroupPropertyDescriptor`
`DdCheckboxGroupPropertyDescriptor` (this is me)

### Instance Variables
- _selectionCombo_: `SpListPresenter` — multi-selection list of current items
- _clearSelectionButton_: `SpButtonPresenter` — clears all selected items
"
Class {
	#name : 'DdCheckboxGroupPropertyDescriptor',
	#superclass : 'DdGroupPropertyDescriptor',
	#instVars : [
		'selectionCheckboxes',
		'clearSelectionButton',
		'selectionPanel',
		'targetPresenter'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdCheckboxGroupPropertyDescriptor >> addSelectionFieldsTo: aPanel for: aPresenter [ 
    selectionPanel := aPanel.
    targetPresenter := aPresenter.
    self rebuildSelectionCheckboxes.
]

{ #category : 'adding' }
DdCheckboxGroupPropertyDescriptor >> addSelectionPropertiesTo: result varName: varName [ 
    
    | indexes |
    indexes := OrderedCollection new.
    
    selectionCheckboxes withIndexDo: [ :cb :i |
        cb state ifTrue: [ indexes add: i ] ].
    
    result add: (DdKeywordProperties new
        varName: varName;
        selector: 'selectedIndexes:';
        value: indexes asArray;
        yourself).
]

{ #category : 'as yet unclassified' }
DdCheckboxGroupPropertyDescriptor >> onItemsChanged: newItems [ 
"Replaces the items in the selection list with newItems when the group's item collection changes."

    (selectionPanel isNil or: [ targetPresenter isNil ]) ifTrue: [ ^ self ].
    self rebuildSelectionCheckboxes.
]

{ #category : 'as yet unclassified' }
DdCheckboxGroupPropertyDescriptor >> rebuildSelectionCheckboxes [ 
    
    selectionCheckboxes := OrderedCollection new.
    selectionPanel add: (SpLabelPresenter new label: 'Selected items') expand: false.
    targetPresenter items doWithIndex: [ :item :i |
        | cb |
        cb := SpCheckBoxPresenter new.
        cb label: item asString.
        [ cb state: (targetPresenter isCheckedAt: i) ] on: Error do: [].
        selectionCheckboxes add: cb.
        selectionPanel add: cb expand: false ].
]
