Class {
	#name : 'DdPanedNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdPanedNode >> canAcceptChild [
	"A paned layout holds two children at most"

	^ children size < 2
]

{ #category : 'resizing' }
DdPanedNode >> childResizeHandles [
"A paned layout sizes its two children with its slider (positionOfSlider:), not per child."

	^ #(  )
]

{ #category : 'constraints' }
DdPanedNode >> constraintPropertiesFor: aChild [

	^ #(  )
]

{ #category : 'labels' }
DdPanedNode >> kindLabel [

	(#( #newLeftToRight #newHorizontal ) includes: factorySelector)
		ifTrue: [ ^ 'Horizontal paned' ].
	(#( #newTopToBottom #newVertical ) includes: factorySelector)
		ifTrue: [ ^ 'Vertical paned' ].
	^ 'Paned'
]

{ #category : 'properties' }
DdPanedNode >> layoutProperties [

	^ { (DdLayoutProperty
		   sliderPosition: 'Slider position (0.3 or pixels)'
		   selector: #positionOfSlider:) }
]

{ #category : 'editing' }
DdPanedNode >> newAddMessageFor: aNode [
	"SpPanedLayout only understands add: (its position is the order of addition),
	so the constraints of a box child are dropped."

	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: #add:
		  arguments: { aNode addMessage arguments first }
]

{ #category : 'parsing' }
DdPanedNode >> normalizeCascade [

	| positional firstMessage secondMessage index added |
	positional := cascade messages select: [ :each |
			              #( #first: #second: #replaceFirst: #replaceSecond: )
				              includes: each selector ].
	positional isEmpty ifTrue: [ ^ self ].
	firstMessage := positional reversed
		                detect: [ :each |
		                #( #first: #replaceFirst: ) includes: each selector ]
		                ifNone: [ nil ].
	secondMessage := positional reversed
		                 detect: [ :each |
		                 #( #second: #replaceSecond: ) includes:
			                 each selector ]
		                 ifNone: [ nil ].
	index := cascade messages identityIndexOf: positional first.
	positional do: [ :each |
		cascade messages removeAt: (cascade messages identityIndexOf: each) ].
	added := ({
		          firstMessage.
		          secondMessage } reject: [ :each | each isNil ]) collect: [
			         :each |
			         OCMessageNode
				         receiver: cascade receiver copy
				         selector: #add:
				         arguments: { each arguments first } ].
	added reverseDo: [ :each |
			each parent: cascade.
			cascade messages add: each beforeIndex: index ]
]

{ #category : 'printing' }
DdPanedNode >> printOn: aStream [
	aStream
		nextPutAll: 'Paned ';
		print: factorySelector.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]

{ #category : 'resizing' }
DdPanedNode >> resizeHandlesFor: aChild [
"Only the edge facing the slider: dragging it moves the slider (positionOfSlider:)."

	| index |
	children size = 2 ifFalse: [ ^ #(  ) ].
	index := children identityIndexOf: aChild.
	index = 0 ifTrue: [ ^ #(  ) ].
	^ self isHorizontal
		  ifTrue: [
				  index = 1
					  ifTrue: [ #( #right ) ]
					  ifFalse: [ #( #left ) ] ]
		  ifFalse: [
				  index = 1
					  ifTrue: [ #( #bottom ) ]
					  ifFalse: [ #( #top ) ] ]
]
