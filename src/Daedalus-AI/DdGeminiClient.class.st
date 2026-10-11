Class {
	#name : 'DdGeminiClient',
	#superclass : 'DdLlmClient',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdGeminiClient >> answerTo: aConversation system: aSystemText [

	self checkReady.
	^ self textFromJson: (self
			   request: #post
			   url: baseUrl , '/models/' , model , ':generateContent'
			   headers: self headers
			   body: (self requestBodyFor: aConversation system: aSystemText))
]

{ #category : 'private' }
DdGeminiClient >> errorMessageFrom: aString status: aCode [

	| message |
	message := [
	           ((STONJSON fromString: aString) at: 'error') at: 'message' ]
		           on: Error
		           do: [ aString ].
	^ 'Gemini error ' , aCode printString , ': ' , message
]

{ #category : 'private' }
DdGeminiClient >> headers [
	^ Dictionary newFrom: { ('x-goog-api-key' -> apiKey) }
]

{ #category : 'answering' }
DdGeminiClient >> modelNames [

	| json |
	self checkKey.
	json := self
		        request: #get
		        url: baseUrl , '/models?pageSize=1000'
		        headers: self headers
		        body: nil.
	^ (((json at: 'models' ifAbsent: [ #(  ) ]) select: [ :each |
		    (each at: 'supportedGenerationMethods' ifAbsent: [ #(  ) ]) includes:
			    'generateContent' ]) collect: [ :each |
		   (each at: 'name') copyReplaceAll: 'models/' with: '' ]) asSortedCollection
		  asArray
]

{ #category : 'private' }
DdGeminiClient >> requestBodyFor: aConversation system: aSystemText [
	"JSON mode; temperature 0 when the provider says so: as repeatable as the model allows."

	| config |
	config := Dictionary newFrom: { ('responseMimeType' -> 'application/json') }.
	(provider isNil or: [ provider temperature notNil ]) ifTrue: [
		config
			at: 'temperature'
			put: (provider ifNil: [ 0 ] ifNotNil: [ provider temperature ]) ].
	^ Dictionary newFrom: {
			  ('systemInstruction'
			   -> (Dictionary newFrom: { ('parts' -> { (Dictionary newFrom: { ('text' -> aSystemText) }) }) })).
			  ('contents' -> (aConversation collect: [ :each |
					    Dictionary newFrom: {
							    ('role' -> each key asString).
							    ('parts' -> { (Dictionary newFrom: { ('text' -> each value) }) }) } ]) asArray).
			  ('generationConfig' -> config) }
]

{ #category : 'private' }
DdGeminiClient >> textFromJson: json [

	| candidates parts |
	candidates := json at: 'candidates' ifAbsent: [ #(  ) ].
	candidates isEmpty ifTrue: [
		^ DdAiError signal: 'Gemini gave no answer'
			  , ((json at: 'promptFeedback' ifAbsent: [ nil ])
					   ifNil: [ '' ]
					   ifNotNil: [ :feedback | ' (' , feedback printString , ')' ]) ].
	parts := (candidates first at: 'content' ifAbsent: [ Dictionary new ])
		         at: 'parts'
		         ifAbsent: [ #(  ) ].
	^ (parts
		   detect: [ :each | each includesKey: 'text' ]
		   ifNone: [ ^ DdAiError signal: 'The Gemini answer has no text' ]) at: 'text'
]

{ #category : 'private' }
DdGeminiClient >> textFromReply: aString [

	^ self textFromJson: ([ STONJSON fromString: aString ]
			   on: Error
			   do: [ ^ DdAiError signal: 'Gemini answered something that is not JSON' ])
]
