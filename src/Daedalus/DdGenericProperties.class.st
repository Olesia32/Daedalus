Class {
	#name : 'DdGenericProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'selector',
		'value'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'operations' }
DdGenericProperties >> applyTo: aPresenter [ 
    [ aPresenter perform: selector asSymbol with: value ] on: Error do: [ ]
]

{ #category : 'translating' }
DdGenericProperties >> patchSource: anAst [ 
    | existing newNode initNode |
    existing := anAst body statements
        detect: [ :stmt |
            stmt isMessage
                and: [ stmt receiver isVariable
                and: [ stmt receiver name = varName
                and: [ stmt selector = selector ] ] ] ]
        ifNone: [ nil ].
    existing ifNotNil: [
        existing arguments first replaceWith:
            (RBLiteralValueNode value: value).
        ^ anAst ].
    initNode := anAst body statements
        detect: [ :stmt | stmt isAssignment and: [ stmt variable name = varName ] ]
        ifNone: [ nil ].
    initNode ifNil: [ ^ anAst ].
    newNode := RBParser parseExpression:
        varName , ' ' , selector , ' ' , value printString.
    anAst body addNode: newNode after: initNode.
    ^ anAst
]

{ #category : 'accessing' }
DdGenericProperties >> selector [

	^ selector
]

{ #category : 'accessing' }
DdGenericProperties >> selector: anObject [

	selector := anObject
]

{ #category : 'accessing' }
DdGenericProperties >> value1 [

	^ value
]

{ #category : 'accessing' }
DdGenericProperties >> value: anObject [

	value := anObject
]
