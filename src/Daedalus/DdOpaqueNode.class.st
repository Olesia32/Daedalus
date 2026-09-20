Class {
	#name : 'DdOpaqueNode',
	#superclass : 'DdLayoutNode',
	#instVars : [
		'expression'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'accessing' }
DdOpaqueNode >> expression [
	^ expression
]

{ #category : 'accessing' }
DdOpaqueNode >> expression: aNode [
	expression := aNode
]

{ #category : 'printing' }
DdOpaqueNode >> printOn: aStream [
	aStream
		nextPutAll: 'Opaque (';
		nextPutAll: expression class name;
		nextPut: $)
]

{ #category : 'labels' }
DdOpaqueNode >> treeLabel [
	| source |
	source := expression formattedCode withSeparatorsCompacted.
	source size > 40 ifTrue: [ source := (source first: 40) , '...' ].
	^ '<other> ' , source
]
