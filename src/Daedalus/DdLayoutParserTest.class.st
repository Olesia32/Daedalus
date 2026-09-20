Class {
	#name : 'DdLayoutParserTest',
	#superclass : 'TestCase',
	#category : 'Daedalus-Tests',
	#package : 'Daedalus',
	#tag : 'Tests'
}

{ #category : 'tests' }
DdLayoutParserTest >> testDoesNotFailOnAnyPresenterInImage [
	| failures |
	failures := OrderedCollection new.
	SpPresenter allSubclasses do: [ :cls |
			(cls includesSelector: #defaultLayout) ifTrue: [
					[
						DdLayoutParser new parseMethodSource:
							(cls >> #defaultLayout) sourceCode ]
						on: Error
						do: [ :e | failures add: cls name -> e messageText ] ] ].
	self assert: failures isEmpty description: failures printString
]

{ #category : 'tests' }
DdLayoutParserTest >> testFlatBox [
	| tree |
	tree := DdLayoutParser new parseMethodSource:
		        'defaultLayout
	  	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: a expand: false;
		  add: b;
		  yourself'.
	self assert: tree class equals: DdBoxNode.
	self assert: tree factorySelector equals: #newTopToBottom.
	self
		assert: (tree propertyMessages collect: #selector) asArray
		equals: #( #spacing: ).
	self assert: tree children size equals: 2.
	self assert: tree children first varName equals: 'a'.
	self assert: tree children first addSelector equals: #add:expand:.
	self
		assert: tree children first constraintArguments
		equals: #( 'false' ).
	self assert: tree children second constraintArguments isEmpty
]

{ #category : 'tests' }
DdLayoutParserTest >> testLiteralChildIsOpaque [

	| tree |
	tree := DdLayoutParser new parseMethodSource:
		        'defaultLayout
		^ SpBoxLayout newTopToBottom
		  add: ''Title'' expand: false;
		yourself'.
	self assert: tree children first class equals: DdOpaqueNode
]

{ #category : 'tests' }
DdLayoutParserTest >> testNestedBox [

	| tree inner |
	tree := DdLayoutParser new parseMethodSource:
		        'defaultLayout
		^ SpBoxLayout newTopToBottom
		add: (SpBoxLayout newLeftToRight
		add: p width: 150;
		add: w;
		yourself);
		add: c height: 150;
		yourself'.
	self assert: tree children size equals: 2.
	inner := tree children first.
	self assert: inner class equals: DdBoxNode.
	self assert: inner children size equals: 2.
	self assert: inner parent == tree.
	self assert: inner children first varName equals: 'p'
]

{ #category : 'tests' }
DdLayoutParserTest >> testUnsupportedRootIsOpaque [

	| tree |
	tree := DdLayoutParser new parseMethodSource:
		        'defaultLayout
		^ SpGridLayout new
		add: a at: 1 @ 1;
		yourself'.
	self assert: tree class equals: DdOpaqueNode
]
