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

{ #category : 'labels' }
DdPanedNode >> kindLabel [
	factorySelector = #newLeftToRight ifTrue: [ ^ 'Horizontal paned' ].
	factorySelector = #newTopToBottom ifTrue: [ ^ 'Vertical paned' ].
	^ 'Paned'
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
