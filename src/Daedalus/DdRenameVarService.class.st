"
I am a thin wrapper around RBRenameInstanceVariableRefactoring. I rename a single instance variable in a presenter class, guarding
against the cases where the old name does not exist or the new name is already taken.

### Hierarchy
`Object`
`DdRenameVarService` (this is me)
"
Class {
	#name : 'DdRenameVarService',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'as yet unclassified' }
DdRenameVarService >> renameIn: aClass from: anOldName to: aNewName [ 
"Renames anOldName to aNewName in aClass via RBRenameInstanceVariableRefactoring, skipping silently if the old
name is absent or the new name already exists."

    (aClass instVarNames includes: anOldName) ifFalse: [ ^ self ].
    (aClass instVarNames includes: aNewName) ifTrue: [ ^ self ].
    (RBRenameInstanceVariableRefactoring
        rename: anOldName
        to: aNewName
        in: aClass) execute.
]
