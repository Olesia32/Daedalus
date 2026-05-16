Class {
	#name : 'DdTableColumnProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'label',
		'key'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
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
