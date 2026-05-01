Class {
	#name : 'DdCanvasPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'editedPresenter',
		'previewPresenter',
		'rootPreviewPresenter',
		'presenterIndex',
		'selectedPresenter',
		'selectionOverlay'
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
DdCanvasPresenter >> clickedMorphFromEvent: anEvent [
    (anEvent respondsTo: #target) ifTrue: [ 
        anEvent target ifNotNil: [ ^ anEvent target ] ].

    (anEvent respondsTo: #source) ifTrue: [ 
        anEvent source ifNotNil: [ ^ anEvent source ] ].

    (anEvent respondsTo: #receiver) ifTrue: [ 
        anEvent receiver ifNotNil: [ ^ anEvent receiver ] ].

    ^ nil
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [

	| clickedMorph presenter |
	Transcript show: 'CLICK'; cr.
	clickedMorph := self clickedMorphFromEvent: anEvent.
	clickedMorph ifNil: [ ^ self ].

	presenter := presenterIndex presenterAtClickedMorph: clickedMorph.
	presenter ifNil: [ ^ self ].

	selectedPresenter := presenter.
	self logSelectionFor: presenter clickedMorph: clickedMorph.

	(anEvent respondsTo: #wasHandled:) ifTrue: [
		anEvent wasHandled: true ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseUp: anEvent [
    self ddOnMouseDown: anEvent
]

{ #category : 'layout' }
DdCanvasPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 30;
		  add: previewPresenter expand: false;
		  yourself
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> defaultLayoutSourceOf: aClass [

	| method |
	method := aClass compiledMethodAt: #defaultLayout.
	^ method sourceCode
]

{ #category : 'accessing' }
DdCanvasPresenter >> editedPresenter: aPresenter [

	editedPresenter := aPresenter.
	self rebuildPreview
]

{ #category : 'initialization' }
DdCanvasPresenter >> initializePresenters [

	previewPresenter := SpBoxLayout new.
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

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> installClickHookOnWidget: aWidget [
    aWidget on: #mouseDown send: #ddOnMouseDown: to: self.
    aWidget submorphs do: [ :sub |
        self installClickHookOnWidget: sub ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> installClickHooks [
    | root |
    root := rootPreviewPresenter adapter widget.

    root allMorphsDo: [ :m |
        (m respondsTo: #on:send:to:) ifTrue: [
            m on: #mouseDown send: #ddOnMouseDown: to: self ].
    ].
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> logSelectionFor: aPresenter clickedMorph: aMorph [ 
	| varName |
	varName := self instVarNameForPresenterInRoot: aPresenter.

	Transcript
		show: 'Selected presenter: '; show: aPresenter class name;
		show: ' | instVar in root: '; show: varName printString;
		show: ' | clicked morph: '; show: aMorph class name;
		cr.
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> presenterFromClickedMorph: aMorph [ 
	| m |
	m := aMorph.
	[ m notNil ] whileTrue: [
		(presenterIndex presenterForWidget: m) ifNotNil: [ :found | ^ found ].
		m := m owner ].
	^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterIndex [
 ^ presenterIndex 
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [
    rootPreviewPresenter := editedPresenter class new.
    previewPresenter removeAll; add: rootPreviewPresenter.
    presenterIndex := DdPresenterIndex new buildFromRootPresenter: rootPreviewPresenter.
    [ self installClickHooks ] fork
]

{ #category : 'accessing' }
DdCanvasPresenter >> rootPreviewPresenter [
  ^ rootPreviewPresenter 
]

{ #category : 'accessing' }
DdCanvasPresenter >> selectedPresenter [
    ^ selectedPresenter
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> updateLayoutMethodFor: aClass with: source [
    (aClass compiler compile: source)
        ifNil: [ self inform: 'Compilation error' ]
        ifNotNil: [
            self rebuildPreview.
            self inform: 'Updated!' ].

]
