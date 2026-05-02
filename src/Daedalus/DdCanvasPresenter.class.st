Class {
	#name : 'DdCanvasPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'editedPresenter',
		'previewPresenter',
		'rootPreviewPresenter',
		'presenterIndex',
		'selectedPresenter',
		'selectionOverlay',
		'designer',
		'selectedSubPresenter'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdCanvasPresenter class >> onPresenter: aPresenter [
    
^ self new
        editedPresenter: aPresenter;
        yourself.
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> clickedMorphFromEvent: arg1 [

	| tmp1 |
	tmp1 := arg1 position.
	^ self deepestMorphAt: tmp1
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [

	| clickedMorph result |

	clickedMorph := self clickedMorphFromEvent: anEvent.
	clickedMorph ifNil: [ ^ self ].

	result := self presenterFromClickedMorph: clickedMorph.
	result ifNil: [ ^ self ].

	selectedPresenter := result key.
	selectedSubPresenter := result value.

	designer ifNotNil: [ designer onSelectionChanged ].

	(anEvent respondsTo: #wasHandled:) ifTrue: [
		anEvent wasHandled: true ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> deepestMorphAt: arg1 [

	| tmp1 |
	tmp1 := rootPreviewPresenter adapter widget.
	tmp1 ifNil: [ ^ nil ] ifNotNil: [ tmp1 ].
	^ self deepestMorphIn: tmp1 at: arg1
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> deepestMorphIn: arg1 at: arg2 [

	(arg1 fullBounds containsPoint: arg2) ifFalse: [ ^ nil ].
	arg1 submorphs reverseDo: [ :arg3 |
			| tmp1 |
			tmp1 := self deepestMorphIn: arg3 at: arg2.
			tmp1 ifNotNil: [ ^ tmp1 ] ].
	^ arg1
]

{ #category : 'layout' }
DdCanvasPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 30;
		  add: previewPresenter expand: false;
		  yourself
]

{ #category : 'accessing' }
DdCanvasPresenter >> designer: arg1 [

	designer := arg1
]

{ #category : 'accessing' }
DdCanvasPresenter >> editedPresenter: aPresenter [

	editedPresenter := aPresenter.
	self rebuildPreview
]

{ #category : 'initialization' }
DdCanvasPresenter >> initialize [

	super initialize.
	self announcer
]

{ #category : 'initialization' }
DdCanvasPresenter >> initializePresenters [

	super initializePresenters.
	previewPresenter := SpBoxLayout new
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> instVarNameForPresenterInRoot: aPresenter [ 
	| names |
	names := rootPreviewPresenter class allInstVarNames.
	1 to: rootPreviewPresenter class instSize do: [ :i |
		((rootPreviewPresenter instVarAt: i) == aPresenter)
			ifTrue: [ ^ names at: i ] ].
	^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> installClickHooks [

	| tmp1 tmp3 |
	tmp1 := rootPreviewPresenter adapter widget.
	tmp3 := 0.

	tmp1 allMorphsDo: [ :m |
			(m respondsTo: #removeActionsForEvent:) ifTrue: [
				m removeActionsForEvent: #mouseDown ] ].

	tmp1 allMorphsDo: [ :arg1 |
			(arg1 respondsTo: #on:send:to:) ifTrue: [
					arg1 on: #mouseDown send: #ddOnMouseDown: to: self.
					tmp3 := tmp3 + 1 ] ].
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterFromClickedMorph: aMorph [ 
    | m adapter spPresenter current |
    m := aMorph.
    [ m notNil ] whileTrue: [
        (m respondsTo: #model) ifTrue: [
            adapter := m model.
            (adapter respondsTo: #owner) ifTrue: [
                spPresenter := adapter owner.
                spPresenter ifNotNil: [
                    current := spPresenter owner.
                    [ current isKindOf: SpPresenter ] whileTrue: [
                        (presenterIndex presenters includes: current) ifTrue: [
                            (current class name beginsWith: 'Sp') ifFalse: [
                                ^ Association key: current value: spPresenter ] ].
                        current ifNil: [ ^ nil ].
                        current := current owner ] ] ] ].
        m := m owner ].
    ^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterIndex [

	^ presenterIndex
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [

	| newPresenter |
	newPresenter := editedPresenter class new.
	newPresenter application: self application.
	newPresenter build.
	rootPreviewPresenter := newPresenter.
	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.
	self layout: (SpBoxLayout newTopToBottom
			 spacing: 30;
			 add: rootPreviewPresenter expand: false;
			 yourself).
	self needRebuild: true.

	self updatePresenter.

	UIManager default defer: [ self installClickHooks ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [ 
    rootPreviewPresenter ifNil: [ ^ self rebuildPreview ].
    UIManager default defer: [ self installClickHooks ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [

	^ rootPreviewPresenter
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [

	^ selectedPresenter
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedSubPresenter [ 

    ^ selectedSubPresenter
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> updateLayoutMethodFor: aClass with: source [
    (aClass compiler compile: source)
        ifNil: [ self inform: 'Compilation error' ]
        ifNotNil: [
            self rebuildPreview.
            self inform: 'Updated!' ].

]
