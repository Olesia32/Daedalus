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

{ #category : 'constraints' }
DdBoxNode >> addMessageFor: aChild values: aDictionary [
"The shortest form Spec understands. A fixed size already means expand: false. A child kept
at the end uses the matching addLast:... form."

	| argument expand fill padding size atEnd parts selector arguments |
	argument := aChild addMessage arguments first.
	expand := aDictionary at: #expand.
	fill := aDictionary at: #fill.
	padding := aDictionary at: #padding.
	size := aDictionary at: self sizeKey.
	atEnd := aDictionary at: #atEnd ifAbsent: [ false ].
	(size notNil and: [ atEnd or: [ fill not or: [ padding ~= 0 ] ] ])
		ifTrue: [
				parts := OrderedCollection new.
				parts add: self sizeKey , ': ' , size printString.
				fill ifFalse: [ parts add: 'fill: false' ].
				padding = 0 ifFalse: [
					parts add: 'padding: ' , padding printString ].
				^ OCMessageNode
					  receiver: (OCVariableNode named: 'layout')
					  selector: (atEnd
							   ifTrue: [ #addLast:withConstraints: ]
							   ifFalse: [ #add:withConstraints: ])
					  arguments: {
							  argument.
							  (DdLayoutNode blockSource: parts) } ].
	size
		ifNotNil: [
				selector := self sizeKey = #height
					            ifTrue: [ #add:height: ]
					            ifFalse: [ #add:width: ].
				arguments := { size } ]
		ifNil: [
				(fill and: [ padding = 0 ])
					ifTrue: [
							expand
								ifTrue: [
										selector := #add:.
										arguments := {  } ]
								ifFalse: [
										selector := #add:expand:.
										arguments := { false } ] ]
					ifFalse: [
							selector := #add:expand:fill:padding:.
							arguments := {
								             expand.
								             fill.
								             padding } ] ].
	atEnd ifTrue: [
			selector := ('addLast:' , (selector allButFirst: 'add:' size))
				            asSymbol ].
	^ OCMessageNode
		  receiver: (OCVariableNode named: 'layout')
		  selector: selector
		  arguments: { argument } , (arguments collect: [ :each |
				   OCParser parseExpression: each printString ])
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

{ #category : 'constraints' }
DdBoxNode >> childIsPlacedAtEnd: aChild [

	| message |
	message := aChild addMessage.
	(message selector beginsWith: 'addLast:') ifTrue: [ ^ true ].
	message selector = #add:withConstraints: ifFalse: [ ^ false ].
	^ (DdLayoutNode blockMessagesOf: message arguments second)
		  ifNil: [ false ]
		  ifNotNil: [ :messages |
			  messages anySatisfy: [ :each | each selector = #bePlacedAtEnd ] ]
]

{ #category : 'resizing' }
DdBoxNode >> childResizeHandles [

	^ self isHorizontal
		  ifTrue: [ #( #left #right ) ]
		  ifFalse: [ #( #top #bottom ) ]
]

{ #category : 'accessing' }
DdBoxNode >> children [
	^ children
]

{ #category : 'constraints' }
DdBoxNode >> constraintPropertiesFor: aChild [

	| properties |
	properties := OrderedCollection new.
	properties
		add: (DdConstraintProperty
				 key: #expand
				 label: 'Expand'
				 kind: #boolean
				 default: true);
		add: (DdConstraintProperty
				 key: #fill
				 label: 'Fill'
				 kind: #boolean
				 default: true);
		add: (DdConstraintProperty
				 key: #padding
				 label: 'Padding'
				 kind: #number
				 default: 0);
		add: (DdConstraintProperty
				 key: self sizeKey
				 label: (self isHorizontal
						  ifTrue: [ 'Width' ]
						  ifFalse: [ 'Height' ])
				 kind: #number
				 default: nil).
	(self childIsPlacedAtEnd: aChild) ifTrue: [
			properties add: (DdConstraintProperty
					 key: #atEnd
					 label: 'Placed at end (addLast:, not recommended by Spec)'
					 kind: #boolean
					 default: false) ].
	^ properties asArray
]

{ #category : 'constraints' }
DdBoxNode >> constraintValuesOf: aChild [
"addLast:... reads like the matching add:... with #atEnd set."

	| message selector arguments values literal |
	values := Dictionary new.
	values
		at: #expand put: true;
		at: #fill put: true;
		at: #padding put: 0;
		at: self sizeKey put: nil.
	(self childIsPlacedAtEnd: aChild) ifTrue: [
		values at: #atEnd put: true ].
	message := aChild addMessage.
	selector := message selector asString.
	(selector beginsWith: 'addLast:') ifTrue: [
		selector := 'add:' , (selector allButFirst: 'addLast:' size) ].
	selector := selector asSymbol.
	arguments := message arguments allButFirst.
	literal := [ :node |
		           node isLiteralNode
			           ifTrue: [ node value ]
			           ifFalse: [ ^ nil ] ].
	selector = #add: ifTrue: [ ^ values ].
	(#( #add:expand: #add:expand:fill: #add:expand:fill:padding: )
		 includes: selector) ifTrue: [
			#( #expand #fill #padding )
				with: (arguments , #( nil nil nil ) first: 3)
				do: [ :key :node |
					node ifNotNil: [ values at: key put: (literal value: node) ] ].
			^ values ].
	(#( #add:height: #add:width: ) includes: selector) ifTrue: [
			selector = #add:height: = (self sizeKey = #height) ifTrue: [
				values at: self sizeKey put: (literal value: arguments first) ].
			values at: #expand put: false.
			^ values ].
	selector = #add:withConstraints: ifTrue: [
			(DdLayoutNode blockMessagesOf: arguments first)
				ifNil: [ ^ nil ]
				ifNotNil: [ :messages |
						messages do: [ :each |
								(#( #expand: #fill: #padding: #height: #width: #bePlacedAtEnd
								    #bePlacedAtStart ) includes: each selector) ifFalse: [
									^ nil ].
								(#( #bePlacedAtEnd #bePlacedAtStart ) includes: each selector)
									ifFalse: [
											(each selector = #height: or: [ each selector = #width: ])
												ifTrue: [
														values at: #expand put: false.
														each selector allButLast asSymbol = self sizeKey
															ifTrue: [
															values
																at: self sizeKey
																put: (literal value: each arguments first) ] ]
												ifFalse: [
														values
															at: each selector allButLast asSymbol
															put: (literal value: each arguments first) ] ] ].
						^ values ] ].
	^ nil
]

{ #category : 'as yet unclassified' }
DdBoxNode >> displayLabel [

	^ self kindLabel
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

{ #category : 'editing' }
DdBoxNode >> isBoxConstraintsBlock: aBlockNode [
"Whether a withConstraints: block only says things a box understands (expand:, fill:,
padding:, width:, height:, placement) - a grid's or an absolute layout's block does not."

	^ (DdLayoutNode blockMessagesOf: aBlockNode)
		  ifNil: [ false ]
		  ifNotNil: [ :messages |
				  messages allSatisfy: [ :each |
						  #( #expand: #fill: #padding: #width: #height: #bePlacedAtEnd
						     #bePlacedAtStart ) includes: each selector ] ]
]

{ #category : 'testing' }
DdBoxNode >> isChildMessage: aMessage [
"add:... and addLast:... (a child placed at the end of the box) both add a child."

	aMessage arguments isEmpty ifTrue: [ ^ false ].
	^ (aMessage selector beginsWith: 'add:') or: [
		  aMessage selector beginsWith: 'addLast:' ]
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

	(#( #newLeftToRight #newHorizontal ) includes: factorySelector)
		ifTrue: [ ^ 'Horizontal box' ].
	(#( #newTopToBottom #newVertical ) includes: factorySelector)
		ifTrue: [ ^ 'Vertical box' ].
	^ 'Box'
]

{ #category : 'properties' }
DdBoxNode >> layoutProperties [

	^ {
		  (DdLayoutProperty number: 'Spacing' selector: #spacing:).
		  (DdLayoutProperty number: 'Border width' selector: #borderWidth:).
		  (DdLayoutProperty
			   flag: 'Same size for all children'
			   on: #beHomogeneous
			   off: #beNotHomogeneous
			   default: false).
		  (DdLayoutProperty
			   alignment: 'Align children horizontally'
			   prefix: #hAlign).
		  (DdLayoutProperty
			   alignment: 'Align children vertically'
			   prefix: #vAlign) }
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

	| selector |
	selector := aNode addSelector.
	(#( #add:atPoint: #add:atPoint:span: #add:at: #add:at:span:
	    #child: #addOverlay: #addOverlay:withConstraints:
	    #add:atPoint:extent: #add:bounds: ) includes: selector) ifTrue: [
			^ OCMessageNode
				  receiver: cascade receiver copy
				  selector: #add:
				  arguments: { aNode addMessage arguments first } ].
	(selector = #add:withConstraints: and: [
		 (self isBoxConstraintsBlock: aNode addMessage arguments second) not ])
		ifTrue: [
				^ OCMessageNode
					  receiver: cascade receiver copy
					  selector: #add:
					  arguments: { aNode addMessage arguments first } ].
	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: selector
		  arguments: aNode addMessage arguments asArray
]

{ #category : 'parsing' }
DdBoxNode >> normalizeCascade [
"Hook run by the parser before the children are read. Nothing to do for most layouts."

	
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

{ #category : 'constraints' }
DdBoxNode >> sizeKey [

	^ self isHorizontal
		  ifTrue: [ #width ]
		  ifFalse: [ #height ]
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
