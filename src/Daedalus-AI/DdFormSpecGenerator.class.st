Class {
	#name : 'DdFormSpecGenerator',
	#superclass : 'Object',
	#instVars : [
		'client',
		'attempts'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'constants' }
DdFormSpecGenerator class >> maxAttempts [
	"The first answer and one repair. More rarely helps and costs free-tier requests."

	^ 2
]

{ #category : 'accessing' }
DdFormSpecGenerator >> attempts [
"How many answers the last descriptionFor: took (1 = right the first time)."

	^ attempts
]

{ #category : 'accessing' }
DdFormSpecGenerator >> client: aClient [

	client := aClient
]

{ #category : 'generating' }
DdFormSpecGenerator >> descriptionFor: aRequest [
"A form description (a Dictionary) DdFormSpecImporter can take. An answer with problems goes
back to the model with the list of problems, in the same conversation; when the last attempt
still has some, DdFormSpecError lists them."

	| conversation answer problems |
	conversation := OrderedCollection with: #user -> aRequest.
	attempts := 0.
	[
		attempts := attempts + 1.
		answer := client
			          answerTo: conversation
			          system: DdFormSpecPrompt systemInstruction.
		problems := self problemsIn: answer.
		problems isEmpty ifTrue: [ ^ STONJSON fromString: answer ].
		attempts < self class maxAttempts ] whileTrue: [
			conversation
				add: #model -> answer;
				add: #user -> (self repairRequestFor: problems) ].
	^ DdFormSpecError signalProblems: problems
]

{ #category : 'private' }
DdFormSpecGenerator >> problemsIn: anAnswer [

	| description |
	description := [ STONJSON fromString: anAnswer ]
		               on: Error
		               do: [ ^ #( 'the answer is not valid JSON' ) ].
	[ DdFormSpecLayoutBuilder sourceFor: description ]
		on: DdFormSpecError
		do: [ :error | ^ error problems ].
	^ #(  )
]

{ #category : 'private' }
DdFormSpecGenerator >> repairRequestFor: aCollection [

	^ 'Your description has these problems:' , String cr
	  , (String cr join: aCollection) , String cr
	  ,
	  'Fix them and answer with the whole corrected description, as JSON only.'
]
