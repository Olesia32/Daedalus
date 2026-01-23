Class {
	#name : 'DdCanvasPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'editedPresenter',
		'previewPresenter'
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
DdCanvasPresenter >> rebuildPreview [

	| newPresenter |
	newPresenter := editedPresenter class new.
	previewPresenter
		removeAll;
		add: newPresenter
]

{ #category : 'as yet unclassified' }
DdCanvasPresenter >> updateLayoutMethodFor: aClass with: source [
    (aClass compiler compile: source)
        ifNil: [ self inform: 'Compilation error' ]
        ifNotNil: [
            self rebuildPreview.
            self inform: 'Updated!' ].

]
