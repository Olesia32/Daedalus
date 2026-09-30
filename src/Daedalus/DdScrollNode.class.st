Class {
	#name : 'DdScrollNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdScrollNode >> canAcceptChild [
"A scrollable layout shows exactly one child."

	^ children isEmpty
]

{ #category : 'resizing' }
DdScrollNode >> childResizeHandles [
"The child's size is the scrolled content's own; the scroll area is sized by its parent."

	^ #(  )
]

{ #category : 'constraints' }
DdScrollNode >> constraintPropertiesFor: aChild [

	^ #(  )
]

{ #category : 'testing' }
DdScrollNode >> isChildMessage: aMessage [

	^ aMessage selector = #child:
]

{ #category : 'labels' }
DdScrollNode >> kindLabel [

	^ 'Scroll'
]

{ #category : 'properties' }
DdScrollNode >> layoutProperties [

	^ #(  )
]

{ #category : 'editing' }
DdScrollNode >> newAddMessageFor: aNode [

	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: #child:
		  arguments: { aNode addMessage arguments first }
]

{ #category : 'printing' }
DdScrollNode >> printOn: aStream [

	aStream nextPutAll: 'Scroll'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
