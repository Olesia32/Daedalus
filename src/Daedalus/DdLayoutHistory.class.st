Class {
	#name : 'DdLayoutHistory',
	#superclass : 'Object',
	#instVars : [
		'targetClass',
		'undoStack',
		'redoStack',
		'lastSnapshot'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'instance creation' }
DdLayoutHistory class >> forClass: aClass [
"Undo/redo for the edits the designer makes to aClass. Starts with the class as it is now."

	^ self new setClass: aClass
]

{ #category : 'constants' }
DdLayoutHistory class >> maxDepth [
"How many steps back undo can go; older steps are forgotten."

	^ 50
]

{ #category : 'constants' }
DdLayoutHistory class >> trackedSelectors [

	^ #( #defaultLayout #initializePresenters )
]

{ #category : 'testing' }
DdLayoutHistory >> canRedo [

	^ redoStack notEmpty
]

{ #category : 'testing' }
DdLayoutHistory >> canUndo [
	^ undoStack notEmpty
]

{ #category : 'recording' }
DdLayoutHistory >> checkpoint [

	| current |
	current := self currentSnapshot.
	current = lastSnapshot ifTrue: [ ^ false ].
	undoStack addLast: lastSnapshot.
	undoStack size > self class maxDepth ifTrue: [ undoStack removeFirst ].
	redoStack removeAll.
	lastSnapshot := current.
	^ true
]

{ #category : 'private' }
DdLayoutHistory >> currentSnapshot [
	"Selector -> source of each tracked method, nil for one the class does not have."

	| snapshot |
	snapshot := Dictionary new.
	self class trackedSelectors do: [ :selector |
			snapshot
				at: selector
				put: ((targetClass includesSelector: selector) ifTrue: [
						 (targetClass >> selector) sourceCode ]) ].
	^ snapshot
]

{ #category : 'actions' }
DdLayoutHistory >> redo [
"Answers false when there is nothing to redo (also after a new edit, which clears redo)."

	self checkpoint.
	self canRedo ifFalse: [ ^ false ].
	undoStack addLast: lastSnapshot.
	self restore: redoStack removeLast.
	^ true
]

{ #category : 'accessing' }
DdLayoutHistory >> redoSize [

	^ redoStack size
]

{ #category : 'private' }
DdLayoutHistory >> restore: aSnapshot [
"Recompiles only the methods that differ, so an untouched method keeps its timestamp."

	aSnapshot keysAndValuesDo: [ :selector :source |
			source
				ifNil: [
						(targetClass includesSelector: selector) ifTrue: [
							targetClass removeSelector: selector ] ]
				ifNotNil: [
						((targetClass includesSelector: selector) and: [
							 (targetClass >> selector) sourceCode = source ]) ifFalse: [
							targetClass compile: source ] ] ].
	lastSnapshot := self currentSnapshot
]

{ #category : 'initialization' }
DdLayoutHistory >> setClass: aClass [

	targetClass := aClass.
	undoStack := OrderedCollection new.
	redoStack := OrderedCollection new.
	lastSnapshot := self currentSnapshot
]

{ #category : 'accessing' }
DdLayoutHistory >> targetClass [

	^ targetClass
]

{ #category : 'actions' }
DdLayoutHistory >> undo [
"Answers false when there is nothing to undo. An edit made since the last checkpoint is
recorded first, so undo takes back exactly that edit instead of silently dropping it."

	self checkpoint.
	self canUndo ifFalse: [ ^ false ].
	redoStack addLast: lastSnapshot.
	self restore: undoStack removeLast.
	^ true
]

{ #category : 'accessing' }
DdLayoutHistory >> undoSize [

	^ undoStack size
]
