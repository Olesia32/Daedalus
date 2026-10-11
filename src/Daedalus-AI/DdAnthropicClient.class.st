Class {
	#name : 'DdAnthropicClient',
	#superclass : 'DdLlmClient',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdAnthropicClient >> answerTo: aConversation system: aSystemText [

	self checkReady.
	^ self textFromJson: (self
			   request: #post
			   url: baseUrl , '/messages'
			   headers: self headers
			   body: (self requestBodyFor: aConversation system: aSystemText))
]

{ #category : 'private' }
DdAnthropicClient >> headers [

	^ Dictionary newFrom: {
			  ('x-api-key' -> (apiKey ifNil: [ '' ])).
			  ('anthropic-version' -> '2023-06-01') }
]

{ #category : 'answering' }
DdAnthropicClient >> modelNames [

	| json |
	self checkKey.
	json := self
		        request: #get
		        url: baseUrl , '/models?limit=100'
		        headers: self headers
		        body: nil.
	^ ((json at: 'data' ifAbsent: [ #(  ) ]) collect: [ :each | each at: 'id' ])
		  asSortedCollection asArray
]

{ #category : 'private' }
DdAnthropicClient >> requestBodyFor: aConversation system: aSystemText [

	| body |
	body := Dictionary newFrom: {
			        ('model' -> model).
			        ('max_tokens' -> 8192).
			        ('system' -> aSystemText).
			        ('messages' -> (aConversation collect: [ :each |
					          Dictionary newFrom: {
							          ('role' -> (self roleOf: each)).
							          ('content' -> each value) } ]) asArray) }.
	(provider notNil and: [ provider temperature notNil ]) ifTrue: [
		body at: 'temperature' put: provider temperature ].
	^ body
]

{ #category : 'private' }
DdAnthropicClient >> textFromJson: json [

	| parts |
	parts := (json at: 'content' ifAbsent: [ #(  ) ]) select: [ :each |
		         (each at: 'type' ifAbsent: [ nil ]) = 'text' ].
	parts isEmpty ifTrue: [
		^ DdAiError signal: 'The ' , self label , ' answer has no text' ].
	^ '' join: (parts collect: [ :each | each at: 'text' ])
]
