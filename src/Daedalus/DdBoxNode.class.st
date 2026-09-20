Class {
	#name : 'DdBoxNode',
	#superclass : 'DdLayoutNode',
	#instVars : [
		'cascade',
		'factorySelector',
		'children',
		'propertyMessages'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'adding' }
DdBoxNode >> addChild: aNode [
	aNode parent: self.
	^ children add: aNode
]

{ #category : 'adding' }
DdBoxNode >> addPropertyMessage: aMessage [
	propertyMessages add: aMessage
]

{ #category : 'accessing' }
DdBoxNode >> cascade [
	^ cascade
]

{ #category : 'accessing' }
DdBoxNode >> cascade: aNode [
	cascade := aNode
]

{ #category : 'accessing' }
DdBoxNode >> children [
	^ children
]

{ #category : 'accessing' }
DdBoxNode >> factorySelector [
	^ factorySelector
]

{ #category : 'accessing' }
DdBoxNode >> factorySelector: aSymbol [
	factorySelector := aSymbol
]

{ #category : 'initialization' }
DdBoxNode >> initialize [
	super initialize.
	children := OrderedCollection new.
	propertyMessages := OrderedCollection new
]

{ #category : 'editing' }
DdBoxNode >> insertChild: aNode at: anIndex [
"aNode carries an addMessage (possibly detached); a fresh message with the same
selector and arguments is attached to this box's cascade."

	| message |
	(anIndex between: 1 and: children size + 1) ifFalse: [
		^ self error: 'Index out of range' ].
	message := OCMessageNode
		           receiver: cascade receiver copy
		           selector: aNode addSelector
		           arguments: aNode addMessage arguments asArray.
	message parent: cascade.
	cascade messages
		add: message
		beforeIndex: (self messageIndexForInsertionAt: anIndex).
	aNode addMessage: message.
	aNode parent: self.
	children add: aNode beforeIndex: anIndex.
	^ aNode
]

{ #category : 'editing' }
DdBoxNode >> messageIndexForInsertionAt: anIndex [
"Position in the cascade where the add-message for a child at anIndex must go."

	| messages yourselfIndex |
	messages := cascade messages.
	anIndex <= children size ifTrue: [
		^ messages identityIndexOf: (children at: anIndex) addMessage ].
	children isEmpty ifFalse: [
		^ (messages identityIndexOf: children last addMessage) + 1 ].
	yourselfIndex := messages findFirst: [ :m | m selector = #yourself ].
	^ yourselfIndex = 0
		  ifTrue: [ messages size + 1 ]
		  ifFalse: [ yourselfIndex ]
]

{ #category : 'printing' }
DdBoxNode >> printOn: aStream [
	aStream
		nextPutAll: 'Box ';
		print: factorySelector.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]

{ #category : 'accessing' }
DdBoxNode >> propertyMessages [
	^ propertyMessages
]

{ #category : 'editing' }
DdBoxNode >> removeChild: aNode [
	| index messageIndex |
	index := children identityIndexOf: aNode.
	index = 0 ifTrue: [ ^ self error: 'Not a child of this box' ].
	cascade messages size > 1 ifFalse: [
		^ self error: 'Cannot remove the last message of a cascade' ].
	"AST nodes compare structurally, so identity is used on purpose"
	messageIndex := cascade messages identityIndexOf: aNode addMessage.
	cascade messages removeAt: messageIndex.
	children removeAt: index.
	aNode parent: nil.
	^ aNode
]

{ #category : 'labels' }
DdBoxNode >> treeLabel [
	| kind props constraints label |
	kind := factorySelector = #newLeftToRight
		        ifTrue: [ 'Horizontal box' ]
		        ifFalse: [
				        factorySelector = #newTopToBottom
					        ifTrue: [ 'Vertical box' ]
					        ifFalse: [ 'Box' ] ].
	props := propertyMessages collect: [ :each |
		         self labelForMessage: each ].
	constraints := self constraintsLabel.
	label := props isEmpty
		         ifTrue: [ kind ]
		         ifFalse: [ kind , ' (' , (', ' join: props) , ')' ].
	^ constraints isEmpty
		  ifTrue: [ label ]
		  ifFalse: [ label , ' [' , constraints , ']' ]
]

{ #category : 'accessing' }
DdBoxNode >> widgetNames [
	^ children flatCollect: [ :each | each widgetNames ]
]
