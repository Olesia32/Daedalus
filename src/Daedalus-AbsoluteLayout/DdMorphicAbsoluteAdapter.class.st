"
I am the Morphic adapter of DdAbsoluteLayout. I build a panel with a ProportionalLayout and I place every child with a LayoutFrame whose fractions are all zero, so that the offsets are plain pixels.
"
Class {
	#name : 'DdMorphicAbsoluteAdapter',
	#superclass : 'SpMorphicLayoutAdapter',
	#category : 'Daedalus-AbsoluteLayout',
	#package : 'Daedalus-AbsoluteLayout'
}

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter class >> adaptingName [
"The name used by the adapter bindings, matching DdAbsoluteLayout>>#adapterName.
It is written explicitly because the class name does not have the SpMorphic prefix."

	^ #AbsoluteAdapter
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> adapterOfChild: aPresenterLayoutOrSymbol [
	"Answer the adapter of a child, or nil if it cannot be found (e.g. it was added as a String
that was converted to a presenter when the layout was built)."

	| resolved |
	resolved := aPresenterLayoutOrSymbol isSymbol
		            ifTrue: [
			            self presenter
				            presenterAt: aPresenterLayoutOrSymbol
				            ifAbsent: [ nil ] ]
		            ifFalse: [ aPresenterLayoutOrSymbol ].

	^ (resolved isPresenter or: [ resolved isSpLayout ]) ifTrue: [
		  resolved adapter ]
]

{ #category : 'protocol' }
DdMorphicAbsoluteAdapter >> add: aPresenter [
	self add: aPresenter constraints: DdAbsoluteConstraints new
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> addConstraints: constraints toChild: childMorph [
"Adds constraints by child: the frame is computed before touching the resizing of the morph,
so a child without explicit extent keeps the extent it was built with."

	childMorph
		layoutFrame: (self frameFor: constraints of: childMorph);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setProperty: #absoluteConstraints toValue: constraints.

	^ childMorph
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> basicAdd: aPresenter constraints: constraints to: aPanel [
	| childMorph |
	childMorph := self buildMorph: aPresenter constraints: constraints.

	"the last child added is the one on top"
	aPanel addMorphFront: childMorph.
	self growPanel: aPanel toFit: constraints of: childMorph.

	^ childMorph
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> children [
	"In drawing order: the first one is the one at the back."

	^ widget submorphs reversed
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> childrenWidgets [
	^ self children
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> frameFor: constraints of: aMorph [
"All fractions are zero: offsets are absolute pixels measured from the top-left corner of the panel."

	| origin corner |
	origin := constraints position.
	corner := origin + (constraints extent ifNil: [ aMorph extent ]).

	^ LayoutFrame identity
		  leftFraction: 0;
		  topFraction: 0;
		  rightFraction: 0;
		  bottomFraction: 0;
		  leftOffset: origin x;
		  topOffset: origin y;
		  rightOffset: corner x;
		  bottomOffset: corner y;
		  yourself
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> growPanel: aPanel toFit: constraints of: childMorph [
"Make the panel (never smaller than) the area covered by the child, so a window opens showing all its content."

	| corner |
	corner := constraints position
	          + (constraints extent ifNil: [ childMorph extent ]).
	aPanel extent: (aPanel extent max: corner)
]

{ #category : 'protocol' }
DdMorphicAbsoluteAdapter >> layout: aLayout [
"Build of widget was differed up to here (as in the other layout adapters)"

	layout := aLayout.

	widget ifNil: [ widget := self newPanel ].

	aLayout whenChildrenAddedDo: [ :ann |
		self add: ann child constraints: (aLayout constraintsFor: ann child) ].

	aLayout whenChildrenRemovedDo: [ :ann | self remove: ann child ].

	super layout: aLayout
]

{ #category : 'factory' }
DdMorphicAbsoluteAdapter >> newPanel [
"A panel where children are placed by LayoutFrames (see #frameFor:of:)"

	^ self newPanelWith: ProportionalLayout new
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> remove: aPresenterLayoutOrSymbol [
	| childAdapter |
	childAdapter := self adapterOfChild: aPresenterLayoutOrSymbol.
	childAdapter ifNil: [ ^ self ].

	childAdapter unsubscribe.
	widget removeMorph: childAdapter widget.
	self verifyExtent
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> removeAll [
	widget removeAllMorphs.
	self verifyExtent
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> removeSubWidgets [
	widget removeAllMorphs
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> replace: aPresenter with: otherPresenter [
	self
		replace: aPresenter
		with: otherPresenter
		withConstraints: (layout constraintsFor: otherPresenter)
]

{ #category : 'accessing' }
DdMorphicAbsoluteAdapter >> replace: aPresenter with: otherPresenter withConstraints: constraints [
	| oldAdapter newMorph |
	oldAdapter := self adapterOfChild: aPresenter.
	oldAdapter ifNil: [ ^ self ].

	otherPresenter isPresenter ifTrue: [
		otherPresenter owner: self model ].
	newMorph := self buildMorph: otherPresenter constraints: constraints.
	widget replaceSubmorph: oldAdapter widget by: newMorph.
	oldAdapter unsubscribe.
	self growPanel: widget toFit: constraints of: newMorph
]

{ #category : 'styling' }
DdMorphicAbsoluteAdapter >> styleName [
"Name used to look for styles in the stylesheet (e.g. .absolute)"

	^ 'absolute'
]

{ #category : 'updating' }
DdMorphicAbsoluteAdapter >> updateConstraints: constraints [
"The constraints of a child changed: place its morph again."

	| childMorph |
	childMorph := widget submorphs
		              detect: [ :each |
		              (each valueOfProperty: #absoluteConstraints)
		              == constraints ]
		              ifNone: [ ^ self ].

	childMorph layoutFrame: (self frameFor: constraints of: childMorph).
	self growPanel: widget toFit: constraints of: childMorph.
	widget layoutChanged
]

{ #category : 'private' }
DdMorphicAbsoluteAdapter >> verifyExtent [
	widget hasSubmorphs ifFalse: [ widget extent: 0 @ 0 ]
]
