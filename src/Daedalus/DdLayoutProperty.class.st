Class {
	#name : 'DdLayoutProperty',
	#superclass : 'Object',
	#instVars : [
		'label',
		'kind',
		'selector',
		'offSelector',
		'default'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'instance creation' }
DdLayoutProperty class >> flag: aLabel on: anOnSelector off: anOffSelector default: aBoolean [
"A pair of unary messages, e.g. beHomogeneous / beNotHomogeneous. Only written to the code
when it differs from aBoolean, Spec's default."

	^ self new
		  setLabel: aLabel
		  kind: #flag
		  selector: anOnSelector
		  offSelector: anOffSelector
		  default: aBoolean
]

{ #category : 'instance creation' }
DdLayoutProperty class >> fraction: aLabel selector: aSelector [
"A number between 0 and 1, e.g. positionOfSlider: 0.3."

	^ self new
		  setLabel: aLabel
		  kind: #fraction
		  selector: aSelector
		  offSelector: nil
		  default: nil
]

{ #category : 'instance creation' }
DdLayoutProperty class >> number: aLabel selector: aSelector [
"A whole number, e.g. spacing: 4. Absent from the code means Spec's own default."

	^ self new
		  setLabel: aLabel
		  kind: #number
		  selector: aSelector
		  offSelector: nil
		  default: nil
]

{ #category : 'accessing' }
DdLayoutProperty >> default [

	^ default
]

{ #category : 'testing' }
DdLayoutProperty >> isFlag [

	^ kind = #flag
]

{ #category : 'accessing' }
DdLayoutProperty >> kind [

	^ kind
]

{ #category : 'accessing' }
DdLayoutProperty >> label [

	^ label
]

{ #category : 'code' }
DdLayoutProperty >> messageFor: aValue receiver: aReceiverNode [
"The cascade message that sets aValue, or nil when nothing needs to be written (a cleared
number, or a flag at its default)."

	aValue ifNil: [ ^ nil ].
	kind = #flag ifTrue: [
			aValue = default ifTrue: [ ^ nil ].
			^ OCMessageNode
				  receiver: aReceiverNode
				  selector: (aValue
						   ifTrue: [ selector ]
						   ifFalse: [ offSelector ])
				  arguments: #(  ) ].
	^ OCMessageNode
		  receiver: aReceiverNode
		  selector: selector
		  arguments: { (OCParser parseExpression: aValue printString) }
]

{ #category : 'accessing' }
DdLayoutProperty >> offSelector [

	^ offSelector
]

{ #category : 'printing' }
DdLayoutProperty >> printOn: aStream [

	aStream
		nextPutAll: 'Property ';
		nextPutAll: label
]

{ #category : 'accessing' }
DdLayoutProperty >> selector [

	^ selector
]

{ #category : 'accessing' }
DdLayoutProperty >> selectors [
"Every selector this property can appear as in a cascade."

	^ offSelector ifNil: [ { selector } ] ifNotNil: [
			  {
				  selector.
				  offSelector } ]
]

{ #category : 'initialization' }
DdLayoutProperty >> setLabel: aLabel kind: aKind selector: aSelector offSelector: anOffSelector default: aDefault [

	label := aLabel.
	kind := aKind.
	selector := aSelector.
	offSelector := anOffSelector.
	default := aDefault
]

{ #category : 'code' }
DdLayoutProperty >> validate: aValue [

	aValue ifNil: [ ^ self ].
	kind = #flag ifTrue: [
			(#( true false ) includes: aValue) ifFalse: [
				^ self error: label , ' must be true or false' ].
			^ self ].
	aValue isNumber ifFalse: [ ^ self error: label , ' must be a number' ].
	kind = #number ifTrue: [
			(aValue isInteger and: [ aValue >= 0 ]) ifFalse: [
				^ self error: label , ' must be a whole number, 0 or more' ] ].
	kind = #fraction ifTrue: [
			(aValue between: 0 and: 1) ifFalse: [
				^ self error: label , ' must be between 0 and 1' ] ]
]
