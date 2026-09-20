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
