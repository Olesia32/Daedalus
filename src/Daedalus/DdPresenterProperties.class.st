Class {
	#name : 'DdPresenterProperties',
	#superclass : 'Object',
	#instVars : [
		'varName'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'translating' }
DdPresenterProperties >> patchSource: anAst [ 
    "Абстрактний — підкласи реалізують"
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
