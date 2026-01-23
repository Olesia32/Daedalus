Class {
	#name : 'DdLayoutCodeEditorPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'codeEditor',
		'currentClass'
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
        yourself
]

{ #category : 'initialization' }
DdLayoutCodeEditorPresenter >> initializePresenters [
    super initializePresenters.

    codeEditor := self newCode.
    codeEditor
        withLineNumbers;
        withSyntaxHighlight;
        withSmartCharacters.
]

{ #category : 'as yet unclassified' }
DdLayoutCodeEditorPresenter >> refreshCode [

	| source |
	currentClass ifNil: [ ^ self ].
	source := currentClass sourceCodeAt: #defaultLayout ifAbsent: [ '' ].
	codeEditor text: source
]
