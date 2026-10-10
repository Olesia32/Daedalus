Class {
	#name : 'DdAiSettings',
	#superclass : 'Object',
	#classVars : [
		'ApiKey',
		'Model'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'accessing' }
DdAiSettings class >> apiKey [
"Set in this image, otherwise the GEMINI_API_KEY environment variable; nil when neither."

	(ApiKey notNil and: [ ApiKey notEmpty ]) ifTrue: [ ^ ApiKey ].
	^ OSEnvironment current at: 'GEMINI_API_KEY' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
DdAiSettings class >> apiKey: aString [

	ApiKey := aString
]

{ #category : 'accessing' }
DdAiSettings class >> defaultModel [
"Google's suggestion for new projects (October 2026); any model of the free tier will do."

	^ 'gemini-3.5-flash-lite'
]

{ #category : 'accessing' }
DdAiSettings class >> model [

	^ (Model notNil and: [ Model notEmpty ])
		  ifTrue: [ Model ]
		  ifFalse: [ self defaultModel ]
]

{ #category : 'accessing' }
DdAiSettings class >> model: aString [

	Model := aString
]
