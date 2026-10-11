Class {
	#name : 'DdLlmProvider',
	#superclass : 'Object',
	#instVars : [
		'id',
		'label',
		'clientClassName',
		'baseUrl',
		'defaultModel',
		'keyVariable',
		'keyRequired',
		'jsonMode',
		'temperature'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'accessing' }
DdLlmProvider class >> all [
	"The providers the settings offer. Ollama and any OpenAI-compatible server run without a key.
	A model left empty is chosen by the user (List models shows what the provider has).
	temperature nil: not sent - some models accept only their own default."

	^ {
		  (self
			   id: #gemini
			   label: 'Google Gemini'
			   client: #DdGeminiClient
			   baseUrl: 'https://generativelanguage.googleapis.com/v1beta'
			   model: 'gemini-3.5-flash-lite'
			   key: 'GEMINI_API_KEY'
			   required: true
			   json: true
			   temperature: 0).
		  (self
			   id: #openai
			   label: 'OpenAI'
			   client: #DdOpenAiClient
			   baseUrl: 'https://api.openai.com/v1'
			   model: ''
			   key: 'OPENAI_API_KEY'
			   required: true
			   json: true
			   temperature: nil).
		  (self
			   id: #groq
			   label: 'Groq'
			   client: #DdOpenAiClient
			   baseUrl: 'https://api.groq.com/openai/v1'
			   model: ''
			   key: 'GROQ_API_KEY'
			   required: true
			   json: true
			   temperature: 0).
		  (self
			   id: #openrouter
			   label: 'OpenRouter'
			   client: #DdOpenAiClient
			   baseUrl: 'https://openrouter.ai/api/v1'
			   model: ''
			   key: 'OPENROUTER_API_KEY'
			   required: true
			   json: false
			   temperature: nil).
		  (self
			   id: #anthropic
			   label: 'Anthropic Claude'
			   client: #DdAnthropicClient
			   baseUrl: 'https://api.anthropic.com/v1'
			   model: 'claude-haiku-5-5'
			   key: 'ANTHROPIC_API_KEY'
			   required: true
			   json: false
			   temperature: nil).
		  (self
			   id: #ollama
			   label: 'Ollama (local, no key)'
			   client: #DdOpenAiClient
			   baseUrl: 'http://localhost:11434/v1'
			   model: ''
			   key: nil
			   required: false
			   json: true
			   temperature: 0).
		  (self
			   id: #custom
			   label: 'Other OpenAI-compatible'
			   client: #DdOpenAiClient
			   baseUrl: 'http://localhost:1234/v1'
			   model: ''
			   key: nil
			   required: false
			   json: false
			   temperature: nil) }
]

{ #category : 'instance creation' }
DdLlmProvider class >> id: anId label: aLabel client: aClientClassName baseUrl: aUrl model: aModel key: aVariableOrNil required: aBoolean json: aJsonMode temperature: aTemperatureOrNil [

	^ self new
		  setId: anId
		  label: aLabel
		  client: aClientClassName
		  baseUrl: aUrl
		  model: aModel
		  key: aVariableOrNil
		  required: aBoolean
		  json: aJsonMode
		  temperature: aTemperatureOrNil
]

{ #category : 'accessing' }
DdLlmProvider class >> named: anId [

	^ self all
		  detect: [ :each | each id = anId asSymbol ]
		  ifNone: [ self all first ]
]

{ #category : 'comparing' }
DdLlmProvider >> = anObject [
	^ self class = anObject class and: [ id = anObject id ]
]

{ #category : 'accessing' }
DdLlmProvider >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
DdLlmProvider >> clientClass [
	^ Smalltalk globals at: clientClassName
]

{ #category : 'accessing' }
DdLlmProvider >> defaultModel [
	^ defaultModel
]

{ #category : 'comparing' }
DdLlmProvider >> hash [
	^ id hash
]

{ #category : 'accessing' }
DdLlmProvider >> id [
	^ id
]

{ #category : 'accessing' }
DdLlmProvider >> jsonMode [
	"Whether the provider is asked for JSON output (response_format)."

	^ jsonMode
]

{ #category : 'accessing' }
DdLlmProvider >> keyRequired [
	^ keyRequired
]

{ #category : 'accessing' }
DdLlmProvider >> keyVariable [
	"The environment variable the key may come from, or nil."

	^ keyVariable
]

{ #category : 'accessing' }
DdLlmProvider >> label [
	^ label
]

{ #category : 'printing' }
DdLlmProvider >> printOn: aStream [
	aStream nextPutAll: label
]

{ #category : 'initialization' }
DdLlmProvider >> setId: anId label: aLabel client: aClientClassName baseUrl: aUrl model: aModel key: aVariableOrNil required: aBoolean json: aJsonMode temperature: aTemperatureOrNil [

	id := anId.
	label := aLabel.
	clientClassName := aClientClassName.
	baseUrl := aUrl.
	defaultModel := aModel.
	keyVariable := aVariableOrNil.
	keyRequired := aBoolean.
	jsonMode := aJsonMode.
	temperature := aTemperatureOrNil
]

{ #category : 'accessing' }
DdLlmProvider >> temperature [
	"Sent with each request, or nil for the model's own default."

	^ temperature
]
