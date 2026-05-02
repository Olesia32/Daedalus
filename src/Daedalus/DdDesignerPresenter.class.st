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

	| selected selectedSub |

	selected := workArea selectedPresenter.
	selectedSub := workArea selectedSubPresenter.

	selected ifNil: [ ^ self ].

	propertyPanel := DdPropertyPanelPresenter new.

	propertyPanel
		target: selected
		subPresenter: selectedSub
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
		subPresenter: nil
		onClass: nil
		canvas: workArea.
		
	WorldMorph doOneCycle.
	workArea installClickHooks
]

{ #category : 'initialization' }
DdDesignerPresenter >> rebuildLayout [ 

    | newLayout |

    newLayout := SpBoxLayout newTopToBottom
        spacing: 10;
        add: (SpBoxLayout newLeftToRight
            spacing: 20;
            add: widgetPalette;
            add: workArea;
            add: propertyPanel;
            yourself);
        add: codeEditor;
        yourself.

    self layout: newLayout.
    self needRebuild: true.
    self updatePresenter.

    WorldMorph doOneCycle.
    workArea installClickHooks.
]
