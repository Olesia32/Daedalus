Class {
	#name : 'DdAbsoluteNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdAbsoluteNode >> acceptsPointDrops [

	^ true
]

{ #category : 'testing' }
DdAbsoluteNode >> canAcceptChild [
"An absolute child's position (and optional extent) is carried entirely in its own add-message
(add:atPoint:[extent:]/add:bounds:/plain add:), the same way a grid cell is - so, like a grid, this
is deliberately excluded from the generic index-based insert/move/drag pipeline. Use
DdLayoutEditor>>insertAbsoluteWidget:into:atPoint:extent: instead, once that slice lands."

	^ false
]

{ #category : 'testing' }
DdAbsoluteNode >> childrenAreOrdered [
"The drawing order still matters (last added is on top), but position among siblings carries no
layout meaning the way it does in a box - same reasoning as a grid cell."

	^ false
]

{ #category : 'editing' }
DdAbsoluteNode >> insertChildDirectly: aNode [
"Splices aNode straight into this layout's cascade and children, without the canAcceptChild guard -
mirrors DdGridNode>>insertChildDirectly:. aNode's own add-message already carries its exact
position/extent (built by the caller). Children are in drawing order (last added is on top), so
this appends."

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

{ #category : 'testing' }
DdAbsoluteNode >> isAnchorSelector: aSelector [
"removeAll is the anchor DdLayoutEditor class>>sourceForContainerKind: uses so a freshly
created, empty absolute layout's cascade never collapses to a single message - it carries no
real configuration and should not be shown as one."

	^ aSelector = #removeAll
]

{ #category : 'labels' }
DdAbsoluteNode >> kindLabel [

	^ 'Absolute'
]

{ #category : 'printing' }
DdAbsoluteNode >> printOn: aStream [

	aStream nextPutAll: 'Absolute'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
