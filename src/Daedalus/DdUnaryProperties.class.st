Class {
	#name : 'DdUnaryProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'selector'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'operations' }
DdUnaryProperties >> applyTo: aPresenter [ 
	[ aPresenter perform: selector asSymbol ] on: Error do: [ ]
]

{ #category : 'translating' }
DdUnaryProperties >> patchSource: anAst [

	| oppositeSelector toRemove initNode newNode |
	oppositeSelector := selector = 'beWrapWord'
		                    ifTrue: [ 'beNotWrapWord' ]
		                    ifFalse: [
		                    selector = 'beNotWrapWord' ifTrue: [
			                    'beWrapWord' ] ].

	toRemove := anAst body statements select: [ :stmt |
			            stmt isMessage and: [
					            stmt receiver isVariable and: [
							            stmt receiver name = varName and: [
									            stmt selector = selector or: [
										            oppositeSelector notNil and: [
											            stmt selector = oppositeSelector ] ] ] ] ] ].

	toRemove do: [ :node | anAst body removeNode: node ].

	initNode := anAst body statements
		            detect: [ :stmt |
		            stmt isAssignment and: [ stmt variable name = varName ] ]
		            ifNone: [ nil ].

	initNode ifNil: [ ^ anAst ].

	newNode := RBParser parseExpression: varName , ' ' , selector.
	anAst body addNode: newNode after: initNode.
	^ anAst
]

{ #category : 'accessing' }
DdUnaryProperties >> selector: aString [ 
	selector := aString
]
