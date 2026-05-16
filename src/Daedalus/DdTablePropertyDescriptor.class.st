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
    | label key |
    label := columnLabelInput text.
    key := columnKeyInput text.
    (label isEmpty or: [ key isEmpty ]) ifTrue: [ ^ self ].
    columnsList items: (columnsList items asOrderedCollection
        add: label -> key asSymbol;
        yourself).
    columnLabelInput text: ''.
    columnKeyInput text: ''.
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> addSpecificFieldsTo: aPanel for: aPresenter [

	columnsList := SpListPresenter new.
	columnsList
    display: [ :assoc | assoc key , ' → ' , assoc value asString ];
    items: ([| src |
        aPresenter columns
            collect: [ :col | 
                src := col evaluation sourceNode printString.
                col title -> (src copyFrom: (src indexOf: $#) + 1 to: src size - 2) ]
            as: OrderedCollection ]
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
				 yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
				 spacing: 4;
				 add: addColumnButton;
				 add: removeColumnButton;
				 yourself)
		expand: false;
		add: columnsList withConstraints: [ :c | c height: 80 ].

	aPanel add: 'Items' expand: false.
	self addItemsFieldsTo: aPanel for: aPresenter.
	aPanel
		add: (SpButtonPresenter new
				 label: 'Load from CSV...';
				 action: [ self loadFromFile ];
				 yourself)
		expand: false
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> collectPropertiesWithVarName: varName [

	| result |
	result := OrderedCollection new.

	result add: (DdUnaryProperties new
			 varName: varName;
			 selector: 'removeAllColumns';
			 yourself).
	result addAll: (columnsList items collect: [ :assoc |
				 DdTableColumnProperties new
					 varName: varName;
					 label: assoc key;
					 key: assoc value;
					 yourself ]).
	itemsList items ifNotEmpty: [ :items |
			result add: (DdGenericProperties new
					 varName: varName;
					 selector: 'items:';
					 value: items asArray;
					 yourself) ].

	^ result
]

{ #category : 'as yet unclassified' }
DdTablePropertyDescriptor >> itemDisplayBlock [ 
    ^ [ :item |
        item isDictionary
            ifTrue: [ item keys inject: '' into: [ :acc :k |
                acc , (acc isEmpty ifTrue: [ '' ] ifFalse: [ ', ' ])
                    , k , ': ' , (item at: k) printString ] ]
            ifFalse: [ item printString ] ]
]

{ #category : 'as yet unclassified' }
DdTablePropertyDescriptor >> loadFromFile [ 
    | ref lines headers items |
    [
        ref := (StOpenFilePresenter new
            extensions: #('csv');
            openModal) ifNil: [ ^ self ].
        ref := ref first.
        lines := ref readStream contents lines
            reject: [ :l | l trim isEmpty ].
        lines isEmpty ifTrue: [ ^ self ].

        headers := lines first substrings: ','.
        columnsList items: (headers collect: [ :h |
            h trim -> h trim asSymbol ]
            as: OrderedCollection).

        items := lines allButFirst collect: [ :line |
            | values dict |
            values := line substrings: ','.
            dict := Dictionary new.
            headers doWithIndex: [ :header :i |
                dict
                    at: header trim asSymbol
                    put: (values at: i ifAbsent: [ '' ]) trim ].
            dict ].

        itemsList items: items asOrderedCollection.
        self onItemsChanged: items asArray.
    ] on: Error do: [ self inform: 'Cannot open file' ]
]

{ #category : 'adding' }
DdTablePropertyDescriptor >> onItemsChanged: newItems [ 
]

{ #category : 'removing' }
DdTablePropertyDescriptor >> removeColumn [ 
    | sel |
    sel := columnsList selectedItem.
    sel ifNil: [ ^ self ].
    columnsList items: (columnsList items asOrderedCollection
        remove: sel ifAbsent: [ ];
        yourself).
]
