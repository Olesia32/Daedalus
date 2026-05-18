"
I represent a single unary message of the form `varName selector`. For toggle-style selectors such as beWrapWord / beNotWrapWord I also
remove the semantic opposite before inserting the new call.

### Hierarchy
`Object`
`DdPresenterProperties`
`DdUnaryProperties` (this is me)

### Instance Variables
- _selector_: `String` — the unary selector to send, e.g. `'beWrapWord'`
"
Class {
	#name : 'DdUnaryProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'selector',
		'oppositeSelector',
		'state'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'accessing' }
DdUnaryProperties >> applyTo: aPresenter [ 
    state
        ifTrue: [ [ aPresenter perform: selector asSymbol ] on: Error do: [ ] ]
        ifFalse: [  ]
]

{ #category : 'accessing' }
DdUnaryProperties >> initialize [ 
    super initialize.
    state := true.
    oppositeSelector := nil.
]

{ #category : 'accessing' }
DdUnaryProperties >> oppositeSelector: aString [ 
    oppositeSelector := aString
]

{ #category : 'accessing' }
DdUnaryProperties >> patchSource: anAst [
	"Removes any existing call to selector or its opposite from anAst.
    If state is true, inserts a fresh call after the variable's assignment node."

	| toRemove initNode newNode |
	toRemove := anAst body statements select: [ :stmt |
			            stmt isMessage and: [
					            stmt receiver isVariable and: [
							            stmt receiver name = varName and: [
									            stmt selector = selector or: [
										            oppositeSelector notNil and: [
											            stmt selector = oppositeSelector ] ] ] ] ] ].
	toRemove do: [ :node | anAst body removeNode: node ].

	state ifFalse: [ ^ anAst ].

	initNode := anAst body statements
		            detect: [ :stmt |
		            stmt isAssignment and: [ stmt variable name = varName ] ]
		            ifNone: [ nil ].
	initNode ifNil: [ ^ anAst ].

	newNode := OCParser parseExpression: varName , ' ' , selector.
	anAst body addNode: newNode after: initNode.
	^ anAst
]

{ #category : 'accessing' }
DdUnaryProperties >> selector: aString [ 
	selector := aString
]

{ #category : 'accessing' }
DdUnaryProperties >> state: aBoolean [ 
    state := aBoolean
]
