"
I represent a single addColumn: call on a table presenter. I carry a column label and a data key, and I know how to both apply the
column to a live presenter and patch the source AST with the corresponding addColumn: expression.

### Hierarchy
`Object`
`DdPresenterProperties`
`DdTableColumnProperties` (this is me)

### Instance Variables
- _label_: `String` — the column header text shown in the table
- _key_: `Symbol` — the dictionary key used to extract the cell value
"
Class {
	#name : 'DdTableColumnProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'label',
		'key'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'operations' }
DdTableColumnProperties >> applyTo: aPresenter [

	[aPresenter addColumn:
			(SpStringTableColumn title: label evaluated: [ :p | p at: key ]) ]
		on: Error
		do: [ ]
]

{ #category : 'accessing' }
DdTableColumnProperties >> key: anObject [

	key := anObject
]

{ #category : 'accessing' }
DdTableColumnProperties >> label: anObject [

	label := anObject
]

{ #category : 'translating' }
DdTableColumnProperties >> patchSource: anAst [ 
    | initNode newNode |
    initNode := anAst body statements
        detect: [ :stmt | stmt isAssignment and: [ stmt variable name = varName ] ]
        ifNone: [ nil ].
    initNode ifNil: [ ^ anAst ].
    newNode := RBParser parseExpression: varName
        , ' addColumn: (SpStringTableColumn title: '
        , label printString
        , ' evaluated: [ :p | p at: '
        , key printString , ' ])'.
    anAst body addNode: newNode after: initNode.
    ^ anAst
]
