Class {
	#name : 'DdGroupPropertyDescriptor',
	#superclass : 'DdBasePresenterPropertyDescriptor',
	#instVars : [
		'titleInput',
		'columnCountInput',
		'showTitleCheckbox',
		'showFrameCheckbox',
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
DdGroupPropertyDescriptor >> addSelectionFieldsTo: aPanel for: aPresenter [ 
    ^ self subclassResponsibility
]

{ #category : 'adding' }
DdGroupPropertyDescriptor >> addSelectionPropertiesTo: result varName: varName [ 
    ^ self subclassResponsibility
]

{ #category : 'adding' }
DdGroupPropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [ 

    titleInput := SpTextInputFieldPresenter new.
    columnCountInput := SpTextInputFieldPresenter new.
    showTitleCheckbox := SpCheckBoxPresenter new label: 'Show title'.
    showFrameCheckbox := SpCheckBoxPresenter new label: 'Show frame'.

    itemsList := SpListPresenter new.
    itemsList display: [ :each | each asString ].
    [ itemsList items: aPresenter items asOrderedCollection ]
        on: Error do: [ itemsList items: #() ].

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
                [ aPresenter items: currentItems asArray ] on: Error do: [ ].
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
                [ aPresenter items: currentItems asArray ] on: Error do: [ ].
                itemsList items: currentItems.
                self onItemsChanged: currentItems asArray ] ].

    [ titleInput text: aPresenter title ] on: Error do: [ ].
    [ columnCountInput text: aPresenter columnCount asString ] on: Error do: [ ].
    [ showTitleCheckbox state: aPresenter showTitle ] on: Error do: [ ].
    [ showFrameCheckbox state: aPresenter showFrame ] on: Error do: [ ].

    aPanel
        add: (self rowFor: 'Title' input: titleInput) expand: false;
        add: (self rowFor: 'Columns' input: columnCountInput) expand: false;
        add: showTitleCheckbox expand: false;
        add: showFrameCheckbox expand: false;
        add: (self rowFor: 'Items' input: itemsList)
            withConstraints: [ :c | c height: 50 ];
        add: (self rowFor: 'New item' input: addItemInput) expand: false;
        add: (SpBoxLayout newLeftToRight
                spacing: 4;
                add: addItemButton;
                add: removeItemButton;
                yourself) expand: false.

    self addSelectionFieldsTo: aPanel for: aPresenter.
]

{ #category : 'as yet unclassified' }
DdGroupPropertyDescriptor >> collectPropertiesWithVarName: varName [ 

    | result |
    result := super collectPropertiesWithVarName: varName.

    titleInput text ifNotEmpty: [ :v |
        result add: (DdGenericProperties new
            varName: varName; selector: 'title:'; value: v; yourself) ].

    columnCountInput text ifNotEmpty: [ :v |
        result add: (DdGenericProperties new
            varName: varName; selector: 'сolumnCount:'; value: v asInteger; yourself) ].

    result add: (DdGenericProperties new
        varName: varName; selector: 'showTitle:'; value: showTitleCheckbox state; yourself).

    result add: (DdGenericProperties new
        varName: varName; selector: 'showFrame:'; value: showFrameCheckbox state; yourself).

    itemsList items ifNotEmpty: [ :items |
        result add: (DdGenericProperties new
            varName: varName; selector: 'items:'; value: items asArray; yourself) ].

    "Підкласи додають свою selection-частину"
    self addSelectionPropertiesTo: result varName: varName.

    ^ result

]

{ #category : 'as yet unclassified' }
DdGroupPropertyDescriptor >> onItemsChanged: newItems [ 
    "Hook — підкласи оновлюють залежні selection-компоненти"
]
