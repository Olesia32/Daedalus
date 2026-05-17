"
I am the main designer window. I coordinate the widget palette, the canvas, the property panel, and the code editor. I react to
selection changes on the canvas and route widget-add requests from the palette to the appropriate service.

### Hierarchy
`SpPresenter`
`DdDesignerPresenter` (this is me)

### Instance Variables
- _presenter_: `Class` — the presenter class being designed
- _widgetPalette_: `DdWidgetPalettePresenter`
- _workArea_: `DdCanvasPresenter`
- _propertyPanel_: `DdPropertyPanelPresenter`
- _codeEditor_: `DdLayoutCodeEditorPresenter`
"
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
"Delegates to DdAddWidgetService, then refreshes the code editor and rebuilds the canvas preview."
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
	workArea      := SpPresenter new.
    propertyPanel := SpPresenter new.
]

{ #category : 'accessing' }
DdDesignerPresenter >> onSelectionChanged [
"Resolves the selected presenter, wraps group presenters in their owner, builds a fresh DdPropertyPanelPresenter for the selection,
and rebuilds the layout."

    | selected selectedSub varName |
    selected := workArea selectedPresenter.
    selectedSub := workArea selectedSubPresenter.
    selected ifNil: [ ^ self ].

    selected == selectedSub ifFalse: [
    (selected respondsTo: #mainPresenter) ifTrue: [
        selectedSub := selected.
        selected := selected owner ].
    (selected isKindOf: RadioGroupPresenter) ifTrue: [
        selectedSub := selected.
        selected := selected owner ].
    (selected isKindOf: CheckboxGroupPresenter) ifTrue: [
        selectedSub := selected.
        selected := selected owner ] ].
    (selected isKindOf: ComboBoxPresenter ) ifTrue: [
        selectedSub := selected.
        selected := selected owner].

    propertyPanel := DdPropertyPanelPresenter new.
    propertyPanel
        target: selected
        subPresenter: selectedSub
        onClass: selected class
        canvas: workArea.

    varName := workArea instVarNameForPresenterInRoot: selectedSub.

    self rebuildLayout.
    UIManager default defer: [ codeEditor highlightVarName: varName ]
]

{ #category : 'as yet unclassified' }
DdDesignerPresenter >> onSelectionCleared [ 
"Resets the property panel to an empty state and rebuilds the layout."

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
"Initialises all sub-presenters, wires the canvas and code editor to this designer, and installs click hooks on the work area."
    
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
    
    workArea installClickHooks
]

{ #category : 'private' }
DdDesignerPresenter >> rebuildLayout [
"Rebuilds the top-level SpBoxLayout combining palette, canvas, property panel and code editor, then defers click hook reinstall."

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
