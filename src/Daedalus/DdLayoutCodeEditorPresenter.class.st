"
I am the code editor panel at the bottom of the designer. I display the source of `defaultLayout` for the edited class, allow the user
to edit it directly, and recompile it on save triggering a canvas refresh.

### Hierarchy
`SpPresenter`
`DdLayoutCodeEditorPresenter` (this is me)

### Instance Variables
- _codeEditor_: `SpCodePresenter` — the syntax-highlighted code editor
- _currentClass_: `Class` — the class whose defaultLayout is being edited
- _saveButton_: `SpButtonPresenter` — triggers saveCode
- _designer_: `DdDesignerPresenter` — notified after a successful save
"
Class {
	#name : 'DdLayoutCodeEditorPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'codeEditor',
		'currentClass',
		'saveButton',
		'designer',
		'editedSelector',
		'methodList',
		'methodToggles'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'methods' }
DdLayoutCodeEditorPresenter class >> editableSelectors [
	^ #( #defaultLayout #initializePresenters )
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> layoutRootIn: aString [
	"The layout model of the method in aString, parsed as it is written (not reformatted), so that
	its nodes point at positions in aString. nil when it cannot be read."
	| ast |
	ast := [ RBParser parseMethod: aString ] on: Error do: [ ^ nil ].
	^ [ DdLayoutParser new parseMethodNode: ast ] on: Error do: [ nil ]
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> rangeOf: aNode [
	"The part of the code that places aNode: its add-message from the first keyword to the end
	(add: emailInput height: 35, or add: (SpBoxLayout ... yourself) expand: false for a nested
	layout). For the root layout, its factory (SpBoxLayout newTopToBottom). nil when unknown."
	| message receiver argument |
	aNode ifNil: [ ^ nil ].
	message := aNode addMessage.
	message ifNotNil: [
		([ message keywordsPositions first ] on: Error do: [ nil ]) ifNotNil: [ :start |
			(start isInteger and: [ start > 0 ]) ifTrue: [
				([ message stop ] on: Error do: [ nil ]) ifNotNil: [ :stop | ^ start to: stop ] ] ].
		"A message the parser rewrote (first:/second: of a paned) has no position: its argument has."
		argument := message arguments ifEmpty: [ nil ] ifNotEmpty: [ :arguments | arguments first ].
		(argument notNil and: [ argument start notNil ]) ifTrue: [ ^ argument start to: argument stop ].
		^ nil ].
	aNode isContainerNode ifFalse: [ ^ nil ].
	receiver := aNode cascade receiver.
	(receiver notNil and: [ receiver start notNil ]) ifTrue: [ ^ receiver start to: receiver stop ].
	^ nil
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> rangeOfInitializationOf: aVarName in: aString [
	"In initializePresenters: from 'aVarName := ...' through the statements right after it that
	still talk to aVarName. Without an assignment, the statements that talk to it. nil when none."
	| ast statements name first last |
	ast := [ RBParser parseMethod: aString ] on: Error do: [ ^ nil ].
	statements := ast body statements.
	name := aVarName asString.
	first := statements findFirst: [ :each |
		each isAssignment and: [ each variable name asString = name ] ].
	first = 0
		ifTrue: [
			first := statements findFirst: [ :each | (self rootReceiverNameOf: each) = name ].
			first = 0 ifTrue: [ ^ nil ].
			last := statements findLast: [ :each | (self rootReceiverNameOf: each) = name ] ]
		ifFalse: [
			last := first.
			[ last < statements size and: [ (self rootReceiverNameOf: (statements at: last + 1)) = name ] ]
				whileTrue: [ last := last + 1 ] ].
	^ (statements at: first) start to: (statements at: last) stop
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> rangeOfNodeAt: aPath in: aString [
	| root |
	root := self layoutRootIn: aString.
	root ifNil: [ ^ nil ].
	^ self rangeOf: ([ root nodeAtPath: aPath ] on: Error do: [ nil ])
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> rangeOfWidgetNamed: aVarName in: aString [
	"By the exact variable name - emailLabel is not email."
	| root |
	root := self layoutRootIn: aString.
	root ifNil: [ ^ nil ].
	^ self rangeOf: (root findWidgetNamed: aVarName)
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter class >> rootReceiverNameOf: aNode [
	"The variable a statement talks to: emailInput in 'emailInput placeholder: 1; yourself' or in
	'emailInput text: (x y)'. nil for anything else."
	| current |
	current := aNode.
	current isCascade ifTrue: [ current := current receiver ].
	[ current isMessage ] whileTrue: [ current := current receiver ].
	^ current isVariable ifTrue: [ current name asString ] ifFalse: [ nil ]
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> classToEdit: aClass [
"Sets currentClass, configures the editor's behavior context, and loads the current defaultLayout source."
    currentClass := aClass.
    self refreshCode.
    codeEditor beForBehavior: aClass.
]

{ #category : 'accessing' }
DdLayoutCodeEditorPresenter >> currentText [
	^ codeEditor text
]

{ #category : 'layout' }
DdLayoutCodeEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
	     add: self methodList expand: false;
		  add: codeEditor;
		  add: saveButton expand: false;
		  yourself
]

{ #category : 'accessing' }
DdLayoutCodeEditorPresenter >> designer: aDesigner [ 
    designer := aDesigner
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> editedSelector [
	"The method shown in the editor: defaultLayout (the layout) or initializePresenters (the widgets
	and their properties)."
	^ editedSelector ifNil: [ #defaultLayout ]
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> hasUnsavedChanges [
	^ codeEditor text asString ~= self savedSource asString
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter >> highlightNodeAt: aPath [
	"Selects the code that places the node at aPath - only defaultLayout has layouts in it."
	aPath ifNil: [ ^ self ].
	self editedSelector = #defaultLayout ifFalse: [ ^ self ].
	(self class rangeOfNodeAt: aPath in: codeEditor text asString) ifNotNil: [ :range |
		codeEditor selectionInterval: range ]
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> highlightVarName: aVarName [
"Finds the line in the editor source that contains aVarName and sets the editor's selection interval to that line."
    
	| source lines offset length lineIndex |
	aVarName ifNil: [ ^ self ].
	source := codeEditor text.
	lines := source lines.
	lineIndex := lines
		             detectIndex: [ :line |
		             line includesSubstring: aVarName ]
		             ifNone: [ ^ self ].
	"Рахуємо offset до цього рядка"
	offset := (lines first: lineIndex - 1)
		          inject: 0
		          into: [ :sum :l | sum + l size + 1 ]. "  +1 для \n"
	length := (lines at: lineIndex) size.
	codeEditor selectionInterval: (offset + 1 to: offset + length)
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter >> highlightWidgetNamed: aVarName [
	"In defaultLayout: the add-message of the widget. In initializePresenters: where it is created
	and set up. When the code cannot be read, the line search of highlightVarName:."
	| text range |
	aVarName ifNil: [ ^ self ].
	text := codeEditor text asString.
	range := self editedSelector = #initializePresenters
		ifTrue: [ self class rangeOfInitializationOf: aVarName in: text ]
		ifFalse: [ self class rangeOfWidgetNamed: aVarName in: text ].
	range
		ifNil: [ self highlightVarName: aVarName ]
		ifNotNil: [ codeEditor selectionInterval: range ]
]

{ #category : 'initialization' }
DdLayoutCodeEditorPresenter >> initializePresenters [

	super initializePresenters.
	codeEditor := self newCode.
	codeEditor
		withLineNumbers;
		withSyntaxHighlight;
		withSmartCharacters.
	codeEditor whenBuiltDo: [
        codeEditor withSyntaxHighlight.
        currentClass ifNotNil: [ codeEditor beForBehavior: currentClass ] ].
	saveButton := self newButton.
	saveButton
		label: 'Save';
		action: [ self saveCode ]
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> methodList [
	"Two toggle buttons side by side, like tabs, instead of a drop list: the one of the method shown
	is pressed. (The name stays methodList: defaultLayout already adds it under that name.)"
	| row |
	methodList ifNotNil: [ ^ methodList ].
	methodToggles := self class editableSelectors collect: [ :selector |
		self newToggleButton
			label: selector asString;
			yourself ].
	methodToggles first associatedToggleButtons: methodToggles allButFirst.
	methodToggles with: self class editableSelectors do: [ :toggle :selector |
		toggle whenChangedDo: [ :pressed | self methodToggle: selector pressed: pressed ] ].
	self syncMethodToggles.
	row := SpBoxLayout newLeftToRight
		spacing: 2;
		yourself.
	methodToggles do: [ :toggle | row add: toggle width: 170 ].
	methodList := SpPresenter new.
	methodList layout: row.
	^ methodList
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> methodToggle: aSelector pressed: aBoolean [
	"Pressing the other method switches to it. Whatever happened - a refused switch, or the pressed
	button clicked again and released - the buttons are put back to show the method in the editor."
	(aBoolean and: [ aSelector ~= self editedSelector ]) ifTrue: [ self switchTo: aSelector ].
	UIManager default defer: [ self syncMethodToggles ]
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> refreshCode [
	"Reads defaultLayout source from currentClass and sets it as the editor's text content."

	| source |
	currentClass ifNil: [ ^ self ].
	   source := currentClass sourceCodeAt: self editedSelector ifAbsent: [ '' ].
	codeEditor text: source.
	codeEditor beForBehavior: currentClass
]

{ #category : 'highlighting' }
DdLayoutCodeEditorPresenter >> rehighlightSelection [
	"Clears the selection left over from the other method (setting a new text kept it, so the whole
	text was selected) and highlights what is selected in the designer, if anything."
	| canvas varName |
	codeEditor selectionInterval: (1 to: 0).
	designer ifNil: [ ^ self ].
	canvas := [ designer workArea ] on: Error do: [ nil ].
	canvas ifNil: [ ^ self ].
	canvas selectedContainerPath ifNotNil: [ :path | ^ self highlightNodeAt: path ].
	canvas selectedPresenter ifNil: [ ^ self ].
	varName := canvas instVarNameForPresenterInRoot: canvas selectedPresenter.
	varName ifNotNil: [ self highlightWidgetNamed: varName ]
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> saveCode [
"Compiles the editor's current text onto currentClass and triggers a canvas preview refresh via the designer."

	| source |
	currentClass ifNil: [ ^ self ].
	source := codeEditor text.
	currentClass compile: source.
	designer ifNotNil: [ designer workArea refreshPreview  ]
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> savedSource [
	currentClass ifNil: [ ^ '' ].
	^ currentClass sourceCodeAt: self editedSelector ifAbsent: [ '' ]
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> switchTo: aSelector [
	"Shows aSelector in the editor. Unsaved edits of the method being left are only dropped when the
	user agrees. The new text starts with nothing selected - or with the current selection of the
	designer highlighted in it."
	aSelector = self editedSelector ifTrue: [ ^ self ].
	(self hasUnsavedChanges and: [
		(UIManager default confirm: self editedSelector asString
			, ' has unsaved changes. Switch and drop them?') not ]) ifTrue: [
		^ self syncMethodToggles ].
	editedSelector := aSelector.
	self refreshCode.
	self syncMethodToggles.
	self rehighlightSelection
]

{ #category : 'methods' }
DdLayoutCodeEditorPresenter >> syncMethodToggles [
	methodToggles ifNil: [ ^ self ].
	methodToggles with: self class editableSelectors do: [ :toggle :selector |
		toggle state: selector = self editedSelector ]
]
