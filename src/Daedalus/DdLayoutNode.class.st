Class {
	#name : 'DdLayoutNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'addMessage'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'accessing' }
DdLayoutNode >> addMessage [

	^ addMessage
]

{ #category : 'accessing' }
DdLayoutNode >> addMessage: aMessageNode [

	addMessage := aMessageNode
]

{ #category : 'accessing' }
DdLayoutNode >> addSelector [
	^ addMessage ifNotNil: [ :m | m selector ]
]

{ #category : 'enumerating' }
DdLayoutNode >> allNodesDo: aBlock [
	aBlock value: self.
	self children do: [ :each | each allNodesDo: aBlock ]
]

{ #category : 'testing' }
DdLayoutNode >> canDelete [
	^ parent notNil
]

{ #category : 'testing' }
DdLayoutNode >> canMoveDown [
	^ parent notNil and: [
		  (parent children identityIndexOf: self) < parent children size ]
]

{ #category : 'testing' }
DdLayoutNode >> canMoveUp [
	^ parent notNil and: [ (parent children identityIndexOf: self) > 1 ]
]

{ #category : 'accessing' }
DdLayoutNode >> children [

	^ #(  )
]

{ #category : 'accessing' }
DdLayoutNode >> constraintArguments [ 
	^ addMessage
		  ifNil: [ #() ]
		  ifNotNil: [ :m |
			  (m arguments allButFirst collect: [ :each | each formattedCode ]) asArray ]
]

{ #category : 'labels' }
DdLayoutNode >> constraintsLabel [
"Everything the parent's add-message says about this node besides the node itself"

	| keywords |
	(addMessage isNil or: [ addMessage arguments size < 2 ]) ifTrue: [
		^ '' ].
	keywords := addMessage selector keywords allButFirst.
	^ (' ' join: (keywords
			    with: self constraintArguments
			    collect: [ :keyword :value | keyword , ' ' , value ]))
		  withSeparatorsCompacted
]

{ #category : 'searching' }
DdLayoutNode >> findWidgetNamed: aString [
	"The widget node whose variable is aString (a String or a Symbol), or nil."

	self allNodesDo: [ :node |
			(node isWidgetNode and: [ node varName asString = aString asString ])
				ifTrue: [ ^ node ] ].
	^ nil
]

{ #category : 'testing' }
DdLayoutNode >> isDescendantOf: aNode [
	| current |
	current := parent.
	[ current notNil ] whileTrue: [
			current == aNode ifTrue: [ ^ true ].
			current := current parent ].
	^ false
]

{ #category : 'testing' }
DdLayoutNode >> isWidgetNode [
	^ false
]

{ #category : 'labels' }
DdLayoutNode >> labelForMessage: aMessage [
"'spacing: 10' for a keyword message, 'vAlignStart' for a unary one"

	aMessage arguments isEmpty ifTrue: [ ^ aMessage selector asString ].
	^ (' ' join: (aMessage selector keywords
			    with:
			    (aMessage arguments collect: [ :each | each formattedCode ])
			    collect: [ :keyword :value | keyword , ' ' , value ]))
		  withSeparatorsCompacted
]

{ #category : 'accessing' }
DdLayoutNode >> parent [
	^ parent
]

{ #category : 'accessing' }
DdLayoutNode >> parent: aNode [
	parent := aNode
]

{ #category : 'navigation' }
DdLayoutNode >> path [
	"Indexes of this node from the root, e.g. #(3 2). The root itself has an empty path."

	parent ifNil: [ ^ #(  ) ].
	^ parent path , { (parent children identityIndexOf: self) }
]

{ #category : 'printing' }
DdLayoutNode >> printTreeOn: aStream indent: n [
	aStream
		next: n * 2 put: $ ;
		print: self;
		cr.
	self children do: [ :c | c printTreeOn: aStream indent: n + 1 ]
]

{ #category : 'labels' }
DdLayoutNode >> treeLabel [
	^ self printString
]

{ #category : 'printing' }
DdLayoutNode >> treeString [
	^ String streamContents: [ :s | self printTreeOn: s indent: 0 ]
]

{ #category : 'accessing' }
DdLayoutNode >> widgetNames [
	^ #(  )
]
