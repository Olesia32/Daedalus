Class {
	#name : 'DdConstraintProperty',
	#superclass : 'Object',
	#instVars : [
		'key',
		'label',
		'kind',
		'default',
		'choices'
	],
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'instance creation' }
DdConstraintProperty class >> key: aKey label: aLabel choices: aCollection default: aDefault [

	^ self new
		  setKey: aKey
		  label: aLabel
		  kind: #choice
		  default: aDefault
		  choices: aCollection
]

{ #category : 'instance creation' }
DdConstraintProperty class >> key: aKey label: aLabel kind: aKind default: aDefault [
"aKind is #boolean, #number (a whole number, or nil when the default is nil), #point (x@y of
whole numbers, or nil when the default is nil) or #choice (see key:label:choices:default:)."

	^ self new
		  setKey: aKey
		  label: aLabel
		  kind: aKind
		  default: aDefault
		  choices: nil
]

{ #category : 'accessing' }
DdConstraintProperty >> choices [

	^ choices
]

{ #category : 'accessing' }
DdConstraintProperty >> default [

	^ default
]

{ #category : 'accessing' }
DdConstraintProperty >> key [
	^ key
]

{ #category : 'accessing' }
DdConstraintProperty >> kind [

	^ kind
]

{ #category : 'accessing' }
DdConstraintProperty >> label [

	^ label
]

{ #category : 'printing' }
DdConstraintProperty >> printOn: aStream [

	aStream
		nextPutAll: 'Constraint ';
		nextPutAll: label
]

{ #category : 'initialization' }
DdConstraintProperty >> setKey: aKey label: aLabel kind: aKind default: aDefault choices: aCollection [

	key := aKey.
	label := aLabel.
	kind := aKind.
	default := aDefault.
	choices := aCollection
]

{ #category : 'validating' }
DdConstraintProperty >> validate: aValue [

	aValue ifNil: [
			default ifNotNil: [ ^ self error: label , ' cannot be empty' ].
			^ self ].
	kind = #boolean ifTrue: [
			(#( true false ) includes: aValue) ifFalse: [
				^ self error: label , ' must be true or false' ].
			^ self ].
	kind = #number ifTrue: [
			(aValue isInteger and: [ aValue >= 0 ]) ifFalse: [
				^ self error: label , ' must be a whole number, 0 or more' ].
			^ self ].
	kind = #point ifTrue: [
			((aValue isKindOf: Point) and: [
				 aValue x isInteger and: [ aValue y isInteger ] ]) ifFalse: [
				^ self error: label , ' must be written as x@y with whole numbers' ].
			^ self ].
	kind = #choice ifTrue: [
			(choices includes: aValue) ifFalse: [
				^ self error: label , ' must be one of ' , choices printString ] ]
]
