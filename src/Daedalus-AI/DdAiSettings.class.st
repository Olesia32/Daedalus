Class {
	#name : 'DdAiSettings',
	#superclass : 'Object',
	#classVars : [
		'BaseUrls',
		'Keys',
		'Models',
		'ProviderId'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'current provider' }
DdAiSettings class >> apiKey [

	^ self keyFor: self provider
]

{ #category : 'current provider' }
DdAiSettings class >> apiKey: aString [

	self key: aString for: self provider
]

{ #category : 'per provider' }
DdAiSettings class >> baseUrl: aString for: aProvider [

	self baseUrls at: aProvider id put: aString
]

{ #category : 'per provider' }
DdAiSettings class >> baseUrlFor: aProvider [

	| url |
	url := self baseUrls at: aProvider id ifAbsent: [ '' ].
	^ url isEmpty
		  ifTrue: [ aProvider baseUrl ]
		  ifFalse: [ url ]
]

{ #category : 'per provider' }
DdAiSettings class >> baseUrls [
	^ BaseUrls ifNil: [ BaseUrls := Dictionary new ]
]

{ #category : 'state' }
DdAiSettings class >> forgetKeys [
	"Before giving the image to someone else."

	Keys := nil
]

{ #category : 'per provider' }
DdAiSettings class >> key: aString for: aProvider [
	self keys at: aProvider id put: aString
]

{ #category : 'per provider' }
DdAiSettings class >> keyFor: aProvider [
	"Typed in the settings, otherwise the provider's environment variable; nil when neither."

	| key |
	key := self storedKeyFor: aProvider.
	key isEmpty ifFalse: [ ^ key ].
	aProvider keyVariable ifNil: [ ^ nil ].
	^ OSEnvironment current at: aProvider keyVariable ifAbsent: [ nil ]
]

{ #category : 'per provider' }
DdAiSettings class >> keys [
	^ Keys ifNil: [ Keys := Dictionary new ]
]

{ #category : 'current provider' }
DdAiSettings class >> model [
	^ self modelFor: self provider
]

{ #category : 'current provider' }
DdAiSettings class >> model: aString [
	self model: aString for: self provider
]

{ #category : 'per provider' }
DdAiSettings class >> model: aString for: aProvider [
	self models at: aProvider id put: aString
]

{ #category : 'per provider' }
DdAiSettings class >> modelFor: aProvider [

	| model |
	model := self models at: aProvider id ifAbsent: [ '' ].
	^ model isEmpty
		  ifTrue: [ aProvider defaultModel ]
		  ifFalse: [ model ]
]

{ #category : 'per provider' }
DdAiSettings class >> models [
	^ Models ifNil: [ Models := Dictionary new ]
]

{ #category : 'clients' }
DdAiSettings class >> newClient [
	^ self newClientFor: self provider
]

{ #category : 'clients' }
DdAiSettings class >> newClientFor: aProvider [

	^ aProvider clientClass new
		  setProvider: aProvider
		  apiKey: (self keyFor: aProvider)
		  model: (self modelFor: aProvider)
		  baseUrl: (self baseUrlFor: aProvider);
		  yourself
]

{ #category : 'provider' }
DdAiSettings class >> provider [
	^ DdLlmProvider named: self providerId
]

{ #category : 'provider' }
DdAiSettings class >> providerId [
	^ ProviderId ifNil: [ #gemini ]
]

{ #category : 'provider' }
DdAiSettings class >> providerId: aSymbol [
	ProviderId := aSymbol asSymbol
]

{ #category : 'state' }
DdAiSettings class >> state [
	^ {
		  ProviderId.
		  Keys.
		  Models.
		  BaseUrls }
]

{ #category : 'state' }
DdAiSettings class >> state: anArray [

	ProviderId := anArray first.
	Keys := anArray second.
	Models := anArray third.
	BaseUrls := anArray fourth
]

{ #category : 'per provider' }
DdAiSettings class >> storedKeyFor: aProvider [
	"Only what was typed in the settings."

	^ self keys at: aProvider id ifAbsent: [ '' ]
]

{ #category : 'current provider' }
DdAiSettings class >> summary [
	"Gemini - gemini-3.5-flash-lite"

	| model |
	model := self model.
	^ self provider label , ' - ' , (model isEmpty
		   ifTrue: [ 'no model chosen' ]
		   ifFalse: [ model ])
]
