Class {
	#name : 'DdLlmClient',
	#superclass : 'Object',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'answering' }
DdLlmClient >> answerTo: aConversation system: aSystemText [
"aConversation: role -> text associations, oldest first (#user / #model).
Answers the text of the model's reply, or signals DdAiError with a message for the user."

	^ self subclassResponsibility
]
