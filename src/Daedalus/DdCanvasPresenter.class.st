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
	(anEvent respondsTo: #target) ifTrue: [ ^ anEvent target ].
	(anEvent respondsTo: #receiver) ifTrue: [ ^ anEvent receiver ].
	(anEvent respondsTo: #morph) ifTrue: [ ^ anEvent morph ].
	^ nil
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [ 
	| clickedMorph p |
	clickedMorph := self clickedMorphFromEvent: anEvent.
	clickedMorph ifNil: [ ^ self ].

	p := self presenterFromClickedMorph: clickedMorph.
	p ifNil: [ ^ self ].

	selectedPresenter := p.
	self logSelectionFor: p clickedMorph: clickedMorph.

	(anEvent respondsTo: #wasHandled:) ifTrue: [ anEvent wasHandled: true ].
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
	(aWidget respondsTo: #on:send:to:) ifTrue: [
		aWidget on: #mouseDown send: #ddOnMouseDown: to: self ].
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> installClickHooks [ 
	presenterIndex widgetToPresenter keysDo: [ :w |
		self installClickHookOnWidget: w ].
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

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> rebuildPreview [

	rootPreviewPresenter := editedPresenter class new.
	previewPresenter
		removeAll;
		add: rootPreviewPresenter .
	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter.
	self installClickHooks
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> updateLayoutMethodFor: aClass with: source [
    (aClass compiler compile: source)
        ifNil: [ self inform: 'Compilation error' ]
        ifNotNil: [
            self rebuildPreview.
            self inform: 'Updated!' ].

]
