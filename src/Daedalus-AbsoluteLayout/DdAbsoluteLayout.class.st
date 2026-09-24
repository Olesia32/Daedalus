"
I am a layout with absolute positioning: every child is placed at a fixed position (and, optionally, with a fixed extent), both in pixels and relative to my top-left corner. My children do not move or stretch when the container is resized. Children added later are drawn on top of the ones added earlier. Example: see the class-side example methods.
"
Class {
	#name : 'DdAbsoluteLayout',
	#superclass : 'SpExecutableLayout',
	#category : 'Daedalus-AbsoluteLayout',
	#package : 'Daedalus-AbsoluteLayout'
}

{ #category : 'examples' }
DdAbsoluteLayout class >> exampleForm [
	<example>
	| presenter |
	presenter := SpPresenter new.
	presenter layout: (self new
			 add: (presenter newLabel label: 'Name:')
			 atPoint: 20 @ 20
			 extent: 80 @ 25;
			 add: presenter newTextInput atPoint: 110 @ 20 extent: 180 @ 25;
			 add: (presenter newButton label: 'Ok')
			 atPoint: 110 @ 60
			 extent: 80 @ 30;
			 add: (presenter newButton label: 'Cancel')
			 atPoint: 200 @ 60
			 extent: 90 @ 30;
			 yourself).
	presenter open
]

{ #category : 'examples' }
DdAbsoluteLayout class >> exampleMoveAtRuntime [
	<example>
	| presenter layout label |
	presenter := SpPresenter new.
	layout := self new.
	layout
		add:
			(label := presenter newLabel label:
					          'I move when you press the button')
		atPoint: 20 @ 20
		extent: 260 @ 25;
		add: (presenter newButton
				 label: 'Move';
				 action: [
					 layout
						 move: label
						 toPoint: (layout positionOf: label) + (10 @ 10) ];
				 yourself)
		atPoint: 20 @ 70 extent: 80 @ 30.
	presenter layout: layout.
	presenter open
]

{ #category : 'examples' }
DdAbsoluteLayout class >> exampleOverlap [
"The child added last is drawn on top."

	<example>
	| presenter |
	presenter := SpPresenter new.
	presenter layout: (self new
			 add: (presenter newButton label: 'Below')
			 atPoint: 20 @ 20
			 extent: 160 @ 80;
			 add: (presenter newButton label: 'On top')
			 atPoint: 90 @ 60
			 extent: 160 @ 80;
			 yourself).
	presenter open
]

{ #category : 'private' }
DdAbsoluteLayout >> adapterName [
	^ #AbsoluteAdapter
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> add: aPresenterLayoutOrSymbol [
"Adds `aPresenterLayoutOrSymbol` at the top-left corner of the layout (0@0), with its natural extent.
`aPresenterLayoutOrSymbol` can be
- any instance of `SpPresenter` hierarchy,
- another layout or
- a Symbol, matching the name of the instance variable who will contain the element to add."

	^ self
		  add: aPresenterLayoutOrSymbol
		  withConstraints: [ :constraints |  ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> add: aPresenterLayoutOrSymbol atPoint: aPoint [
"Adds `aPresenterLayoutOrSymbol` with its top-left corner at `aPoint` (pixels, relative to the top-left
corner of the layout). The child keeps its natural extent."

	^ self
		  add: aPresenterLayoutOrSymbol
		  withConstraints: [ :constraints | constraints position: aPoint ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> add: aPresenterLayoutOrSymbol atPoint: aPoint extent: anExtent [
"Adds `aPresenterLayoutOrSymbol` with its top-left corner at `aPoint` and with the size `anExtent`
(both in pixels, relative to the top-left corner of the layout)."

	^ self
		  add: aPresenterLayoutOrSymbol
		  withConstraints: [ :constraints |
				  constraints
					  position: aPoint;
					  extent: anExtent ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> add: aPresenterLayoutOrSymbol bounds: aRectangle [
"Adds `aPresenterLayoutOrSymbol` occupying `aRectangle` (pixels, relative to the top-left corner of the layout)."

	^ self
		  add: aPresenterLayoutOrSymbol
		  withConstraints: [ :constraints | constraints bounds: aRectangle ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> add: aPresenterLayoutOrSymbol withConstraints: aBlock [
"Adds `aPresenterLayoutOrSymbol`, updating the constraints directly.
 `aBlock` receives one argument (an instance of `DdAbsoluteConstraints`), to be modified directly.
A child can be added only once: use #move:toPoint:, #resize:toExtent: or #place:bounds: to change it."

	(children includesKey: aPresenterLayoutOrSymbol) ifTrue: [
			^ self error:
				  aPresenterLayoutOrSymbol printString
				  , ' is already in this layout' ].
	super add: aPresenterLayoutOrSymbol withConstraints: aBlock.
	self announceChildAdded: aPresenterLayoutOrSymbol
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> boundsOf: aPresenter [
"Answer the rectangle occupied by a child, or nil if it keeps its natural extent."

	^ (self constraintsFor: aPresenter) bounds
]

{ #category : 'private' }
DdAbsoluteLayout >> constraintsChanged: constraints [
"Tell the adapter (if the layout is already built) that constraints were modified."

	self withAdapterDo: [ :anAdapter |
		anAdapter updateConstraints: constraints ]
]

{ #category : 'private' }
DdAbsoluteLayout >> constraintsClass [
	^ DdAbsoluteConstraints
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> extentOf: aPresenter [
"Answer the extent of a child, or nil if it keeps its natural extent."

	^ (self constraintsFor: aPresenter) extent
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> move: aPresenter toPoint: aPoint [
"Move a child (already added) so its top-left corner is at `aPoint`. Works also while the layout is displayed."

	| constraints |
	constraints := self constraintsFor: aPresenter.
	constraints position: aPoint.
	self constraintsChanged: constraints
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> place: aPresenter bounds: aRectangle [
"Set position and extent of a child (already added). Works also while the layout is displayed."

	| constraints |
	constraints := self constraintsFor: aPresenter.
	constraints bounds: aRectangle.
	self constraintsChanged: constraints
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> positionOf: aPresenter [
"Answer the top-left corner (pixels, relative to the layout) of a child."

	^ (self constraintsFor: aPresenter) position
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> presenterAt: index [

	^ children keyAtIndex: index
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> removeAll [
"Remove all presenters added to this layout."

	children ifEmpty: [ ^ self ].
	children keysDo: [ :each |
			(each isPresenter or: [ each isSpLayout ]) ifTrue: [
				each withAdapterDo: [ :anAdapter | anAdapter unsubscribe ] ] ].
	children removeAll.
	self withAdapterDo: [ :anAdapter | anAdapter removeAll ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> replace: aPresenter with: otherPresenter [
"Replace aPresenter with otherPresenter.
Original constraints (position and extent) will be preserved."

	self
		replace: aPresenter
		with: otherPresenter
		withConstraints: (self constraintsFor: aPresenter)
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> replace: aPresenter with: otherPresenter withConstraints: constraints [
"Replace aPresenter with otherPresenter, placing it according to `constraints`.
The replacement takes the place of aPresenter in the drawing order."

	children replaceKey: aPresenter with: otherPresenter.
	children at: otherPresenter put: constraints.

	self withAdapterDo: [ :anAdapter |
			anAdapter
				replace: aPresenter
				with: otherPresenter
				withConstraints: constraints ]
]

{ #category : 'api - adding' }
DdAbsoluteLayout >> replaceAtIndex: index with: aPresenter [
"Replace the presenter in `index` with aPresenter.
Original constraints will be preserved."

	self replace: (self presenterAt: index) with: aPresenter
]

{ #category : 'api - placement' }
DdAbsoluteLayout >> resize: aPresenter toExtent: anExtent [
"Set the extent of a child (already added). Works also while the layout is displayed."

	| constraints |
	constraints := self constraintsFor: aPresenter.
	constraints extent: anExtent.
	self constraintsChanged: constraints
]
