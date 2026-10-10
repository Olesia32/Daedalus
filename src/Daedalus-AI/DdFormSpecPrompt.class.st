Class {
	#name : 'DdFormSpecPrompt',
	#superclass : 'Object',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'prompt' }
DdFormSpecPrompt class >> copyablePromptFor: aRequest [
"Everything in one text, to paste into any chat assistant in a browser - the way to use the
feature without an API key. Its JSON answer goes back through the JSON import."

	^ self systemInstruction , String cr , String cr
	  , 'The form to describe: ' , aRequest
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> formatVersion [

	^ 1
]
