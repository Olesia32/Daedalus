Class {
	#name : 'DdTextProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'text'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'operations' }
DdTextProperties >> applyTo: aPresenter [ 
    aPresenter label: text
]

{ #category : 'translating' }
DdTextProperties >> patchSource: anAst [
    | assignNode |
    assignNode := anAst body statements
        detect: [ :stmt |
            stmt isMessage
                and: [ stmt receiver isVariable
                and: [ stmt receiver name = varName
                and: [ stmt selector = #label: ] ] ] ]
        ifNone: [ nil ].

    assignNode
        ifNotNil: [
            assignNode arguments first replaceWith:
                (RBLiteralValueNode value: text) ]
        ifNil: [
            | initNode newNode |
            initNode := anAst body statements
                detect: [ :stmt |
                    stmt isAssignment
                        and: [ stmt variable name = varName ] ]
                ifNone: [ nil ].
            initNode ifNil: [ ^ anAst ].
            newNode := RBParser parseExpression:
                varName , ' label: ' , text printString.
            anAst body addNode: newNode after: initNode ].

    ^ anAst
]

{ #category : 'accessing' }
DdTextProperties >> text [

	^ text
]

{ #category : 'accessing' }
DdTextProperties >> text: anObject [

	text := anObject
]
