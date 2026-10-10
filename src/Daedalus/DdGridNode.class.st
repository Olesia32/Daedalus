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

	| cell span hAlign vAlign arguments parts |
	cell := aDictionary at: #cell.
	span := aDictionary at: #span.
	hAlign := aDictionary at: #hAlign ifAbsent: [ #none ].
	vAlign := aDictionary at: #vAlign ifAbsent: [ #none ].
	(cell x < 1 or: [ cell y < 1 ]) ifTrue: [
		^ self error: 'A grid cell starts at 1@1' ].
	(span x < 1 or: [ span y < 1 ]) ifTrue: [
		^ self error: 'A span is at least 1@1' ].
	(hAlign = #none and: [ vAlign = #none ]) ifTrue: [
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
				  arguments: arguments ].
	parts := OrderedCollection new.
	parts add: 'position: ' , cell printString.
	span = (1 @ 1) ifFalse: [ parts add: 'span: ' , span printString ].
	hAlign = #none ifFalse: [
		parts add: 'hAlign' , hAlign asString capitalized ].
	vAlign = #none ifFalse: [
		parts add: 'vAlign' , vAlign asString capitalized ].
	^ OCMessageNode
		  receiver: (OCVariableNode named: 'layout')
		  selector: #add:withConstraints:
		  arguments: {
				  aChild addMessage arguments first.
				  (DdLayoutNode blockSource: parts) }
]

{ #category : 'testing' }
DdGridNode >> canAcceptChild [
"A grid cell is a position (column@row), not an index among siblings, so the generic
index-based insert/move/drag pipeline has no correct way to place a child here - it is
deliberately excluded from it. Use DdLayoutEditor>>insertGridWidget:into:atPosition:span:,
which builds the right add:atPoint:[span:] message directly, instead."

	^ false
]

{ #category : 'cells' }
DdGridNode >> childBlocking: aCell span: aSpan ignoring: aNode [
"The first child other than aNode whose area overlaps the area aCell/aSpan, or nil."

	^ children
		  detect: [ :each |
				  each ~~ aNode and: [
						  each gridPosition notNil and: [
								  | position span |
								  position := each gridPosition.
								  span := each gridSpan.
								  position x < (aCell x + aSpan x) and: [
										  aCell x < (position x + span x) and: [
												  position y < (aCell y + aSpan y) and: [
													  aCell y < (position y + span y) ] ] ] ] ] ]
		  ifNone: [ nil ]
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
"Without alignment a child fills its cell; with it, it keeps its natural size inside the cell
(SpMorphicGridAdapter>>basicApplyChildrenAlignmentTo:constraints: shrink-wraps it)."

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
			   default: 1 @ 1).
		  (DdConstraintProperty
			   key: #hAlign
			   label: 'Horizontal align'
			   choices: #( #none #start #center #end )
			   default: #none).
		  (DdConstraintProperty
			   key: #vAlign
			   label: 'Vertical align'
			   choices: #( #none #start #center #end )
			   default: #none) }
]

{ #category : 'constraints' }
DdGridNode >> constraintValuesOf: aChild [

	| values message |
	aChild gridPosition ifNil: [ ^ nil ].
	values := Dictionary new
		          at: #cell put: aChild gridPosition;
		          at: #span put: aChild gridSpan;
		          at: #hAlign put: #none;
		          at: #vAlign put: #none;
		          yourself.
	message := aChild addMessage.
	message selector = #add:withConstraints: ifFalse: [ ^ values ].
	(DdLayoutNode blockMessagesOf: message arguments second)
		ifNil: [ ^ nil ]
		ifNotNil: [ :messages |
				messages do: [ :each |
						| name |
						name := each selector asString.
						(#( #position: #span: ) includes: each selector) ifFalse: [
								((name beginsWith: 'hAlign') or: [ name beginsWith: 'vAlign' ])
									ifFalse: [ ^ nil ].
								(#( 'Start' 'Center' 'End' ) includes: (name allButFirst: 6))
									ifFalse: [ ^ nil ].
								values
									at: (name first: 6) asSymbol
									put: (name allButFirst: 6) asLowercase asSymbol ] ] ].
	^ values
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

{ #category : 'cells' }
DdGridNode >> isRowHomogeneous [
"As the code says it; Spec's default (SpGridLayout>>initialize, Pharo 13) is false."

	cascade messages reverseDo: [ :each |
			each selector = #beRowHomogeneous ifTrue: [ ^ true ].
			each selector = #beRowNotHomogeneous ifTrue: [ ^ false ] ].
	^ false
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
			   default: false).
		  (DdLayoutProperty
			   indexList: 'Expanding columns'
			   selector: #column:expand:).
		  (DdLayoutProperty
			   indexList: 'Expanding rows'
			   selector: #row:expand:) }
]

{ #category : 'printing' }
DdGridNode >> printOn: aStream [

	aStream nextPutAll: 'Grid'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]

{ #category : 'cells' }
DdGridNode >> rowsWithoutOwnHeightIn: aCell span: aSpan ignoring: aNode [

	self isRowHomogeneous ifTrue: [ ^ #(  ) ].
	aSpan y = 1 ifTrue: [ ^ #(  ) ].
	^ (aCell y to: aCell y + aSpan y - 1) asArray reject: [ :row |
			  children anySatisfy: [ :each |
					  each ~~ aNode and: [
							  each gridPosition notNil and: [
								  each gridPosition y = row and: [ each gridSpan y = 1 ] ] ] ] ]
]
