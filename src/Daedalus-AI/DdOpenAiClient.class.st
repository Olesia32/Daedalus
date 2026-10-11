Class {
	#name : 'DdOpenAiClient',
	#superclass : 'DdLlmClient',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdOpenAiClient >> answerTo: aConversation system: aSystemText [

	self checkReady.
	^ self textFromJson: (self
			   request: #post
			   url: baseUrl , '/chat/completions'
			   headers: self headers
			   body: (self requestBodyFor: aConversation system: aSystemText))
]

{ #category : 'private' }
DdOpenAiClient >> headers [

	| headers |
	headers := Dictionary new.
	(apiKey notNil and: [ apiKey notEmpty ]) ifTrue: [
		headers at: 'Authorization' put: 'Bearer ' , apiKey ].
	^ headers
]

{ #category : 'answering' }
DdOpenAiClient >> modelNames [

	| json |
	self checkKey.
	json := self
		        request: #get
		        url: baseUrl , '/models'
		        headers: self headers
		        body: nil.
	^ ((json at: 'data' ifAbsent: [ #(  ) ]) collect: [ :each | each at: 'id' ])
		  asSortedCollection asArray
]

{ #category : 'private' }
DdOpenAiClient >> requestBodyFor: aConversation system: aSystemText [

	| messages body |
	messages := OrderedCollection new.
	messages add: (Dictionary newFrom: {
				 ('role' -> 'system').
				 ('content' -> aSystemText) }).
	aConversation do: [ :each |
		messages add: (Dictionary newFrom: {
					 ('role' -> (self roleOf: each)).
					 ('content' -> each value) }) ].
	body := Dictionary newFrom: {
			        ('model' -> model).
			        ('messages' -> messages asArray) }.
	(provider notNil and: [ provider temperature notNil ]) ifTrue: [
		body at: 'temperature' put: provider temperature ].
	(provider notNil and: [ provider jsonMode ]) ifTrue: [
		body
			at: 'response_format'
			put: (Dictionary newFrom: { ('type' -> 'json_object') }) ].
	^ body
]

{ #category : 'private' }
DdOpenAiClient >> textFromJson: json [

	| choices |
	choices := json at: 'choices' ifAbsent: [ #(  ) ].
	choices isEmpty ifTrue: [ ^ DdAiError signal: self label , ' gave no answer' ].
	^ ((choices first at: 'message' ifAbsent: [ Dictionary new ])
		   at: 'content'
		   ifAbsent: [ nil ]) ifNil: [
		  DdAiError signal: 'The ' , self label , ' answer has no text' ]
]
