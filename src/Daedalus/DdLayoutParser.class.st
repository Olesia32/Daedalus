Class {
	#name : 'DdLayoutParser',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'parsing' }
DdLayoutParser >> containerClassFor: anExpression [
	"The node class for a layout cascade we understand, or nil."

	| receiver name |
	anExpression isCascade ifFalse: [ ^ nil ].
	receiver := anExpression receiver.
	(receiver isMessage and: [ receiver receiver isVariable ]) ifFalse: [
		^ nil ].
	name := receiver receiver name.
	name = 'SpBoxLayout' ifTrue: [ ^ DdBoxNode ].
	name = 'SpPanedLayout' ifTrue: [ "first:/second: put children at fixed positions; editing them as an ordered list would change the meaning"
			^ (self hasPositionalMessages: anExpression)
				  ifTrue: [ nil ]
				  ifFalse: [ DdPanedNode ] ].
	^ nil
]

{ #category : 'parsing' }
DdLayoutParser >> hasPositionalMessages: aCascade [
	^ aCascade messages anySatisfy: [ :each |
			  #( #first: #second: #replaceFirst: #replaceSecond: ) includes:
				  each selector ]
]

{ #category : 'testing' }
DdLayoutParser >> isAddMessage: aMessage [
	^ (aMessage selector beginsWith: 'add:') and: [
		  aMessage arguments notEmpty ]
]

{ #category : 'testing' }
DdLayoutParser >> isBoxCascade: anExpression [
	| receiver |
	anExpression isCascade ifFalse: [ ^ false ].
	receiver := anExpression receiver.
	^ receiver isMessage and: [
			  receiver receiver isVariable and: [
				  receiver receiver name = 'SpBoxLayout' ] ]
]

{ #category : 'parsing' }
DdLayoutParser >> parseBox: aCascade addMessage: aMessage [
	| box |
	box := DdBoxNode new
		       cascade: aCascade;
		       addMessage: aMessage;
		       factorySelector: aCascade receiver selector;
		       yourself.
	aCascade messages do: [ :each |
			(self isAddMessage: each)
				ifTrue: [
						box addChild:
							(self parseExpression: each arguments first addMessage: each) ]
				ifFalse: [
				each selector = #yourself ifFalse: [ box addPropertyMessage: each ] ] ].
	^ box
]

{ #category : 'parsing' }
DdLayoutParser >> parseContainer: aClass cascade: aCascade addMessage: aMessage [
	| container |
	container := aClass new
		             cascade: aCascade;
		             addMessage: aMessage;
		             factorySelector: aCascade receiver selector;
		             yourself.
	aCascade messages do: [ :each |
			(self isAddMessage: each)
				ifTrue: [
						container addChild:
							(self parseExpression: each arguments first addMessage: each) ]
				ifFalse: [
						each selector = #yourself ifFalse: [
							container addPropertyMessage: each ] ] ].
	^ container
]

{ #category : 'parsing' }
DdLayoutParser >> parseExpression: anExpression addMessage: aMessage [
	| containerClass |
	containerClass := self containerClassFor: anExpression.
	containerClass ifNotNil: [
			^ self
				  parseContainer: containerClass
				  cascade: anExpression
				  addMessage: aMessage ].
	(anExpression isVariable and: [ aMessage notNil ]) ifTrue: [
			^ DdWidgetNode new
				  addMessage: aMessage;
				  yourself ].
	^ DdOpaqueNode new
		  expression: anExpression;
		  addMessage: aMessage;
		  yourself
]

{ #category : 'parsing' }
DdLayoutParser >> parseMethodNode: aMethodNode [
	| return |
	return := aMethodNode body statements
		          detect: [ :each | each isReturn ]
		          ifNone: [ ^ nil ].
	^ self parseExpression: return value addMessage: nil
]

{ #category : 'parsing' }
DdLayoutParser >> parseMethodSource: aString [
	^ self parseMethodNode: (RBParser parseMethod: aString)
]
