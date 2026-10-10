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
DdLayoutProperty class >> alignment: aLabel prefix: aPrefix [
"hAlign / vAlign of SpTAlignable: one of the unary messages <prefix>Start, <prefix>Center,
<prefix>End, or none of them (#none)."

	^ self new
		  setLabel: aLabel
		  kind: #align
		  selector: aPrefix
		  offSelector: nil
		  default: #none
]

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
DdLayoutProperty class >> indexList: aLabel selector: aSelector [
"A set of column (or row) numbers, each written as '<selector> n expand: true' - e.g.
column: 2 expand: true. The value is an Array of whole numbers, empty when none."

	^ self new
		  setLabel: aLabel
		  kind: #indexList
		  selector: aSelector
		  offSelector: nil
		  default: #(  )
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

{ #category : 'instance creation' }
DdLayoutProperty class >> sliderPosition: aLabel selector: aSelector [
"positionOfSlider: takes a fraction (0.3 = 30%) or a whole number of pixels."

	^ self new
		  setLabel: aLabel
		  kind: #slider
		  selector: aSelector
		  offSelector: nil
		  default: nil
]

{ #category : 'instance creation' }
DdLayoutProperty class >> string: aLabel selector: aSelector [
"A text, e.g. label: 'Group'. Empty means no message."

	^ self new
		  setLabel: aLabel
		  kind: #string
		  selector: aSelector
		  offSelector: nil
		  default: nil
]

{ #category : 'accessing' }
DdLayoutProperty >> choices [

	^ self isAlign
		  ifTrue: [ #( #none #start #center #end ) ]
		  ifFalse: [ #(  ) ]
]

{ #category : 'accessing' }
DdLayoutProperty >> default [

	^ default
]

{ #category : 'testing' }
DdLayoutProperty >> isAlign [

	^ kind = #align
]

{ #category : 'testing' }
DdLayoutProperty >> isFlag [

	^ kind = #flag
]

{ #category : 'testing' }
DdLayoutProperty >> isIndexList [

	^ kind = #indexList
]

{ #category : 'testing' }
DdLayoutProperty >> isString [

	^ kind = #string
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
number, a flag at its default, an alignment set to none)."

	aValue ifNil: [ ^ nil ].
	kind = #align ifTrue: [
			aValue = #none ifTrue: [ ^ nil ].
			^ OCMessageNode
				  receiver: aReceiverNode
				  selector: (selector , aValue asString capitalized) asSymbol
				  arguments: #(  ) ].
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

	self isAlign ifTrue: [
			^ #( 'Start' 'Center' 'End' ) collect: [ :each |
				  (selector , each) asSymbol ] ].
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
	kind = #string ifTrue: [
			aValue isString ifFalse: [ ^ self error: label , ' must be a text' ].
			^ self ].
	kind = #indexList ifTrue: [
			(aValue isCollection and: [
				 aValue allSatisfy: [ :each | each isInteger and: [ each >= 1 ] ] ])
				ifFalse: [
				^ self error: label , ' must be numbers from 1, e.g. 2, 3' ].
			^ self ].
	kind = #align ifTrue: [
			(self choices includes: aValue) ifFalse: [
				^ self error:
					  label , ' must be one of ' , self choices printString ].
			^ self ].
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
				^ self error: label , ' must be between 0 and 1' ] ].
	kind = #slider ifTrue: [
			((aValue > 0 and: [ aValue <= 1 ]) or: [
				 aValue isInteger and: [ aValue > 1 ] ]) ifFalse: [
					^ self error:
						  label
						  ,
						  ' must be a fraction (0.3) or a whole number of pixels (200)' ] ]
]
