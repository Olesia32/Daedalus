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

	currentClass := aClass.
	codeEditor beForBehavior: aClass.
	self refreshCode
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
    saveButton := self newButton.
    saveButton
        label: 'Save';
        action: [ self saveCode ]
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> refreshCode [

	| source |
	currentClass ifNil: [ ^ self ].
	source := currentClass sourceCodeAt: #defaultLayout ifAbsent: [ '' ].
	codeEditor text: source
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> saveCode [

	| source |
	currentClass ifNil: [ ^ self ].
	source := codeEditor text.
	currentClass compile: source.
	designer ifNotNil: [ designer workArea refreshPreview  ]
]
