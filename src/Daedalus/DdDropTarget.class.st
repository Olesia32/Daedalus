Class {
	#name : 'DdDropTarget',
	#superclass : 'Object',
	#instVars : [
		'containerPath',
		'index',
		'indicator',
		'isNoOp',
		'cell',
		'swapWithPath',
		'point'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'accessing' }
DdDropTarget >> cell [

	^ cell
]

{ #category : 'accessing' }
DdDropTarget >> cell: aPoint [

	cell := aPoint
]

{ #category : 'accessing' }
DdDropTarget >> containerPath [

	^ containerPath
]

{ #category : 'accessing' }
DdDropTarget >> containerPath: arg1 [

	containerPath := arg1
]

{ #category : 'accessing' }
DdDropTarget >> index [

	^ index
]

{ #category : 'accessing' }
DdDropTarget >> index: arg1 [

	index := arg1
]

{ #category : 'accessing' }
DdDropTarget >> indicator [

	^ indicator
]

{ #category : 'accessing' }
DdDropTarget >> indicator: arg1 [

	indicator := arg1
]

{ #category : 'testing' }
DdDropTarget >> isCellTarget [
"A drop into a grid cell (column@row) rather than at an index among siblings."

	^ cell notNil
]

{ #category : 'accessing' }
DdDropTarget >> isNoOp [

	^ isNoOp == true
]

{ #category : 'accessing' }
DdDropTarget >> isNoOp: arg1 [

	isNoOp := arg1
]

{ #category : 'testing' }
DdDropTarget >> isPointTarget [
"A drop at a free pixel position inside an absolute layout, rather than at an index or a grid cell."

	^ point notNil
]

{ #category : 'testing' }
DdDropTarget >> isSwap [
"A drop onto a cell already taken by another widget of the same grid: the two exchange cells
rather than one silently displacing the other."

	^ swapWithPath notNil
]

{ #category : 'accessing' }
DdDropTarget >> point [
	^ point
]

{ #category : 'accessing' }
DdDropTarget >> point: aPoint [
	point := aPoint
]

{ #category : 'printing' }
DdDropTarget >> printOn: aStream [

	aStream
		nextPutAll: 'DropTarget into ';
		print: containerPath.
	self isCellTarget
		ifTrue: [
				aStream
					nextPutAll: ' cell ';
					print: cell ]
		ifFalse: [
				self isPointTarget
					ifTrue: [
							aStream
								nextPutAll: ' point ';
								print: point ]
					ifFalse: [
							aStream
								nextPutAll: ' at ';
								print: index ] ]
]

{ #category : 'accessing' }
DdDropTarget >> swapWithPath [

	^ swapWithPath
]

{ #category : 'accessing' }
DdDropTarget >> swapWithPath: aPathOrNil [

	swapWithPath := aPathOrNil
]
