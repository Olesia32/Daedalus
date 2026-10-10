Class {
	#name : 'DdFormSpecError',
	#superclass : 'Error',
	#instVars : [
		'problems'
	],
	#category : 'Daedalus-Daedalus-Import',
	#package : 'Daedalus',
	#tag : 'Daedalus-Import'
}

{ #category : 'signalling' }
DdFormSpecError class >> signalProblems: aCollection [

	^ self new
		  problems: aCollection;
		  signal
]

{ #category : 'accessing' }
DdFormSpecError >> messageText [

	^ 'The form description has ' , self problems size printString
	  , ' problem(s):' , String cr , (String cr join: self problems)
]

{ #category : 'accessing' }
DdFormSpecError >> problems [

	^ problems ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
DdFormSpecError >> problems: aCollection [

	problems := aCollection asArray
]
