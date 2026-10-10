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
	#name : 'DdKeywordProperties',
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
DdKeywordProperties >> applyTo: aPresenter [ 
"Sends selector asSymbol with value to aPresenter for immediate live preview, silently ignoring errors."
    
    aPresenter perform: selector asSymbol with: value 
]

{ #category : 'translating' }
DdKeywordProperties >> patchSource: anAst [
	"Finds every varName selector: call in anAst - as a plain statement or inside a cascade on
	varName - and replaces its argument with value; if none exists, inserts a new statement
	after the variable's assignment node."

	| matches newNode initNode |
	matches := OrderedCollection new.
	anAst body statements do: [ :stmt |
		(stmt isMessage or: [ stmt isCascade ]) ifTrue: [
			(stmt isCascade
				 ifTrue: [ stmt messages ]
				 ifFalse: [ { stmt } ]) do: [ :msg |
				(msg receiver isVariable and: [
					 msg receiver name = varName and: [
						 msg selector = selector asSymbol ] ]) ifTrue: [
					matches add: msg ] ] ] ].
	matches ifNotEmpty: [
		matches do: [ :msg |
			msg arguments first replaceWith:
				(OCParser parseExpression: value printString) ].
		^ anAst ].
	initNode := anAst body statements
		            detect: [ :stmt |
		            stmt isAssignment and: [ stmt variable name = varName ] ]
		            ifNone: [ nil ].
	initNode ifNil: [ ^ anAst ].
	newNode := OCParser parseExpression:
		           varName , ' ' , selector , ' ' , value printString.
	anAst body addNode: newNode after: initNode.
	^ anAst
]

{ #category : 'accessing' }
DdKeywordProperties >> selector [

	^ selector
]

{ #category : 'accessing' }
DdKeywordProperties >> selector: anObject [

	selector := anObject
]

{ #category : 'accessing' }
DdKeywordProperties >> value1 [

	^ value
]

{ #category : 'accessing' }
DdKeywordProperties >> value: anObject [

	value := anObject
]
