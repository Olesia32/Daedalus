Class {
	#name : 'DdGeminiClient',
	#superclass : 'DdLlmClient',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdGeminiClient >> answerTo: aConversation system: aSystemText [

	| key client contents |
	key := DdAiSettings apiKey.
	key ifNil: [
			^ DdAiError signal:
				  'No Gemini API key: set it with DdAiSettings apiKey: or the GEMINI_API_KEY environment variable' ].
	client := ZnClient new
		          url: self endpoint;
		          headerAt: 'x-goog-api-key' put: key;
		          entity: (ZnEntity
				           with: (STONJSON toString:
							            (self
								             requestBodyFor: aConversation
								             system: aSystemText))
				           type: ZnMimeType applicationJson);
		          timeout: 90;
		          yourself.
	[
		[ client post ]
			on: Error
			do: [ :error |
					^ DdAiError signal:
						  'Gemini could not be reached: ' , error description ].
		contents := client response contents.
		contents isString ifFalse: [ contents := contents utf8Decoded ].
		client response isSuccess ifFalse: [
				^ DdAiError signal:
					  (self errorMessageFrom: contents status: client response code) ] ]
		ensure: [ client close ].
	^ self textFromReply: contents
]

{ #category : 'private' }
DdGeminiClient >> endpoint [

	^ 'https://generativelanguage.googleapis.com/v1beta/models/'
	  , DdAiSettings model , ':generateContent'
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
DdGeminiClient >> requestBodyFor: aConversation system: aSystemText [
"JSON mode and temperature 0: as repeatable as the model allows."

	^ Dictionary newFrom: {
			  ('systemInstruction' -> (Dictionary newFrom:
				    { ('parts'
				     -> { (Dictionary newFrom: { ('text' -> aSystemText) }) }) })).
			  ('contents' -> (aConversation collect: [ :each |
					    Dictionary newFrom: {
							    ('role' -> each key asString).
							    ('parts'
							     -> { (Dictionary newFrom: { ('text' -> each value) }) }) } ])
				   asArray).
			  ('generationConfig' -> (Dictionary newFrom: {
					    ('responseMimeType' -> 'application/json').
					    ('temperature' -> 0) })) }
]

{ #category : 'private' }
DdGeminiClient >> textFromReply: aString [

	| json candidates parts |
	json := [ STONJSON fromString: aString ]
		        on: Error
		        do: [
		        ^ DdAiError signal:
			          'Gemini answered something that is not JSON' ].
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
		   ifNone: [ ^ DdAiError signal: 'The Gemini answer has no text' ])
		  at: 'text'
]
