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

{ #category : 'constraints' }
DdGridNode >> addMessageFor: aChild values: aDictionary [

	| cell span arguments |
	cell := aDictionary at: #cell.
	span := aDictionary at: #span.
	(cell x < 1 or: [ cell y < 1 ]) ifTrue: [
		^ self error: 'A grid cell starts at 1@1' ].
	(span x < 1 or: [ span y < 1 ]) ifTrue: [
		^ self error: 'A span is at least 1@1' ].
	arguments := {
		             aChild addMessage arguments first.
		             (OCParser parseExpression: cell printString) }.
	span = (1 @ 1) ifFalse: [
			arguments := arguments
			             , { (OCParser parseExpression: span printString) } ].
	^ OCMessageNode
		  receiver: (OCVariableNode named: 'layout')
		  selector: (span = (1 @ 1)
				   ifTrue: [ #add:atPoint: ]
				   ifFalse: [ #add:atPoint:span: ])
		  arguments: arguments
]

{ #category : 'testing' }
DdGridNode >> canAcceptChild [
"A grid cell is a position (column@row), not an index among siblings, so the generic
index-based insert/move/drag pipeline has no correct way to place a child here - it is
deliberately excluded from it. Use DdLayoutEditor>>insertGridWidget:into:atPosition:span:,
which builds the right add:atPoint:[span:] message directly, instead."

	^ false
]

{ #category : 'resizing' }
DdGridNode >> childResizeHandles [
"All eight: the left/top ones move the cell as well as change the span."

	^ DdResizeHandles allHandleNames
]

{ #category : 'testing' }
DdGridNode >> childrenAreOrdered [

	^ false
]

{ #category : 'constraints' }
DdGridNode >> constraintPropertiesFor: aChild [

	^ {
		  (DdConstraintProperty
			   key: #cell
			   label: 'Cell (column@row)'
			   kind: #point
			   default: 1 @ 1).
		  (DdConstraintProperty
			   key: #span
			   label: 'Span (columns@rows)'
			   kind: #point
			   default: 1 @ 1) }
]

{ #category : 'constraints' }
DdGridNode >> constraintValuesOf: aChild [

	aChild gridPosition ifNil: [ ^ nil ].
	^ Dictionary new
		  at: #cell put: aChild gridPosition;
		  at: #span put: aChild gridSpan;
		  yourself
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

{ #category : 'properties' }
DdGridNode >> layoutProperties [

	^ {
		  (DdLayoutProperty number: 'Border width' selector: #borderWidth:).
		  (DdLayoutProperty
			   number: 'Column spacing'
			   selector: #columnSpacing:).
		  (DdLayoutProperty number: 'Row spacing' selector: #rowSpacing:).
		  (DdLayoutProperty
			   flag: 'Same width for all columns'
			   on: #beColumnHomogeneous
			   off: #beColumnNotHomogeneous
			   default: true).
		  (DdLayoutProperty
			   flag: 'Same height for all rows'
			   on: #beRowHomogeneous
			   off: #beRowNotHomogeneous
			   default: true) }
]

{ #category : 'printing' }
DdGridNode >> printOn: aStream [

	aStream nextPutAll: 'Grid'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
