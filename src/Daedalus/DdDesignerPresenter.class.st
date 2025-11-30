Class {
	#name : 'DdDesignerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'widgetPalette',
		'canvas',
		'propertyPanel',
		'codeEditor',
		'footerBar'
	],
	#category : 'Daedalus',
	#package : 'Daedalus'
}

{ #category : 'layout' }
DdDesignerPresenter >> defaultLayout [
    ^ SpBoxLayout newVertical
        add: (SpBoxLayout newHorizontal
            add: widgetPalette width: 200;
            add: canvas expand: true;
            add: propertyPanel width: 260;
            yourself);
        add: (SpBoxLayout newHorizontal
            add: codeEditor expand: true;
            add: footerBar height: 28;
            yourself);
        yourself.
]

{ #category : 'initialization' }
DdDesignerPresenter >> initializePresenters [
    widgetPalette := DdWidgetPalettePresenter new.
    canvas := DdCanvasPresenter new.
    propertyPanel := DdPropertyPanelPresenter new.
    codeEditor := DdCodeEditorPresenter new.
    footerBar := DdFooterBarPresenter new.

    self focusOrder add: widgetPalette; add: canvas; add: propertyPanel.
]

{ #category : 'accessing' }
DdDesignerPresenter >> model: aPresenterDefinition [
    super model: aPresenterDefinition.
    canvas model: aPresenterDefinition.
    propertyPanel model: aPresenterDefinition.
    codeEditor text: aPresenterDefinition defaultLayout.
]
