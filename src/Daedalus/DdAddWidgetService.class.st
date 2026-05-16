"
I am a service object responsible for adding a new widget to an edited presenter class. I modify the class programmatically: I add
an instance variable, patch `initializePresenters` to initialize it, and patch `defaultLayout` to include it in the layout cascade.

### Hierarchy
`Object`
`DdAddWidgetService` (this is me)

### Instance Variables
- _presenterClass_: a `Class` — the `SpPresenter` subclass currently
  being edited in the designer
"
Class {
	#name : 'DdAddWidgetService',
	#superclass : 'Object',
	#instVars : [
		'presenterClass'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'accessing' }
DdAddWidgetService >> addInstVar: varName [
	"Add varName as an instance variable via RBAddInstanceVariableRefactoring, skipping the operation silently if the variable already exists."

	(presenterClass instVarNames includes: varName) ifTrue: [ ^ self ].
	(RBAddInstanceVariableRefactoring
		 variable: varName
		 class: presenterClass) execute
]

{ #category : 'accessing' }
DdAddWidgetService >> addWidget: aDescriptor [
  "The main entry point for adding a widget. I derive a unique variable name from aDescriptor, register it as an instance variable,
patch both initializePresenters and defaultLayout, and return the generated name."
	| varName |
	varName := self generateVarNameFor: aDescriptor.
	self addInstVar: varName.
	self
		patchInitializePresenters: varName
		initExpression: aDescriptor initExpression.
	self patchDefaultLayout: varName.
	^ varName
]

{ #category : 'accessing' }
DdAddWidgetService >> generateVarNameFor: aDescriptor [
	"Derive a collision-free variable name from aDescriptor's label by lowercasing it and appending an integer suffix until the name
is unique among all existing instance variable names."

	| base cleaned existing index |
	base := aDescriptor label asLowercase copyReplaceAll: ' ' with: ''.
	cleaned := base select: [ :ch | ch isLetter or: [ ch isDigit ] ].
	cleaned isEmpty ifTrue: [ cleaned := 'widget' ].
	cleaned first isDigit ifTrue: [ cleaned := 'widget' , cleaned ].

	existing := presenterClass allInstVarNames.
	index := 1.

	[ existing includes: cleaned , index printString ] whileTrue: [
		index := index + 1 ].

	^ cleaned , index printString
]

{ #category : 'accessing' }
DdAddWidgetService >> patchDefaultLayout: varName [
	"Insert 'add: varName' into the SpBoxLayout cascade inside defaultLayout, placing it immediately before the yourself message, then recompile the method."

	| source ast cascade yourselfMsg addMsg |
	source := presenterClass
		          sourceCodeAt: #defaultLayout
		          ifAbsent: [ nil ].
	source ifNil: [ ^ self ].
	ast := RBParser parseMethod: source.

	cascade := nil.
	ast body nodesDo: [ :node |
			(cascade isNil and: [ node isKindOf: OCCascadeNode ]) ifTrue: [
					(node messages anySatisfy: [ :m | m selector = #yourself ])
						ifTrue: [ cascade := node ] ] ].
	cascade ifNil: [ ^ self ].

	yourselfMsg := cascade messages detect: [ :m |
		               m selector = #yourself ].
	addMsg := OCMessageNode
		          receiver: cascade receiver copy
		          selector: #add:
		          arguments: { (OCVariableNode named: varName) }.
	cascade messages
		add: addMsg
		beforeIndex: (cascade messages indexOf: yourselfMsg).

	presenterClass compile: ast formattedCode
]

{ #category : 'accessing' }
DdAddWidgetService >> patchInitializePresenters: varName initExpression: anExpr [
	"Insert 'varName := anExpr' into initializePresenters right after the super call. If the method does not yet exist I compile a fresh skeleton first."

	| source ast superCallNode newNode |
	source := presenterClass
		          sourceCodeAt: #initializePresenters
		          ifAbsent: [ nil ].
	source ifNil: [
			presenterClass compile:
				'initializePresenters' , String cr , String tab
				, 'super initializePresenters.' , String cr , String tab , varName
				, ' := ' , anExpr , '.'.
			^ self ].
	ast := RBParser parseMethod: source.
	superCallNode := ast body statements
		                 detect: [ :stmt |
			                 stmt isMessage and: [
				                 stmt selector = #initializePresenters ] ]
		                 ifNone: [ ast body statements last ].
	newNode := RBParser parseExpression: varName , ' := ' , anExpr.
	ast body addNode: newNode after: superCallNode.
	presenterClass compile: ast formattedCode
]

{ #category : 'accessing' }
DdAddWidgetService >> presenterClass: aClass [ 
    presenterClass := aClass
]
