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

	^ SpBoxLayout new
		  spacing: 30;
		  add: previewPresenter;
		  yourself
]

{ #category : 'accessing' }
DdCanvasPresenter >> designer [
  ^designer 
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

	| root |
	root := rootPreviewPresenter adapter widget.
	root ifNil: [ ^ self ].

	"Знімаємо старі обробники"
	root allMorphsDo: [ :m |
		(m respondsTo: #removeActionsForEvent:) ifTrue: [
			m removeActionsForEvent: #mouseDown ] ].

	presenterIndex presenters do: [ :p |
		(p adapter notNil and: [ p adapter widget notNil ]) ifTrue: [
			| w |
			w := p adapter widget.
			(w respondsTo: #on:send:to:) ifTrue: [
				w on: #mouseDown send: #ddOnMouseDown: to: self ] ] ].
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterFromClickedMorph: aMorph [

	| m list|
	list := presenterIndex presenters.
	m := aMorph.
	[ m notNil ] whileTrue: [
			presenterIndex presenters do: [ :p |
					(p adapter notNil and: [ p adapter widget == m ]) ifTrue: [
							| current |
							current := p owner.
							[ current isKindOf: SpPresenter ] whileTrue: [
									(presenterIndex presenters includes: current) ifTrue: [
											(current class name beginsWith: 'Sp') ifFalse: [
												^ Association key: current value: p ] ].
									current ifNil: [ ^ nil ].
									current := current owner ] ] ].
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
	newPresenter build.
	rootPreviewPresenter := newPresenter.
	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.
	self layout: (SpBoxLayout new
			 spacing: 30;
			 add: rootPreviewPresenter;
			 yourself).
	self needRebuild: true.

	self updatePresenter.
	UIManager default defer: [
		UIManager default defer: [  
			presenterIndex := DdPresenterIndex new
				buildFromRootPresenter: rootPreviewPresenter.
			self installClickHooks ] ]
]

{ #category : 'accessing' }
DdCanvasPresenter >> refreshPreview [

	| subVarName presenterVarName |
	subVarName := selectedSubPresenter ifNotNil: [
		              self instVarNameForPresenterInRoot:
			              selectedSubPresenter ].
	presenterVarName := selectedPresenter ifNotNil: [
		                    self instVarNameForPresenterInRoot:
			                    selectedPresenter ].

	 SpNullApplication skipReset: true.
    [
        rootPreviewPresenter initializePresenters.
        rootPreviewPresenter layout: rootPreviewPresenter defaultLayout.
    ] ensure: [ SpNullApplication skipReset: false ].

	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.

	presenterVarName ifNotNil: [
			| idx |
			idx := rootPreviewPresenter class allInstVarNames indexOf:
				       presenterVarName.
			idx > 0 ifTrue: [
				selectedPresenter := rootPreviewPresenter instVarAt: idx ] ].

	subVarName ifNotNil: [
			| idx |
			idx := rootPreviewPresenter class allInstVarNames indexOf:
				       subVarName.
			idx > 0 ifTrue: [
				selectedSubPresenter := rootPreviewPresenter instVarAt: idx ] ].

	UIManager default defer: [
			self installClickHooks.
			designer ifNotNil: [ designer onSelectionChanged ] ]
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
