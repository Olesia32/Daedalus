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
		'designer'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> classToEdit: aClass [
"Sets currentClass, configures the editor's behavior context, and loads the current defaultLayout source."
    currentClass := aClass.
    self refreshCode.
    codeEditor beForBehavior: aClass.
]

{ #category : 'layout' }
DdLayoutCodeEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: codeEditor;
		  add: saveButton expand: false;
		  yourself
]

{ #category : 'accessing' }
DdLayoutCodeEditorPresenter >> designer: aDesigner [ 
    designer := aDesigner
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

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> refreshCode [
"Reads defaultLayout source from currentClass and sets it as the editor's text content."

    | source |
    currentClass ifNil: [ ^ self ].
    source := currentClass sourceCodeAt: #defaultLayout ifAbsent: [ '' ].
    codeEditor text: source.
    codeEditor beForBehavior: currentClass.
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
