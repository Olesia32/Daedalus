Class {
	#name : 'DdGridNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdGridNode >> acceptsCellDrops [

	^ true
]

{ #category : 'testing' }
DdGridNode >> canAcceptChild [
"A grid cell is a position (column@row), not an index among siblings, so the generic
index-based insert/move/drag pipeline has no correct way to place a child here - it is
deliberately excluded from it. Use DdLayoutEditor>>insertGridWidget:into:atPosition:span:,
which builds the right add:atPoint:[span:] message directly, instead."

	^ false
]

{ #category : 'testing' }
DdGridNode >> childrenAreOrdered [

	^ false
]

{ #category : 'editing' }
DdGridNode >> insertChildDirectly: aNode [
"Splices aNode straight into this grid's cascade and children, without the canAcceptChild guard
that blocks the generic index-based path: aNode's own add-message already carries its exact
cell (built by the caller), so there is nothing left to decide here. A grid's children have no
meaningful order among themselves, so this simply appends."

	| message |
	message := OCMessageNode
		           receiver: cascade receiver copy
		           selector: aNode addSelector
		           arguments: aNode addMessage arguments asArray.
	message parent: cascade.
	cascade messages addLast: message.
	aNode addMessage: message.
	aNode parent: self.
	children addLast: aNode.
	^ aNode
]

{ #category : 'labels' }
DdGridNode >> kindLabel [

	^ 'Grid'
]

{ #category : 'printing' }
DdGridNode >> printOn: aStream [

	aStream nextPutAll: 'Grid'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
