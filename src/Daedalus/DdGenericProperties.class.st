"
I represent a single keyword message of the form `varName selector: value`. I know how to find and replace an
existing call in the AST, or insert a new one after the variable's assignment node.

### Hierarchy
`Object`
`DdPresenterProperties`
`DdGenericProperties` (this is me)

### Instance Variables
- _selector_: `String` — the keyword selector, e.g. `'items:'`
- _value_: `Object` — the argument to pass, e.g. a `String` or `Array`
"
Class {
	#name : 'DdGenericProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'selector',
		'value'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'operations' }
DdGenericProperties >> applyTo: aPresenter [ 
"Sends selector asSymbol with value to aPresenter for immediate live preview, silently ignoring errors."
    
    aPresenter perform: selector asSymbol with: value 
]

{ #category : 'translating' }
DdGenericProperties >> patchSource: anAst [ 
"Finds an existing varName selector: call in anAst and replaces its argument with value; if none exists, inserts a new statement after
the variable's assignment node."

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
