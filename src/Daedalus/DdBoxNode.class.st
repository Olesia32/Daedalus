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

{ #category : 'testing' }
DdBoxNode >> canAcceptChild [
	^ true
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
	"aNode carries an addMessage (possibly detached); a fresh message is attached to this container's cascade."

	| message |
	self canAcceptChild ifFalse: [
		^ self error: 'This container cannot hold more children' ].
	(anIndex between: 1 and: children size + 1) ifFalse: [
		^ self error: 'Index out of range' ].
	message := self newAddMessageFor: aNode.
	message parent: cascade.
	cascade messages
		add: message
		beforeIndex: (self messageIndexForInsertionAt: anIndex).
	aNode addMessage: message.
	aNode parent: self.
	children add: aNode beforeIndex: anIndex.
	^ aNode
]

{ #category : 'testing' }
DdBoxNode >> isAnchorSelector: aSelector [
"Whether aSelector is a structural no-op message (like the trailing yourself) rather than a real
property - so it should never show up in propertyMessages/treeLabel. Plain boxes have none; a
subclass whose only way to keep a cascade non-collapsing is a harmless call of its own (see
DdAbsoluteNode) overrides this to say so."

	^ false
]

{ #category : 'testing' }
DdBoxNode >> isContainerNode [
	^ true
]

{ #category : 'testing' }
DdBoxNode >> isHorizontal [
"SpBoxLayout new and SpPanedLayout new are vertical."

	^ #( #newLeftToRight #newHorizontal ) includes: factorySelector
]

{ #category : 'labels' }
DdBoxNode >> kindLabel [

	factorySelector = #newLeftToRight ifTrue: [ ^ 'Horizontal box' ].
	factorySelector = #newTopToBottom ifTrue: [ ^ 'Vertical box' ].
	^ 'Box'
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

{ #category : 'editing' }
DdBoxNode >> newAddMessageFor: aNode [
"The message that will insert aNode into this container's cascade. A plain box keeps the
selector and arguments (constraints) of the node's own add-message, EXCEPT when that selector
is grid-only (atPoint:/atPoint:span:, or the deprecated at:/at:span:) - a Box cannot accept a
cell position, so it falls back to a plain add: instead, same as moving out of a paned already
drops its constraints."

	| selector |
	selector := aNode addSelector.
	(#( #add:atPoint: #add:atPoint:span: #add:at: #add:at:span: )
		 includes: selector) ifTrue: [
			^ OCMessageNode
				  receiver: cascade receiver copy
				  selector: #add:
				  arguments: { aNode addMessage arguments first } ].
	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: selector
		  arguments: aNode addMessage arguments asArray
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
"Removing the last non-yourself message would leave the cascade with a single message
(just yourself). Pharo's own formattedCode then prints that without a semicolon - valid Smalltalk,
but no longer a cascade, so a later reparse turns the whole node into an unreadable DdOpaqueNode.
Guard against it by duplicating the trailing message first, so the cascade never drops below two
messages. Harmless: 'yourself; yourself' still yields the same object."

	| index messageIndex |
	index := children identityIndexOf: aNode.
	index = 0 ifTrue: [ ^ self error: 'Not a child of this box' ].
	cascade messages size > 1 ifFalse: [
		^ self error: 'Cannot remove the last message of a cascade' ].
	cascade messages size = 2 ifTrue: [
		cascade messages add: cascade messages last copy ].
	"AST nodes compare structurally, so identity is used on purpose"
	messageIndex := cascade messages identityIndexOf: aNode addMessage.
	cascade messages removeAt: messageIndex.
	children removeAt: index.
	aNode parent: nil.
	^ aNode
]

{ #category : 'labels' }
DdBoxNode >> treeLabel [

	| props constraints label |
	props := propertyMessages collect: [ :each |
		         self labelForMessage: each ].
	constraints := self constraintsLabel.
	label := props isEmpty
		         ifTrue: [ self kindLabel ]
		         ifFalse: [
		         self kindLabel , ' (' , (', ' join: props) , ')' ].
	^ constraints isEmpty
		  ifTrue: [ label ]
		  ifFalse: [ label , ' [' , constraints , ']' ]
]

{ #category : 'accessing' }
DdBoxNode >> widgetNames [
	^ children flatCollect: [ :each | each widgetNames ]
]
