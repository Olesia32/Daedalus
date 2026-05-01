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
		'designer'
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
DdCanvasPresenter >> announceSelectionChanged [

	self triggerEvent: #selectionChanged
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> clickedMorphFromEvent: arg1 [

	(arg1 respondsTo: #target) ifTrue: [
			| tmp2 |
			tmp2 := arg1 target.
			tmp2 ifNotNil: [ ^ arg1 target ] ].
	(arg1 respondsTo: #source) ifTrue: [
			| tmp4 |
			tmp4 := arg1 source.
			tmp4 ifNotNil: [ ^ arg1 source ] ].
	(arg1 respondsTo: #receiver) ifTrue: [
			| tmp6 |
			tmp6 := arg1 receiver.
			tmp6 ifNotNil: [ ^ arg1 receiver ] ].
	^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> ddOnMouseDown: anEvent [

    | clickedMorph presenter |
    Transcript show: 'CLICK'; cr.

    clickedMorph := self clickedMorphFromEvent: anEvent.
    clickedMorph ifNil: [ ^ self ].

    presenter := self presenterFromClickedMorph: clickedMorph.

    presenter ifNil: [
        Transcript show: 'NO PRESENTER'; cr.
        ^ self
    ].

    Transcript show: 'FOUND: ', presenter class name; cr.

    selectedPresenter := presenter.

    designer ifNotNil: [
        designer onSelectionChanged
    ].

    (anEvent respondsTo: #wasHandled:) ifTrue: [
        anEvent wasHandled: true ]
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> ddOnMouseUp: arg1 [

	self ddOnMouseDown: arg1
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
DdCanvasPresenter >> designer: aDesigner [
    designer := aDesigner
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

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> installClickHookOnWidget: arg1 [

	arg1 on: #mouseDown send: #ddOnMouseDown: to: self.
	arg1 submorphs do: [ :arg2 | self installClickHookOnWidget: arg2 ]
]

{ #category : 'initialization' }
DdCanvasPresenter >> installClickHooks [

	| tmp1 tmp3 |
	tmp1 := rootPreviewPresenter adapter widget.
	tmp3 := 0.
	tmp1
		ifNil: [
				Transcript
					show: 'NO ROOT WIDGET';
					cr.
				^ self ]
		ifNotNil: [ tmp1 ].
	tmp1 allMorphsDo: [ :arg1 |
			(arg1 respondsTo: #on:send:to:) ifTrue: [
					arg1 on: #mouseDown send: #ddOnMouseDown: to: self.
					tmp3 := tmp3 + 1 ] ].
	Transcript
		show: 'Hooks installed: ' , tmp3 printString;
		cr
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

{ #category : 'accessing' }
DdCanvasPresenter >> presenterFromClickedMorph: aMorph [

    | m |
    m := aMorph.

    [ m notNil ] whileTrue: [

        (m respondsTo: #valueOfProperty:) ifTrue: [
            (m valueOfProperty: #ddPresenter ifAbsent: [ nil ]) ifNotNil: [ :p |
                ^ p
            ]
        ].

        m := m owner
    ].

    ^ nil
]

{ #category : 'accessing' }
DdCanvasPresenter >> presenterIndex [

	^ presenterIndex
]

{ #category : 'initialization' }
DdCanvasPresenter >> rebuildPreview [

	rootPreviewPresenter := editedPresenter class new.
	previewPresenter
		removeAll;
		add: rootPreviewPresenter.
	rootPreviewPresenter build.
	presenterIndex := DdPresenterIndex new buildFromRootPresenter:
		                  rootPreviewPresenter
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
