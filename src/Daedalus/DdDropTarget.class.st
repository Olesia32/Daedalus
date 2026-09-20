Class {
	#name : 'DdDropTarget',
	#superclass : 'Object',
	#instVars : [
		'containerPath',
		'index',
		'indicator',
		'isNoOp'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdDropTarget >> containerPath [
	^ containerPath
]

{ #category : 'accessing' }
DdDropTarget >> containerPath: aPath [
	containerPath := aPath
]

{ #category : 'accessing' }
DdDropTarget >> index [
	^ index
]

{ #category : 'accessing' }
DdDropTarget >> index: anInteger [
	index := anInteger
]

{ #category : 'accessing' }
DdDropTarget >> indicator [
	^ indicator
]

{ #category : 'accessing' }
DdDropTarget >> indicator: aRectangle [
	indicator := aRectangle
]

{ #category : 'accessing' }
DdDropTarget >> isNoOp [
"True when dropping here would put the dragged node exactly where it already is."

	^ isNoOp == true
]

{ #category : 'accessing' }
DdDropTarget >> isNoOp: aBoolean [
	isNoOp := aBoolean
]

{ #category : 'printing' }
DdDropTarget >> printOn: aStream [
	aStream
		nextPutAll: 'DropTarget into ';
		print: containerPath;
		nextPutAll: ' at ';
		print: index
]
