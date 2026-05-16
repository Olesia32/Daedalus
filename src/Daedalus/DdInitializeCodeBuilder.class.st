"
I am responsible for generating or patching the source code of `initializePresenters`. Given a list of `DdPresenterProperties`
I either patch the existing method's AST or produce a fresh skeleton if the method does not yet exist.

### Hierarchy
`Object`
`DdInitializeCodeBuilder` (this is me)

### Instance Variables
- _presenterClass_: `Class` — the presenter class whose method is being patched
- _propertiesList_: `Collection` — the list of `DdPresenterProperties` to apply to the AST
"
Class {
	#name : 'DdInitializeCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'presenterClass',
		'propertiesList'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'translating' }
DdInitializeCodeBuilder >> generate [ 
"Fetches the existing initializePresenters source, parses it into an AST, applies each DdPresenterProperties via patchSource:, and
returns the formatted result. Falls back to generateFresh if the method does not exist."

    | method existingSource ast |
    method := presenterClass
        compiledMethodAt: #initializePresenters
        ifAbsent: [ nil ].
    existingSource := method ifNil: [ ^ self generateFresh ] ifNotNil: [ method sourceCode ].
    ast := RBParser parseMethod: existingSource.
    propertiesList do: [ :props | props patchSource: ast ].
    ^ ast formattedCode
]

{ #category : 'as yet unclassified' }
DdInitializeCodeBuilder >> generateFresh [ 
"Returns a minimal initializePresenters source string containing only the super call, used when the method does not yet exist."

    | stream |
    stream := WriteStream on: String new.
    stream nextPutAll: 'initializePresenters'; cr.
    stream tab; nextPutAll: 'super initializePresenters.'; cr.
    ^ stream contents
]

{ #category : 'as yet unclassified' }
DdInitializeCodeBuilder >> presenterClass: aClass properties: aCollection [ 
"Stores presenterClass and propertiesList for use during generation."

    presenterClass := aClass.
    propertiesList := aCollection.
]
