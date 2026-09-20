Class {
	#name : 'DdDropGeometry',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'geometry' }
DdDropGeometry class >> boundaryBefore: anIndex among: rectangles horizontal: aBoolean [
"The coordinate, along the layout direction, of the gap where item number anIndex would go."

	| before after |
	anIndex <= 1 ifTrue: [
		^ self leadingEdgeOf: rectangles first horizontal: aBoolean ].
	anIndex > rectangles size ifTrue: [
		^ self trailingEdgeOf: rectangles last horizontal: aBoolean ].
	before := self
		          trailingEdgeOf: (rectangles at: anIndex - 1)
		          horizontal: aBoolean.
	after := self
		         leadingEdgeOf: (rectangles at: anIndex)
		         horizontal: aBoolean.
	^ before + after // 2
]

{ #category : 'geometry' }
DdDropGeometry class >> indexAt: aPoint among: rectangles horizontal: aBoolean [
	"The 1-based position a dragged item takes among children with these rectangles
	when dropped at aPoint: after every child whose centre lies before the point."

	| coordinate |
	coordinate := aBoolean
		              ifTrue: [ aPoint x ]
		              ifFalse: [ aPoint y ].
	^ 1 + (rectangles count: [ :each |
			   (aBoolean
				    ifTrue: [ each center x ]
				    ifFalse: [ each center y ]) < coordinate ])
]

{ #category : 'geometry' }
DdDropGeometry class >> indicatorAt: anIndex among: rectangles in: containerRectangle horizontal: aBoolean [
"A thin rectangle marking where the dropped item will go; an empty container is outlined whole."

	| boundary line |
	rectangles isEmpty ifTrue: [ ^ containerRectangle insetBy: 3 ].
	boundary := self
		            boundaryBefore: anIndex
		            among: rectangles
		            horizontal: aBoolean.
	line := aBoolean
		        ifTrue: [
				        boundary - 1 @ containerRectangle top corner:
					        boundary + 1 @ containerRectangle bottom ]
		        ifFalse: [
				        containerRectangle left @ (boundary - 1) corner:
					        containerRectangle right @ (boundary + 1) ].
	^ line intersect: containerRectangle
]

{ #category : 'geometry' }
DdDropGeometry class >> leadingEdgeOf: aRectangle horizontal: aBoolean [
	^ aBoolean
		  ifTrue: [ aRectangle left ]
		  ifFalse: [ aRectangle top ]
]

{ #category : 'geometry' }
DdDropGeometry class >> trailingEdgeOf: aRectangle horizontal: aBoolean [
	^ aBoolean
		  ifTrue: [ aRectangle right ]
		  ifFalse: [ aRectangle bottom ]
]
