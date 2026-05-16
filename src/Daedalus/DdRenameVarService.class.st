Class {
	#name : 'DdRenameVarService',
	#superclass : 'Object',
	#instVars : [
		'presenterClass'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'as yet unclassified' }
DdRenameVarService >> renameIn: aClass from: anOldName to: aNewName [ 
    (aClass instVarNames includes: anOldName) ifFalse: [ ^ self ].
    (aClass instVarNames includes: aNewName) ifTrue: [ ^ self ].
    (RBRenameInstanceVariableRefactoring
        rename: anOldName
        to: aNewName
        in: aClass) execute.
]
