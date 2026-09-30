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
DdLayoutNode class >> blockMessagesOf: aBlockNode [
	"The messages a constraints block sends to its argument: [ :c | c expand: false; padding: 2 ]
or [ :c | c expand: false. c padding: 2 ]. Answers nil for anything else."

	| argumentName messages |
	(aBlockNode isBlock and: [ aBlockNode arguments size = 1 ]) ifFalse: [
		^ nil ].
	argumentName := aBlockNode arguments first name.
	messages := OrderedCollection new.
	aBlockNode body statements do: [ :statement |
			| receiver |
			receiver := statement isCascade
				            ifTrue: [ statement receiver ]
				            ifFalse: [
				            statement isMessage ifTrue: [ statement receiver ] ].
			(receiver notNil and: [
				 receiver isVariable and: [ receiver name = argumentName ] ])
				ifFalse: [ ^ nil ].
			statement isCascade
				ifTrue: [ messages addAll: statement messages ]
				ifFalse: [ messages add: statement ] ].
	^ messages
]

{ #category : 'parsing' }
DdLayoutNode class >> blockSource: aCollectionOfStrings [
"[ :constraints | constraints a; b ] as a parsed block node."

	^ OCParser parseExpression:
		  '[ :constraints | constraints '
		  , ('; ' join: aCollectionOfStrings) , ' ]'
]

{ #category : 'parsing' }
DdLayoutNode class >> pointFromNode: anExpression [
"10 @ 20 written in the code -> 10@20, or nil when it is not a literal point."

	(anExpression notNil and: [
		 anExpression isMessage and: [ anExpression selector = #@ ] ])
		ifFalse: [ ^ nil ].
	(anExpression receiver isLiteralNode and: [
		 anExpression arguments first isLiteralNode ]) ifFalse: [ ^ nil ].
	^ anExpression receiver value @ anExpression arguments first value
]

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

{ #category : 'constraints' }
DdLayoutNode >> addMessageFor: aChild values: aDictionary [

	^ self error: self kindLabel , ' has no constraints to set'
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

{ #category : 'resizing' }
DdLayoutNode >> childResizeHandles [
"The resize handles a child of this node gets on the canvas. Only containers have children."

	^ #(  )
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

{ #category : 'constraints' }
DdLayoutNode >> constraintPropertiesFor: aChild [
"How aChild sits in this container, as editable properties. None by default."

	^ #(  )
]

{ #category : 'constraints' }
DdLayoutNode >> constraintValuesOf: aChild [
"Key -> value for every constraint property, read from aChild's add-message; nil when that
message is written in a form the designer cannot edit safely."

	^ Dictionary new
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
DdLayoutNode >> deepestContainerContaining: aPoint rectangles: aOneArgBlock [

	| best |
	best := nil.
	self allNodesDo: [ :node |
			node isContainerNode ifTrue: [
					((aOneArgBlock value: node path)
						 ifNil: [ false ]
						 ifNotNil: [ :rect | rect containsPoint: aPoint ]) ifTrue: [
							(best isNil or: [ node path size > best size ]) ifTrue: [
								best := node path ] ] ] ].
	^ best
]

{ #category : 'as yet unclassified' }
DdLayoutNode >> displayLabel [
	"What the component tree shows. Defaults to the full label."

	^ self treeLabel
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

{ #category : 'properties' }
DdLayoutNode >> layoutProperties [
"The properties of this layout that the designer can edit (see DdLayoutProperty)."

	^ #(  )
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

	| index |
	index := parent cascade messages identityIndexOf: addMessage.
	index = 0 ifTrue: [
		^ self error: 'Add-message not found in parent cascade' ].
	aNewMessageNode receiver: parent cascade receiver copy.
	aNewMessageNode parent: parent cascade.
	parent cascade messages at: index put: aNewMessageNode.
	addMessage := aNewMessageNode
]

{ #category : 'resizing' }
DdLayoutNode >> resizeHandles [

	^ parent
		  ifNil: [ #(  ) ]
		  ifNotNil: [ :container | container resizeHandlesFor: self ]
]

{ #category : 'resizing' }
DdLayoutNode >> resizeHandlesFor: aChild [

	^ self childResizeHandles
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
