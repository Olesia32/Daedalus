Class {
	#name : 'DdCanvasMap',
	#superclass : 'Object',
	#instVars : [
		'root',
		'morphs',
		'complete'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdCanvasMap class >> presenter: aPresenter model: aRootNode [
"Maps every node of the layout model to the morph the preview built for it. The two trees
are parallel: the model is parsed from the same code that produced the live layout objects."

	^ self new buildFrom: aPresenter model: aRootNode
]

{ #category : 'accessing' }
DdCanvasMap >> boundsAt: aPath [
	"Bounds of the node's morph in world coordinates, or nil."

	^ (self morphAt: aPath) ifNotNil: [ :morph | morph boundsInWorld ]
]

{ #category : 'building' }
DdCanvasMap >> buildFrom: aPresenter model: aRootNode [
	root := aRootNode.
	aRootNode ifNil: [ ^ self ].
	aPresenter layout isSpLayout ifFalse: [
			complete := false.
			^ self ].
	self mapNode: aRootNode to: aPresenter layout at: #(  )
]

{ #category : 'finding' }
DdCanvasMap >> dropTargetAt: aPoint dragging: aPathOrNil [
	^ self finder targetAt: aPoint dragging: aPathOrNil
]

{ #category : 'finding' }
DdCanvasMap >> finder [
	^ DdDropTargetFinder
		  root: root
		  rectangles: [ :path | self boundsAt: path ]
]

{ #category : 'debugging' }
DdCanvasMap >> flash [
"Outlines every mapped morph for three seconds: containers blue, widgets green."

	| frames |
	frames := OrderedCollection new.
	morphs keysAndValuesDo: [ :path :morph |
			morph ifNotNil: [
					| frame |
					frame := BorderedMorph new.
					frame
						color: Color transparent;
						borderColor: ((root nodeAtPath: path) isContainerNode
								 ifTrue: [ Color blue ]
								 ifFalse: [ Color green ]);
						borderWidth: 1.
					frame openInWorld.
					frame bounds: morph boundsInWorld.
					frames add: frame ] ].
	[
		(Delay forSeconds: 3) wait.
		UIManager default defer: [ frames do: [ :each | each delete ] ] ]
		fork
]

{ #category : 'initialization' }
DdCanvasMap >> initialize [
	super initialize.
	morphs := Dictionary new.
	complete := true
]

{ #category : 'accessing' }
DdCanvasMap >> isComplete [
	"False when the live layout did not match the model, so some nodes have no morph."

	^ complete
]

{ #category : 'building' }
DdCanvasMap >> mapNode: aNode to: aLiveItem at: aPath [

	| liveChildren |
	morphs at: aPath put: (self morphOf: aLiveItem).
	aNode children isEmpty ifTrue: [ ^ self ].
	aLiveItem isSpLayout ifFalse: [
			complete := false.
			^ self ].
	liveChildren := aLiveItem children.
	liveChildren size = aNode children size ifFalse: [
			complete := false.
			^ self ].
	1 to: liveChildren size do: [ :i |
			self
				mapNode: (aNode children at: i)
				to: (liveChildren at: i)
				at: aPath , { i } ]
]

{ #category : 'accessing' }
DdCanvasMap >> morphAt: aPath [
	^ morphs at: aPath ifAbsent: [ nil ]
]

{ #category : 'building' }
DdCanvasMap >> morphOf: aLiveItem [
	"A layout has its own panel morph; a presenter its widget. Names not yet resolved have neither."

	(aLiveItem isSpLayout or: [ aLiveItem respondsTo: #adapter ])
		ifFalse: [ ^ nil ].
	^ aLiveItem adapter ifNotNil: [ :anAdapter | anAdapter widget ]
]
