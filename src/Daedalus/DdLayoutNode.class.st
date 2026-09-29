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

{ #category : 'parsing' }
DdLayoutNode class >> pointFromText: aString [
	"'2 @ 1' or '2@1' (spacing depends on the formatter) -> 2@1, or nil when it is not a plain literal point."

	| cleaned parts |
	cleaned := aString select: [ :c |
		           c isDigit or: [ #( $@ $- ) includes: c ] ].
	parts := cleaned substrings: '@'.
	parts size = 2 ifFalse: [ ^ nil ].
	^ [ parts first asInteger @ parts second asInteger ]
		  on: Error
		  do: [ :error | nil ]
]

{ #category : 'testing' }
DdLayoutNode >> acceptsCellDrops [
"True for a container that is dropped into by cell (a grid) rather than by index among siblings."

	^ false
]

{ #category : 'testing' }
DdLayoutNode >> acceptsPointDrops [
"True for a container that is dropped into at a free pixel position (an absolute layout) rather
than by index among siblings or by grid cell."

	^ false
]

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
			  parent childrenAreOrdered and: [
				  (parent children identityIndexOf: self) < parent children size ] ]
]

{ #category : 'testing' }
DdLayoutNode >> canMoveUp [

	^ parent notNil and: [
			  parent childrenAreOrdered and: [
				  (parent children identityIndexOf: self) > 1 ] ]
]

{ #category : 'accessing' }
DdLayoutNode >> children [

	^ #(  )
]

{ #category : 'testing' }
DdLayoutNode >> childrenAreOrdered [
"False when the position among siblings means nothing (a grid: the cell is the position)."

	^ true
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

{ #category : 'grid' }
DdLayoutNode >> gridPosition [
"The cell (column@row) this node has in a grid, or nil when it is not a grid child."

	| arguments |
	addMessage ifNil: [ ^ nil ].
	arguments := self constraintArguments.
	arguments isEmpty ifTrue: [ ^ nil ].
	^ self class pointFromText: arguments first
]

{ #category : 'grid' }
DdLayoutNode >> gridSpan [
"How many columns@rows this node covers in a grid: 1@1 unless it says otherwise."

	| arguments |
	arguments := self constraintArguments.
	arguments size >= 2 ifFalse: [ ^ 1 @ 1 ].
	^ (self class pointFromText: arguments second) ifNil: [ 1 @ 1 ]
]

{ #category : 'testing' }
DdLayoutNode >> isContainerNode [
	^ false
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

{ #category : 'navigation' }
DdLayoutNode >> nodeAtPath: aPath [
"The node reached from the receiver through the child indexes in aPath."

	^ aPath inject: self into: [ :node :i | node children at: i ]
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

{ #category : 'editing' }
DdLayoutNode >> replaceAddMessageWith: aNewMessageNode [
"Splices aNewMessageNode into the parent's cascade at the exact spot the receiver's own
add-message currently occupies, and makes it the receiver's add-message from now on."

	| index |
	index := parent cascade messages identityIndexOf: addMessage.
	index = 0 ifTrue: [
		^ self error: 'Add-message not found in parent cascade' ].
	aNewMessageNode parent: parent cascade.
	parent cascade messages at: index put: aNewMessageNode.
	addMessage := aNewMessageNode
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
