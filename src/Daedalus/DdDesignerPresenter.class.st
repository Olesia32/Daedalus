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

{ #category : 'adding' }
DdDesignerPresenter >> addWidget: aDescriptor [ 
    DdAddWidgetService new
        presenterClass: presenter;
        addWidget: aDescriptor.
    codeEditor refreshCode.
    workArea rebuildPreview.
]

{ #category : 'accessing' }
DdDesignerPresenter >> codeEditor [ 
^ codeEditor 
]

{ #category : 'layout' }
DdDesignerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 20;
				   add: widgetPalette width: 150;
				   add: workArea;
				   add: propertyPanel width: 200;
				   yourself);
		  add: codeEditor height: 150;
		  yourself.
		
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

	(selected respondsTo: #mainPresenter) ifTrue: [
			selectedSub := selected.
			selected := selected owner ].
	(selected isKindOf: RadioGroupPresenter) ifTrue: [
			selectedSub := selected.
			selected := selected owner ].
	(selected isKindOf: CheckboxGroupPresenter) ifTrue: [
			selectedSub := selected.
			selected := selected owner ].

	propertyPanel := DdPropertyPanelPresenter new.
	propertyPanel
		target: selected
		subPresenter: selectedSub
		onClass: selected class
		canvas: workArea.

	self rebuildLayout 
]

{ #category : 'as yet unclassified' }
DdDesignerPresenter >> onSelectionCleared [ 
    propertyPanel := DdPropertyPanelPresenter new.
    propertyPanel
        target: nil
        subPresenter: nil
        onClass: nil
        canvas: workArea.
    self rebuildLayout
]

{ #category : 'initialization' }
DdDesignerPresenter >> presenterClass: aClass [ 
    presenter := aClass.
    workArea := DdCanvasPresenter onPresenter: presenter new.
    workArea designer: self.
    codeEditor classToEdit: presenter.
    codeEditor designer: self.
    widgetPalette designer: self.   
    propertyPanel := DdPropertyPanelPresenter new.
    propertyPanel
        target: nil
        subPresenter: nil
        onClass: nil
        canvas: workArea.
    WorldMorph doOneCycle.
    workArea installClickHooks
]

{ #category : 'private' }
DdDesignerPresenter >> rebuildLayout [

	| newLayout |
	newLayout := SpBoxLayout newTopToBottom
		             spacing: 10;
		             add: (SpBoxLayout newLeftToRight
				              spacing: 20;
				              add: widgetPalette width: 150;
				              add: workArea;
				              add: propertyPanel width: 250;
				              yourself);
		             add: codeEditor height: 150;
		             yourself.
	self layout: newLayout.
	self needRebuild: true.
	self updatePresenter.
	UIManager default defer: [ workArea installClickHooks ]
]

{ #category : 'accessing' }
DdDesignerPresenter >> workArea [
  ^workArea 
]
