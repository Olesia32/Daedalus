"
I am the base descriptor for group widgets (radio groups, checkbox groups). I manage title, column count, show-title and show-frame
toggles, items, and a selection sub-panel that subclasses must implement.

### Hierarchy
`Object`
`DdPropertyDescriptor`
`DdBasePresenterPropertyDescriptor`
`DdItemsPropertyDescriptor`
`DdGroupPropertyDescriptor` (this is me)

### Instance Variables
- _titleInput_: `SpTextInputFieldPresenter` — edits the group title
- _columnCountInput_: `SpTextInputFieldPresenter` — edits the column count
- _showTitleCheckbox_: `SpCheckBoxPresenter` — toggles title visibility
- _showFrameCheckbox_: `SpCheckBoxPresenter` — toggles frame visibility
"
Class {
	#name : 'DdGroupPropertyDescriptor',
	#superclass : 'DdItemsPropertyDescriptor',
	#instVars : [
		'titleInput',
		'columnCountInput',
		'showTitleCheckbox',
		'showFrameCheckbox'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'adding' }
DdGroupPropertyDescriptor >> addSelectionFieldsTo: aPanel for: aPresenter [ 
"Abstract. Subclasses add their selection UI fields to aPanel."

    ^ self subclassResponsibility
]

{ #category : 'adding' }
DdGroupPropertyDescriptor >> addSelectionPropertiesTo: result varName: varName [ 
"Abstract. Subclasses append selection-related DdPresenterProperties to result."

    ^ self subclassResponsibility
]

{ #category : 'adding' }
DdGroupPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 

    titleInput := SpTextInputFieldPresenter new.
    columnCountInput := SpTextInputFieldPresenter new.
    showTitleCheckbox := SpCheckBoxPresenter new label: 'Show title'.
    showFrameCheckbox := SpCheckBoxPresenter new label: 'Show frame'.

    [ titleInput text: aPresenter title ] on: Error do: [ ].
    [ columnCountInput text: aPresenter columnCount asString ] on: Error do: [ ].
    [ showTitleCheckbox state: aPresenter showTitle ] on: Error do: [ ].
    [ showFrameCheckbox state: aPresenter showFrame ] on: Error do: [ ].

    aPanel
        add: (self rowFor: 'Title' input: titleInput) expand: false;
        add: (self rowFor: 'Columns' input: columnCountInput) expand: false;
        add: showTitleCheckbox expand: false;
        add: showFrameCheckbox expand: false.

    self addItemsFieldsTo: aPanel for: aPresenter.
    self addSelectionFieldsTo: aPanel for: aPresenter.
]

{ #category : 'as yet unclassified' }
DdGroupPropertyDescriptor >> collectPropertiesWithVarName: varName [ 

    | result |
    result := super collectPropertiesWithVarName: varName.

    titleInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'title:'; value: v; yourself) ].

    columnCountInput text ifNotEmpty: [ :v |
        result add: (DdKeywordProperties new
            varName: varName; selector: 'сolumnCount:'; value: v asInteger; yourself) ].

    result add: (DdKeywordProperties new
        varName: varName; selector: 'showTitle:'; value: showTitleCheckbox state; yourself).

    result add: (DdKeywordProperties new
        varName: varName; selector: 'showFrame:'; value: showFrameCheckbox state; yourself).

    self collectItemsPropertiesWith: varName into: result.
    self addSelectionPropertiesTo: result varName: varName.

    ^ result
]

{ #category : 'as yet unclassified' }
DdGroupPropertyDescriptor >> onItemsChanged: newItems [ 
    "Hook called when the item collection changes. Empty by default; subclasses update dependent selection UI here."
]
