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
            add: propertyPanel;  
            yourself);
        add: codeEditor;
        yourself
]

{ #category : 'initialization' }
DdDesignerPresenter >> initializePresenters [

    widgetPalette := DdWidgetPalettePresenter new.
    codeEditor := DdLayoutCodeEditorPresenter new.
]

{ #category : 'initialization' }
DdDesignerPresenter >> onSelectionChanged [

    | selected |
    Transcript show: 'UI UPDATE'; cr.

    selected := workArea selectedPresenter.
    selected ifNil: [ ^ self ].

    propertyPanel := DdPropertyPanelPresenter new.

    propertyPanel
        target: selected
        onClass: selected class
        canvas: workArea.

    self rebuildLayout
]

{ #category : 'initialization' }
DdDesignerPresenter >> presenterClass: aClass [

    presenter := aClass.
    workArea := DdCanvasPresenter onPresenter: presenter new.

    workArea designer: self.

    codeEditor classToEdit: presenter.

    propertyPanel := DdPropertyPanelPresenter new.

    propertyPanel
        target: nil
        onClass: nil
        canvas: workArea.
]

{ #category : 'initialization' }
DdDesignerPresenter >> rebuildLayout [

    self layout: self defaultLayout.
    self needRebuild: true.
    self updatePresenter
]
