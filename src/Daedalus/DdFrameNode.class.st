Class {
	#name : 'DdFrameNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdFrameNode >> canAcceptChild [
"A frame shows exactly one child."

	^ children isEmpty
]

{ #category : 'resizing' }
DdFrameNode >> childResizeHandles [
"The child fills the frame; the frame is sized by its own parent."

	^ #(  )
]

{ #category : 'constraints' }
DdFrameNode >> constraintPropertiesFor: aChild [

	^ #(  )
]

{ #category : 'properties' }
DdFrameNode >> factoryValueFor: aProperty [

	(aProperty selector = #label: and: [ factorySelector = #newLabel: ])
		ifFalse: [ ^ nil ].
	^ cascade receiver arguments first isLiteralNode ifTrue: [
		  cascade receiver arguments first value ]
]

{ #category : 'testing' }
DdFrameNode >> isChildMessage: aMessage [

	^ #( #add: #child: #add:withConstraints: ) includes:
		  aMessage selector
]

{ #category : 'labels' }
DdFrameNode >> kindLabel [

	^ 'Frame'
]

{ #category : 'properties' }
DdFrameNode >> layoutProperties [

	^ { (DdLayoutProperty string: 'Title' selector: #label:) }
]

{ #category : 'editing' }
DdFrameNode >> newAddMessageFor: aNode [

	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: #add:
		  arguments: { aNode addMessage arguments first }
]

{ #category : 'printing' }
DdFrameNode >> printOn: aStream [

	aStream nextPutAll: 'Frame'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
