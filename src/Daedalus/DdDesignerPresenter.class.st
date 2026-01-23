Class {
	#name : 'DdDesignerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'presenter',
		'widgetPalette',
		'workArea',
		'propertyPanel',
		'codeEditor',
		'footerBar'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdDesignerPresenter class >> onPresenter: aPresenterClass [
    
   ^ self new
     presenterClass: aPresenterClass;
     yourself 
]

{ #category : 'layout' }
DdDesignerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
	     spacing: 10;
		  add: (SpBoxLayout newLeftToRight
		         spacing: 20;
				   add: widgetPalette;
				   add: workArea;
				   yourself);
		  add: codeEditor;
		  yourself
]

{ #category : 'initialization' }
DdDesignerPresenter >> initializePresenters [

	| tmp1 |
	widgetPalette := DdWidgetPalettePresenter new.
	codeEditor := DdLayoutCodeEditorPresenter new.
	tmp1 := self focusOrder.
	tmp1
		add: widgetPalette;
		add: workArea
]

{ #category : 'as yet unclassified' }
DdDesignerPresenter >> presenterClass: aClass [

	presenter := aClass.
	workArea := DdCanvasPresenter onPresenter: presenter new.
	codeEditor classToEdit: presenter.
]
