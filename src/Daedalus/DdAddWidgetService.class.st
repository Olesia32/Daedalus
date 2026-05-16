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
    (presenterClass instVarNames includes: varName) ifTrue: [ ^ self ].
    (RBAddInstanceVariableRefactoring
        variable: varName
        class: presenterClass) execute.
]

{ #category : 'accessing' }
DdAddWidgetService >> addWidget: aDescriptor [ 
    | varName |
    varName := self generateVarNameFor: aDescriptor.
    self addInstVar: varName.
    self patchInitializePresenters: varName initExpression: aDescriptor initExpression.
    self patchDefaultLayout: varName.
    ^ varName
]

{ #category : 'accessing' }
DdAddWidgetService >> generateVarNameFor: aDescriptor [ 
    | base existing index |
    base := aDescriptor label asLowercase copyReplaceAll: ' ' with: ''.
    existing := presenterClass allInstVarNames.
    index := 1.
    [ existing includes: base , index printString ] whileTrue: [ index := index + 1 ].
    ^ base , index printString
]

{ #category : 'accessing' }
DdAddWidgetService >> patchDefaultLayout: varName [

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
    | source ast superCallNode newNode |
    source := presenterClass sourceCodeAt: #initializePresenters ifAbsent: [ nil ].
    source ifNil: [
        presenterClass compile: 'initializePresenters' , String cr
            , String tab , 'super initializePresenters.' , String cr
            , String tab , varName , ' := ' , anExpr , '.'.
        ^ self ].
    ast := RBParser parseMethod: source.
    superCallNode := ast body statements
        detect: [ :stmt |
            stmt isMessage and: [ stmt selector = #initializePresenters ] ]
        ifNone: [ ast body statements last ].
    newNode := RBParser parseExpression: varName , ' := ' , anExpr.
    ast body addNode: newNode after: superCallNode.
    presenterClass compile: ast formattedCode.
]

{ #category : 'accessing' }
DdAddWidgetService >> presenterClass: aClass [ 
    presenterClass := aClass
]
