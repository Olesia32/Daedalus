"
I am the abstract base for all objects that describe a single property change to a presenter. I know which instance variable I
target via varName, but I leave it to subclasses to define how to apply the change to a live presenter and how to patch its source AST.

### Hierarchy
`Object`
`DdPresenterProperties` (this is me)

### Instance Variables
- _varName_: `String` — the instance variable name in the edited presenter that this property targets
"
Class {
	#name : 'DdPresenterProperties',
	#superclass : 'Object',
	#instVars : [
		'varName'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'translating' }
DdPresenterProperties >> patchSource: anAst [ 
    "Abstract. Subclasses insert or replace the relevant statement in anAst's body and return the patched AST."

    ^ self subclassResponsibility
]

{ #category : 'accessing' }
DdPresenterProperties >> varName [ 
^ varName 
]

{ #category : 'accessing' }
DdPresenterProperties >> varName: aString [ 
varName := aString 
]
