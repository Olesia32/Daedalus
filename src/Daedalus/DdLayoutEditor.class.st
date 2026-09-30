Class {
	#name : 'DdLayoutEditor',
	#superclass : 'Object',
	#instVars : [
		'ast',
		'root'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'containers' }
DdLayoutEditor class >> containerKinds [
"Kinds of container that can be created, as key -> label"

	^ {
		  (#verticalBox -> 'Vertical box').
		  (#horizontalBox -> 'Horizontal box').
		  (#verticalPaned -> 'Vertical paned').
		  (#horizontalPaned -> 'Horizontal paned').
		  (#grid -> 'Grid').
		  (#absolute -> 'Absolute layout').
		  (#scroll -> 'Scroll').
		  (#overlay -> 'Overlay') }
]

{ #category : 'instance creation' }
DdLayoutEditor class >> forClass: aClass [
	(aClass includesSelector: #defaultLayout) ifFalse: [
		^ self error: aClass name , ' has no defaultLayout of its own' ].
	^ self on: (aClass >> #defaultLayout) sourceCode
]

{ #category : 'containers' }
DdLayoutEditor class >> labelForKind: aKind [

	^ (self containerKinds
		   detect: [ :each | each key = aKind ]
		   ifNone: [ nil ])
		  ifNil: [ aKind asString ]
		  ifNotNil: [ :association | association value ]
]

{ #category : 'paths' }
DdLayoutEditor class >> movedPathFor: aSourcePath into: aTargetPath at: anIndex [
"The path of a node after moveAt:toBoxAt:index: with these arguments."

	^ (self shiftedTargetPath: aTargetPath afterRemoving: aSourcePath)
	  , { anIndex }
]

{ #category : 'instance creation' }
DdLayoutEditor class >> on: aSourceString [
	^ self new setSource: aSourceString
]

{ #category : 'paths' }
DdLayoutEditor class >> shiftedTargetPath: aTargetPath afterRemoving: aSourcePath [
"aTargetPath (a container, meant before a node is taken out) as it reads after aSourcePath is
removed: it shifts by one when the removed node sat earlier in the child list of one of its ancestors."

	| parentPath |
	parentPath := aSourcePath allButLast.
	(aTargetPath size > parentPath size and: [
			 (aTargetPath first: parentPath size) = parentPath and: [
				 (aTargetPath at: parentPath size + 1) > aSourcePath last ] ])
		ifFalse: [ ^ aTargetPath ].
	^ aTargetPath copy
		  at: parentPath size + 1
		  put: (aTargetPath at: parentPath size + 1) - 1;
		  yourself
]

{ #category : 'containers' }
DdLayoutEditor class >> sourceForContainerKind: aKind [
"An empty scroll/overlay has no property message of its own to keep the cascade at two
messages, so it is 'yourself; yourself' - the same shape removeChild: leaves behind."

	aKind = #verticalBox ifTrue: [
		^ 'SpBoxLayout newTopToBottom spacing: 4; yourself' ].
	aKind = #horizontalBox ifTrue: [
		^ 'SpBoxLayout newLeftToRight spacing: 4; yourself' ].
	aKind = #verticalPaned ifTrue: [
		^ 'SpPanedLayout newTopToBottom positionOfSlider: 0.5; yourself' ].
	aKind = #horizontalPaned ifTrue: [
		^ 'SpPanedLayout newLeftToRight positionOfSlider: 0.5; yourself' ].
	aKind = #grid ifTrue: [
		^ 'SpGridLayout new columnSpacing: 4; rowSpacing: 4; yourself' ].
	aKind = #absolute ifTrue: [
		^ 'DdAbsoluteLayout new removeAll; yourself' ].
	aKind = #scroll ifTrue: [
		^ 'SpScrollableLayout new yourself; yourself' ].
	aKind = #overlay ifTrue: [
		^ 'SpOverlayLayout new yourself; yourself' ].
	^ self error: 'Unknown container kind: ' , aKind printString
]

{ #category : 'containers' }
DdLayoutEditor class >> wrapOnlyKinds [
"Container kinds that only make sense around existing content: a scroll shows exactly one
child, an overlay puts things on top of a main child. They are created with Wrap, never empty
with Add."

	^ #( #scroll #overlay )
]

{ #category : 'containers' }
DdLayoutEditor >> addContainer: aKind near: aPath [
"Adds a new empty container inside the node at aPath when that is a container, otherwise
right after that node. Answers the path of the new container. Wrap-only kinds are refused."

	| node newIndex parentPath |
	(self class wrapOnlyKinds includes: aKind) ifTrue: [
			^ self error: (self class labelForKind: aKind)
				  ,
				  ' goes around existing content: select a widget or container and press Wrap' ].
	node := self nodeAt: aPath.
	(node isKindOf: DdBoxNode) ifTrue: [
			newIndex := node children size + 1.
			self insertContainer: aKind into: aPath at: newIndex.
			^ aPath , { newIndex } ].
	aPath isEmpty ifTrue: [
		^ self error: 'There is no container to add to' ].
	parentPath := aPath allButLast.
	newIndex := aPath last + 1.
	self insertContainer: aKind into: parentPath at: newIndex.
	^ parentPath , { newIndex }
]

{ #category : 'applying' }
DdLayoutEditor >> applyTo: aClass [
"Compiles the edited source as defaultLayout of aClass. Refuses to compile when the
layout mentions variables the class does not have (the compiler would ask a question)."

	| unknown method |
	unknown := self unknownVariablesIn: aClass.
	unknown isEmpty ifFalse: [
		^ self error: 'Unknown instance variables: ' , (', ' join: unknown) ].
	method := aClass compile: self source.
	method ifNil: [ ^ self error: 'Compilation failed' ].
	^ method
]

{ #category : 'accessing' }
DdLayoutEditor >> boxAt: aPath [
	| node |
	node := self nodeAt: aPath.
	(node isKindOf: DdBoxNode) ifFalse: [
		^ self error: 'Not a box container' ].
	^ node
]

{ #category : 'constraints' }
DdLayoutEditor >> constraintValuesAt: aPath [

	| node |
	node := self nodeAt: aPath.
	node parent ifNil: [ ^ nil ].
	^ node parent constraintValuesOf: node
]

{ #category : 'grid' }
DdLayoutEditor >> gridAddMessageFor: anArgumentNode cell: aCell span: aSpanOrNil [
"A detached add:atPoint:[span:] message for anArgumentNode - always the modern selector."

	^ (aSpanOrNil isNil or: [ aSpanOrNil = (1 @ 1) ])
		  ifTrue: [
				  OCMessageNode
					  receiver: (OCVariableNode named: 'layout')
					  selector: #add:atPoint:
					  arguments: {
							  anArgumentNode.
							  (OCParser parseExpression: aCell printString) } ]
		  ifFalse: [
				  OCMessageNode
					  receiver: (OCVariableNode named: 'layout')
					  selector: #add:atPoint:span:
					  arguments: {
							  anArgumentNode.
							  (OCParser parseExpression: aCell printString).
							  (OCParser parseExpression: aSpanOrNil printString) } ]
]

{ #category : 'grid' }
DdLayoutEditor >> gridOccupantIn: aGrid at: aCell ignoring: aNode [
"The child of aGrid that covers aCell (spans included), other than aNode, or nil."

	^ aGrid children
		  detect: [ :each |
				  each ~~ aNode and: [
						  each gridPosition notNil and: [
								  | position span |
								  position := each gridPosition.
								  span := each gridSpan.
								  (aCell x between: position x and: position x + span x - 1)
									  and: [
									  aCell y between: position y and: position y + span y - 1 ] ] ] ]
		  ifNone: [ nil ]
]

{ #category : 'absolute' }
DdLayoutEditor >> insertAbsoluteWidget: aVarName into: aPath atPoint: aPositionPoint extent: anExtentOrNil [

	| container detached node |
	container := self nodeAt: aPath.
	(container isKindOf: DdAbsoluteNode) ifFalse: [
		^ self error: 'Not an absolute layout' ].
	detached := anExtentOrNil
		            ifNil: [
				            OCMessageNode
					            receiver: (OCVariableNode named: 'layout')
					            selector: #add:atPoint:
					            arguments: {
							            (OCVariableNode named: aVarName).
							            (OCParser parseExpression:
								             aPositionPoint printString) } ]
		            ifNotNil: [
				            OCMessageNode
					            receiver: (OCVariableNode named: 'layout')
					            selector: #add:atPoint:extent:
					            arguments: {
							            (OCVariableNode named: aVarName).
							            (OCParser parseExpression:
								             aPositionPoint printString).
							            (OCParser parseExpression:
								             anExtentOrNil printString) } ].
	node := DdWidgetNode new
		        addMessage: detached;
		        yourself.
	container insertChildDirectly: node.
	self reparse
]

{ #category : 'containers' }
DdLayoutEditor >> insertContainer: aKind into: aPath at: anIndex [
	| target |
	target := self boxAt: aPath.
	target insertChild: (self newContainerNodeOfKind: aKind) at: anIndex.
	^ self reparse
]

{ #category : 'containers' }
DdLayoutEditor >> insertGridWidget: aVarName into: aPath atPosition: aPositionPoint span: aSpanPointOrNil [

	| grid existing detached node |
	grid := self nodeAt: aPath.
	(grid isKindOf: DdGridNode) ifFalse: [
		^ self error: 'Not a grid container' ].
	existing := grid children
		            detect: [ :each |
				            each constraintArguments notEmpty and: [
						            self
							            sameGridPosition: each constraintArguments first
							            as: aPositionPoint ] ]
		            ifNone: [ nil ].
	existing ifNotNil: [ grid removeChild: existing ].
	detached := aSpanPointOrNil
		            ifNil: [
				            OCMessageNode
					            receiver: (OCVariableNode named: 'layout')
					            selector: #add:atPoint:
					            arguments: {
							            (OCVariableNode named: aVarName).
							            (OCParser parseExpression:
								             aPositionPoint printString) } ]
		            ifNotNil: [
				            OCMessageNode
					            receiver: (OCVariableNode named: 'layout')
					            selector: #add:atPoint:span:
					            arguments: {
							            (OCVariableNode named: aVarName).
							            (OCParser parseExpression:
								             aPositionPoint printString).
							            (OCParser parseExpression:
								             aSpanPointOrNil printString) } ].
	node := DdWidgetNode new
		        addMessage: detached;
		        yourself.
	grid insertChildDirectly: node.
	self reparse
]

{ #category : 'editing' }
DdLayoutEditor >> insertWidget: aVarName into: aPath at: anIndex [
	| target detached node |
	target := self boxAt: aPath.
	"detached message: only its selector and arguments are used by insertChild:at:"
	detached := OCMessageNode
		            receiver: (OCVariableNode named: 'layout')
		            selector: #add:
		            arguments: { (OCVariableNode named: aVarName) }.
	node := DdWidgetNode new
		        addMessage: detached;
		        yourself.
	target insertChild: node at: anIndex.
	self reparse
]

{ #category : 'absolute' }
DdLayoutEditor >> moveAt: aSourcePath toAbsoluteAt: aPath point: aPoint [

	| node container first extent arguments |
	node := self nodeAt: aSourcePath.
	container := self nodeAt: aPath.
	(container isKindOf: DdAbsoluteNode) ifFalse: [
		^ self error: 'Not an absolute layout' ].
	node parent ifNil: [ ^ self error: 'Cannot move the root' ].
	(container == node or: [ container isDescendantOf: node ]) ifTrue: [
		^ self error: 'Cannot move a node into itself' ].
	first := node addMessage arguments first.
	extent := node addMessage selector = #add:atPoint:extent:
		          ifTrue: [ node addMessage arguments third copy ]
		          ifFalse: [ nil ].
	node parent removeChild: node.
	arguments := extent
		             ifNil: [
				             {
					             first.
					             (OCParser parseExpression: aPoint printString) } ]
		             ifNotNil: [
				             {
					             first.
					             (OCParser parseExpression: aPoint printString).
					             extent } ].
	node addMessage: (OCMessageNode
			 receiver: (OCVariableNode named: 'layout')
			 selector:
			 (extent
				  ifNil: [ #add:atPoint: ]
				  ifNotNil: [ #add:atPoint:extent: ])
			 arguments: arguments).
	container insertChildDirectly: node.
	self reparse
]

{ #category : 'editing' }
DdLayoutEditor >> moveAt: aSourcePath toBoxAt: aTargetPath index: anIndex [
"Both paths are resolved before any change. anIndex is the position among the
target's children AFTER the moved node has been taken out of its old place."

	| node target maxIndex |
	node := self nodeAt: aSourcePath.
	target := self boxAt: aTargetPath.
	node parent ifNil: [ ^ self error: 'Cannot move the root' ].
	(target == node or: [ target isDescendantOf: node ]) ifTrue: [
		^ self error: 'Cannot move a node into itself' ].
	(node parent == target or: [ target canAcceptChild ]) ifFalse: [
		^ self error: 'The target container cannot hold more children' ].
	maxIndex := node parent == target
		            ifTrue: [ target children size ]
		            ifFalse: [ target children size + 1 ].
	(anIndex between: 1 and: maxIndex) ifFalse: [
		^ self error: 'Index out of range' ].
	node parent removeChild: node.
	target insertChild: node at: anIndex.
	self reparse
]

{ #category : 'grid' }
DdLayoutEditor >> moveAt: aSourcePath toGridAt: aGridPath cell: aCell [
	"Moves the node at aSourcePath into the free cell aCell of the grid at aGridPath. A node already
in that grid keeps its span. A taken cell is refused, not silently replaced."

	| node grid span first |
	node := self nodeAt: aSourcePath.
	grid := self nodeAt: aGridPath.
	(grid isKindOf: DdGridNode) ifFalse: [
		^ self error: 'Not a grid container' ].
	node parent ifNil: [ ^ self error: 'Cannot move the root' ].
	(grid == node or: [ grid isDescendantOf: node ]) ifTrue: [
		^ self error: 'Cannot move a node into itself' ].
	(self gridOccupantIn: grid at: aCell ignoring: node) ifNotNil: [
		^ self error: 'That grid cell is already occupied' ].
	span := node parent == grid ifTrue: [ node gridSpan ].
	first := node addMessage arguments first.
	node parent removeChild: node.
	node addMessage:
		(self gridAddMessageFor: first cell: aCell span: span).
	grid insertChildDirectly: node.
	self reparse
]

{ #category : 'editing' }
DdLayoutEditor >> moveDownAt: aPath [
	| node |
	node := self nodeAt: aPath.
	node canMoveDown ifFalse: [
		^ self error: 'Cannot move this node down' ].
	^ self moveAt: aPath toBoxAt: aPath allButLast index: aPath last + 1
]

{ #category : 'editing' }
DdLayoutEditor >> moveUpAt: aPath [
	| node |
	node := self nodeAt: aPath.
	node canMoveUp ifFalse: [ ^ self error: 'Cannot move this node up' ].
	^ self moveAt: aPath toBoxAt: aPath allButLast index: aPath last - 1
]

{ #category : 'containers' }
DdLayoutEditor >> newContainerNodeOfKind: aKind [

	| expression detached |
	expression := OCParser parseExpression:
		              (self class sourceForContainerKind: aKind).
	detached := OCMessageNode
		            receiver: (OCVariableNode named: 'layout')
		            selector: #add:expand:
		            arguments: {
				            expression.
				            (OCParser parseExpression: 'false') }.
	^ DdLayoutParser new parseExpression: expression addMessage: detached
]

{ #category : 'accessing' }
DdLayoutEditor >> nodeAt: aPath [
"aPath is an Array of child indexes from the root, e.g. #(3 2) = 2nd child of the 3rd child"
	^ aPath inject: root into: [ :node :i | node children at: i ]
]

{ #category : 'editing' }
DdLayoutEditor >> removeAt: aPath [
	| node |
	node := self nodeAt: aPath.
	node parent ifNil: [ ^ self error: 'Cannot remove the root' ].
	node parent removeChild: node.
	self reparse
]

{ #category : 'properties' }
DdLayoutEditor >> removeMessage: aMessage fromCascade: aCascade [
"A cascade must never drop below two messages - Pharo prints a one-message cascade without
the semicolon, and it would no longer parse as a layout (see DdBoxNode>>removeChild:)."

	aCascade messages size <= 2 ifTrue: [
			aCascade messages add: (OCMessageNode
					 receiver: aCascade receiver copy
					 selector: #yourself
					 arguments: #(  )) ].
	aCascade messages removeAt:
		(aCascade messages identityIndexOf: aMessage)
]

{ #category : 'private' }
DdLayoutEditor >> reparse [
"The model is a snapshot: after every edit it is rebuilt from the formatted source."

	self setSource: ast formattedCode
]

{ #category : 'accessing' }
DdLayoutEditor >> root [
	^ root
]

{ #category : 'private' }
DdLayoutEditor >> sameGridPosition: aFormattedText as: aPoint [

	| cleaned parts |
	cleaned := aFormattedText select: [ :c |
		           c isDigit or: [ #( $@ $- ) includes: c ] ].
	parts := cleaned substrings: '@'.
	parts size = 2 ifFalse: [ ^ false ].
	^ [
		  parts first asInteger = aPoint x and: [
			  parts second asInteger = aPoint y ] ]
		  on: Error
		  do: [ :error | false ]
]

{ #category : 'properties' }
DdLayoutEditor >> set: aProperty to: aValue at: aPath [
"Writes aValue for aProperty of the container at aPath, replacing what was there. The message
keeps the place of the one it replaces; a new one goes first, before the children."

	| node cascade index message |
	node := self nodeAt: aPath.
	node isContainerNode ifFalse: [ ^ self error: 'Not a container' ].
	(node layoutProperties anySatisfy: [ :each |
		 each selector = aProperty selector ]) ifFalse: [
		^ self error: node kindLabel , ' has no property ' , aProperty label ].
	aProperty validate: aValue.
	cascade := node cascade.
	index := cascade messages findFirst: [ :each |
		         aProperty selectors includes: each selector ].
	(cascade messages select: [ :each |
		 aProperty selectors includes: each selector ]) do: [ :each |
		self removeMessage: each fromCascade: cascade ].
	message := aProperty
		           messageFor: aValue
		           receiver: cascade receiver copy.
	message ifNotNil: [
			message parent: cascade.
			index = 0 ifTrue: [ index := 1 ].
			cascade messages
				add: message
				beforeIndex: (index min: cascade messages size + 1) ].
	self reparse
]

{ #category : 'absolute' }
DdLayoutEditor >> setAbsoluteBoundsAt: aPath position: aPositionPoint extent: anExtentPoint [
"Rewrites the add-message of the absolute child at aPath as add:atPoint:extent:, whatever form
it had before (plain add:, add:atPoint:, add:bounds:)."

	| node |
	node := self nodeAt: aPath.
	(node parent isKindOf: DdAbsoluteNode) ifFalse: [
		^ self error: 'Not inside an absolute layout' ].
	node replaceAddMessageWith: (OCMessageNode
			 receiver: (OCVariableNode named: 'layout')
			 selector: #add:atPoint:extent:
			 arguments: {
					 node addMessage arguments first.
					 (OCParser parseExpression: aPositionPoint printString).
					 (OCParser parseExpression: anExtentPoint printString) }).
	self reparse
]

{ #category : 'editing' }
DdLayoutEditor >> setBoxSizeAt: aPath size: anInteger [

	| node box |
	node := self nodeAt: aPath.
	box := node parent.
	(box notNil and: [ box class == DdBoxNode ]) ifFalse: [
		^ self error: 'Not inside a box layout' ].
	node replaceAddMessageWith: (OCMessageNode
			 receiver: (OCVariableNode named: 'layout')
			 selector: (box isHorizontal
					  ifTrue: [ #add:width: ]
					  ifFalse: [ #add:height: ])
			 arguments: {
					 node addMessage arguments first.
					 (OCParser parseExpression: anInteger printString) }).
	self reparse
]

{ #category : 'constraints' }
DdLayoutEditor >> setConstraints: aDictionary at: aPath [
"Rewrites the add-message of the node at aPath from aDictionary (key -> value; a missing key
takes its default). Every value is checked before anything changes."

	| node container properties values |
	node := self nodeAt: aPath.
	container := node parent.
	container ifNil: [
		^ self error: 'The root layout is not inside a container' ].
	properties := container constraintPropertiesFor: node.
	properties isEmpty ifTrue: [
			^ self error:
				  'A child of ' , container kindLabel
				  , ' has no constraints to set' ].
	values := Dictionary new.
	properties do: [ :property |
			| value |
			value := aDictionary
				         at: property key
				         ifAbsent: [ property default ].
			property validate: value.
			values at: property key put: value ].
	(container isKindOf: DdGridNode) ifTrue: [
			| cell span |
			cell := values at: #cell.
			span := values at: #span.
			cell x to: cell x + span x - 1 do: [ :column |
					cell y to: cell y + span y - 1 do: [ :row |
							(self gridOccupantIn: container at: column @ row ignoring: node)
								ifNotNil: [
								^ self error: 'That area is taken by another widget' ] ] ] ].
	node replaceAddMessageWith:
		(container addMessageFor: node values: values).
	self reparse
]

{ #category : 'grid' }
DdLayoutEditor >> setGridCellAt: aPath position: aCell span: aSpan [
"Gives the grid child at aPath a new cell and span. Refused when the new area overlaps
another widget of the same grid."

	| node grid |
	node := self nodeAt: aPath.
	grid := node parent.
	(grid isKindOf: DdGridNode) ifFalse: [
		^ self error: 'Not inside a grid' ].
	(aCell x < 1 or: [ aCell y < 1 ]) ifTrue: [
		^ self error: 'A grid cell starts at 1@1' ].
	aCell x to: aCell x + aSpan x - 1 do: [ :column |
			aCell y to: aCell y + aSpan y - 1 do: [ :row |
					(self gridOccupantIn: grid at: column @ row ignoring: node)
						ifNotNil: [
						^ self error: 'That area is taken by another widget' ] ] ].
	node replaceAddMessageWith: (self
			 gridAddMessageFor: node addMessage arguments first
			 cell: aCell
			 span: aSpan).
	self reparse
]

{ #category : 'grid' }
DdLayoutEditor >> setGridPositionOf: aNode to: aCell [
"Rewrites just aNode's cell, keeping its own span (if any)."

	| span |
	span := aNode gridSpan = (1 @ 1)
		        ifTrue: [ nil ]
		        ifFalse: [ aNode gridSpan ].
	aNode replaceAddMessageWith: (self
			 gridAddMessageFor: aNode addMessage arguments first
			 cell: aCell
			 span: span)
]

{ #category : 'editing' }
DdLayoutEditor >> setPanedSliderAt: aPath position: aFraction [
"Sets positionOfSlider: of the paned layout at aPath, replacing the one it already has."

	| paned cascade message index |
	paned := self nodeAt: aPath.
	(paned isKindOf: DdPanedNode) ifFalse: [
		^ self error: 'Not a paned layout' ].
	cascade := paned cascade.
	message := OCMessageNode
		           receiver: cascade receiver copy
		           selector: #positionOfSlider:
		           arguments:
		           { (OCParser parseExpression: aFraction printString) }.
	message parent: cascade.
	index := cascade messages findFirst: [ :each |
		         each selector = #positionOfSlider: ].
	index = 0
		ifTrue: [ cascade messages addFirst: message ]
		ifFalse: [ cascade messages at: index put: message ].
	self reparse
]

{ #category : 'initialization' }
DdLayoutEditor >> setSource: aString [

	| candidate reconstructedExpression rebuilt |
	candidate := RBParser parseMethod: aString.
	reconstructedExpression := DdCascadeReconstructor
		                           reconstructedRootSourceFor: candidate.
	ast := candidate.
	reconstructedExpression ifNotNil: [
			[
				rebuilt := RBParser parseMethod:
					           'defaultLayout ^ ' , reconstructedExpression.
				ast := rebuilt ]
				on: Error
				do: [ :error | 
					 ] ].
	root := DdLayoutParser new parseMethodNode: ast
]

{ #category : 'accessing' }
DdLayoutEditor >> source [
	^ ast formattedCode
]

{ #category : 'grid' }
DdLayoutEditor >> swapGridCells: aSourcePath with: aSwapPath [
"Exchanges the cells of the two widgets - each keeps its own span."

	| node other nodeCell otherCell |
	node := self nodeAt: aSourcePath.
	other := self nodeAt: aSwapPath.
	nodeCell := node gridPosition.
	otherCell := other gridPosition.
	(nodeCell isNil or: [ otherCell isNil ]) ifTrue: [
		^ self error: 'Both widgets must already be in a grid to swap cells' ].
	self setGridPositionOf: node to: otherCell.
	self setGridPositionOf: other to: nodeCell.
	self reparse
]

{ #category : 'accessing' }
DdLayoutEditor >> treeString [
	^ root treeString
]

{ #category : 'applying' }
DdLayoutEditor >> unknownVariablesIn: aClass [

	| known |
	known := aClass allInstVarNames collect: [ :each | each asString ].
	^ (root ifNil: [ #(  ) ] ifNotNil: [ :r | r widgetNames ]) reject: [
		  :each | known includes: each asString ]
]

{ #category : 'properties' }
DdLayoutEditor >> valueOf: aProperty at: aPath [
	"The current value of aProperty for the container at aPath: a Boolean for a flag (its default
when neither selector is in the code), otherwise the number written in the code, or nil."

	| messages found |
	messages := (self nodeAt: aPath) cascade messages.
	aProperty isFlag ifTrue: [
			(messages anySatisfy: [ :each | each selector = aProperty selector ])
				ifTrue: [ ^ true ].
			(messages anySatisfy: [ :each |
				 each selector = aProperty offSelector ]) ifTrue: [ ^ false ].
			^ aProperty default ].
	found := messages
		         detect: [ :each | each selector = aProperty selector ]
		         ifNone: [ ^ nil ].
	"Only a literal can be edited in a field; an expression (a variable, a computation) reads as nil."
	^ found arguments first isLiteralNode ifTrue: [
		  found arguments first value ]
]

{ #category : 'containers' }
DdLayoutEditor >> wrapAt: aPath in: aKind [
"Replaces the node at aPath with a new container that holds it. The container takes the place
and the constraints of the node in its parent (expand:, width: ...); the node becomes a plain
child - or, in a grid, the child of its first cell. Answers aPath, where the container now is."

	| node parent index container originalMessage containerMessage plainMessage isGrid |
	node := self nodeAt: aPath.
	parent := node parent.
	parent ifNil: [ ^ self error: 'Cannot wrap the root' ].
	index := parent children identityIndexOf: node.
	container := self newContainerNodeOfKind: aKind.
	isGrid := container isKindOf: DdGridNode.
	originalMessage := node addMessage.
	parent removeChild: node.
	containerMessage := OCMessageNode
		                    receiver: (OCVariableNode named: 'layout')
		                    selector: originalMessage selector
		                    arguments:
			                    { container addMessage arguments first }
			                    , originalMessage arguments allButFirst asArray.
	container addMessage: containerMessage.
	plainMessage := isGrid
		                ifTrue: [
				                self
					                gridAddMessageFor:
					                originalMessage arguments first
					                cell: 1 @ 1
					                span: nil ]
		                ifFalse: [
				                OCMessageNode
					                receiver: (OCVariableNode named: 'layout')
					                selector: #add:
					                arguments: { originalMessage arguments first } ].
	node addMessage: plainMessage.
	parent insertChild: container at: index.
	isGrid
		ifTrue: [ container insertChildDirectly: node ]
		ifFalse: [ container insertChild: node at: 1 ].
	self reparse.
	^ aPath
]
