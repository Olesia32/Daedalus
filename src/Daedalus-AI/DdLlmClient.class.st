Class {
	#name : 'DdLlmClient',
	#superclass : 'Object',
	#instVars : [
		'provider',
		'apiKey',
		'model',
		'baseUrl'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdLlmClient >> answerTo: aConversation system: aSystemText [
	"aConversation: role -> text associations, oldest first (#user / #model).
	Answers the text of the model's reply, or signals DdAiError with a message for the user."

	^ self subclassResponsibility
]

{ #category : 'checking' }
DdLlmClient >> checkKey [

	(provider notNil and: [
		 provider keyRequired and: [ apiKey isNil or: [ apiKey isEmpty ] ] ]) ifTrue: [
		DdAiError signal: 'No API key for ' , self label , ': enter it in the AI settings'
			, (provider keyVariable
					 ifNil: [ '' ]
					 ifNotNil: [ :variable | ' or set ' , variable ]) ]
]

{ #category : 'checking' }
DdLlmClient >> checkReady [

	self checkKey.
	(model isNil or: [ model isEmpty ]) ifTrue: [
		DdAiError signal: 'Choose a model for ' , self label , ' in the AI settings' ]
]

{ #category : 'private' }
DdLlmClient >> errorMessageFrom: aString status: aCode [

	| message |
	message := [
	           | error |
	           error := (STONJSON fromString: aString) at: 'error'.
	           error isDictionary
		           ifTrue: [ error at: 'message' ]
		           ifFalse: [ error asString ] ]
		           on: Error
		           do: [ aString ].
	^ self label , ' error ' , aCode printString , ': ' , message
]

{ #category : 'private' }
DdLlmClient >> label [
	^ provider
		  ifNil: [ self class name ]
		  ifNotNil: [ provider label ]
]

{ #category : 'answering' }
DdLlmClient >> modelNames [
	"The models the provider offers, for the settings."

	^ self subclassResponsibility
]

{ #category : 'private' }
DdLlmClient >> request: aMethod url: aUrl headers: aDictionary body: aBodyOrNil [
	"The answer, read from JSON - or DdAiError with the provider's own message."

	| client contents |
	client := ZnClient new
		          url: aUrl;
		          timeout: 90;
		          yourself.
	aDictionary keysAndValuesDo: [ :key :value | client headerAt: key put: value ].
	aBodyOrNil ifNotNil: [
		client entity: (ZnEntity
				 with: (STONJSON toString: aBodyOrNil)
				 type: ZnMimeType applicationJson) ].
	[
	[
	aMethod = #post
		ifTrue: [ client post ]
		ifFalse: [ client get ] ]
		on: Error
		do: [ :error |
			^ DdAiError signal: self label , ' could not be reached: ' , error description ].
	contents := client response contents.
	contents isString ifFalse: [
		contents := contents
			            ifNil: [ '' ]
			            ifNotNil: [ contents utf8Decoded ] ].
	client response isSuccess ifFalse: [
		^ DdAiError signal:
			  (self errorMessageFrom: contents status: client response code) ] ]
		ensure: [ client close ].
	^ [ STONJSON fromString: contents ]
		  on: Error
		  do: [ DdAiError signal: self label , ' answered something that is not JSON' ]
]

{ #category : 'private' }
DdLlmClient >> roleOf: anAssociation [
	"#user / #model of the conversation, as most APIs name them."

	^ anAssociation key = #model
		  ifTrue: [ 'assistant' ]
		  ifFalse: [ 'user' ]
]

{ #category : 'initialization' }
DdLlmClient >> setProvider: aProvider apiKey: aKey model: aModel baseUrl: aUrl [

	provider := aProvider.
	apiKey := aKey.
	model := aModel.
	baseUrl := aUrl
]
