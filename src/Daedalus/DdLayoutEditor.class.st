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
		  (#horizontalPaned -> 'Horizontal paned') }
]

{ #category : 'instance creation' }
DdLayoutEditor class >> forClass: aClass [
	(aClass includesSelector: #defaultLayout) ifFalse: [
		^ self error: aClass name , ' has no defaultLayout of its own' ].
	^ self on: (aClass >> #defaultLayout) sourceCode
]

{ #category : 'paths' }
DdLayoutEditor class >> movedPathFor: aSourcePath into: aTargetPath at: anIndex [
"The path of a node after moveAt:toBoxAt:index: with these arguments. The target path is meant
before the move; it shifts by one when the removed node sat earlier in the child list of one of
the target's ancestors."

	| parentPath adjusted |
	parentPath := aSourcePath allButLast.
	adjusted := aTargetPath.
	(aTargetPath size > parentPath size and: [
			 (aTargetPath first: parentPath size) = parentPath and: [
				 (aTargetPath at: parentPath size + 1) > aSourcePath last ] ])
		ifTrue: [
				adjusted := aTargetPath copy.
				adjusted
					at: parentPath size + 1
					put: (aTargetPath at: parentPath size + 1) - 1 ].
	^ adjusted , { anIndex }
]

{ #category : 'instance creation' }
DdLayoutEditor class >> on: aSourceString [
	^ self new setSource: aSourceString
]

{ #category : 'containers' }
DdLayoutEditor class >> sourceForContainerKind: aKind [
"An empty container as a cascade, the only form the parser recognises."

	aKind = #verticalBox ifTrue: [
		^ 'SpBoxLayout newTopToBottom spacing: 4; yourself' ].
	aKind = #horizontalBox ifTrue: [
		^ 'SpBoxLayout newLeftToRight spacing: 4; yourself' ].
	aKind = #verticalPaned ifTrue: [
		^ 'SpPanedLayout newTopToBottom positionOfSlider: 0.5; yourself' ].
	aKind = #horizontalPaned ifTrue: [
		^ 'SpPanedLayout newLeftToRight positionOfSlider: 0.5; yourself' ].
	^ self error: 'Unknown container kind: ' , aKind printString
]

{ #category : 'containers' }
DdLayoutEditor >> addContainer: aKind near: aPath [
	"Adds a new empty container inside the node at aPath when that is a container, otherwise
	right after that node. Answers the path of the new container."

	| node newIndex parentPath |
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

{ #category : 'containers' }
DdLayoutEditor >> insertContainer: aKind into: aPath at: anIndex [
	| target |
	target := self boxAt: aPath.
	target insertChild: (self newContainerNodeOfKind: aKind) at: anIndex.
	^ self reparse
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
	"A detached container node. Its expression sits in a placeholder add: message,
	which insertChild:at: replaces with a real one."

	| expression detached |
	expression := OCParser parseExpression:
		              (self class sourceForContainerKind: aKind).
	detached := OCMessageNode
		            receiver: (OCVariableNode named: 'layout')
		            selector: #add:
		            arguments: { expression }.
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

{ #category : 'private' }
DdLayoutEditor >> reparse [
"The model is a snapshot: after every edit it is rebuilt from the formatted source."

	self setSource: ast formattedCode
]

{ #category : 'accessing' }
DdLayoutEditor >> root [
	^ root
]

{ #category : 'initialization' }
DdLayoutEditor >> setSource: aString [
	ast := RBParser parseMethod: aString.
	root := DdLayoutParser new parseMethodNode: ast
]

{ #category : 'accessing' }
DdLayoutEditor >> source [
	^ ast formattedCode
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

{ #category : 'containers' }
DdLayoutEditor >> wrapAt: aPath in: aKind [
	"Replaces the node at aPath with a new container that holds it. The container takes the place
	and the constraints of the node in its parent (expand:, width: ...); the node becomes a plain child.
	Answers aPath, where the container now is."

	| node parent index container originalMessage containerMessage plainMessage |
	node := self nodeAt: aPath.
	parent := node parent.
	parent ifNil: [ ^ self error: 'Cannot wrap the root' ].
	index := parent children identityIndexOf: node.
	container := self newContainerNodeOfKind: aKind.
	originalMessage := node addMessage.
	parent removeChild: node.
	containerMessage := OCMessageNode
		                    receiver: (OCVariableNode named: 'layout')
		                    selector: originalMessage selector
		                    arguments:
			                    { container addMessage arguments first }
			                    , originalMessage arguments allButFirst asArray.
	container addMessage: containerMessage.
	plainMessage := OCMessageNode
		                receiver: (OCVariableNode named: 'layout')
		                selector: #add:
		                arguments: { originalMessage arguments first }.
	node addMessage: plainMessage.
	parent insertChild: container at: index.
	container insertChild: node at: 1.
	self reparse.
	^ aPath
]
