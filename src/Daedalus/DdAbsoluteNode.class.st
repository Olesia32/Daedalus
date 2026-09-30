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

{ #category : 'constraints' }
DdAbsoluteNode >> addMessageFor: aChild values: aDictionary [

	| position extent arguments |
	position := aDictionary at: #position.
	extent := aDictionary at: #extent.
	arguments := {
		             aChild addMessage arguments first.
		             (OCParser parseExpression: position printString) }.
	extent ifNotNil: [
			arguments := arguments
			             , { (OCParser parseExpression: extent printString) } ].
	^ OCMessageNode
		  receiver: (OCVariableNode named: 'layout')
		  selector:
		  (extent
			   ifNil: [ #add:atPoint: ]
			   ifNotNil: [ #add:atPoint:extent: ])
		  arguments: arguments
]

{ #category : 'testing' }
DdAbsoluteNode >> canAcceptChild [
"An absolute child's position (and optional extent) is carried entirely in its own add-message
(add:atPoint:[extent:]/add:bounds:/plain add:), the same way a grid cell is - so, like a grid, this
is deliberately excluded from the generic index-based insert/move/drag pipeline. Use
DdLayoutEditor>>insertAbsoluteWidget:into:atPoint:extent: instead, once that slice lands."

	^ false
]

{ #category : 'resizing' }
DdAbsoluteNode >> childResizeHandles [
"All eight: the left/top ones move the position (atPoint:) as well as change the extent."

	^ DdResizeHandles allHandleNames
]

{ #category : 'testing' }
DdAbsoluteNode >> childrenAreOrdered [
"The drawing order still matters (last added is on top), but position among siblings carries no
layout meaning the way it does in a box - same reasoning as a grid cell."

	^ false
]

{ #category : 'constraints' }
DdAbsoluteNode >> constraintPropertiesFor: aChild [

	^ {
		  (DdConstraintProperty
			   key: #position
			   label: 'Position (x@y)'
			   kind: #point
			   default: 0 @ 0).
		  (DdConstraintProperty
			   key: #extent
			   label: 'Size (width@height)'
			   kind: #point
			   default: nil) }
]

{ #category : 'constraints' }
DdAbsoluteNode >> constraintValuesOf: aChild [

	| message values point |
	message := aChild addMessage.
	values := Dictionary new.
	values
		at: #position put: 0 @ 0;
		at: #extent put: nil.
	message selector = #add: ifTrue: [ ^ values ].
	(#( #add:atPoint: #add:atPoint:extent: ) includes: message selector)
		ifFalse: [ ^ nil ].
	point := DdLayoutNode pointFromNode: message arguments second.
	point ifNil: [ ^ nil ].
	values at: #position put: point rounded.
	message selector = #add:atPoint:extent: ifTrue: [
			point := DdLayoutNode pointFromNode: message arguments third.
			point ifNil: [ ^ nil ].
			values at: #extent put: point rounded ].
	^ values
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

{ #category : 'properties' }
DdAbsoluteNode >> layoutProperties [

	^ #(  )
]

{ #category : 'printing' }
DdAbsoluteNode >> printOn: aStream [

	aStream nextPutAll: 'Absolute'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
