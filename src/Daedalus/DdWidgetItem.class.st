Class {
	#name : 'DdWidgetItem',
	#superclass : 'Object',
	#instVars : [
		'name',
		'presenterClass'
	],
	#category : 'Daedalus',
	#package : 'Daedalus'
}

{ #category : 'accessing' }
DdWidgetItem >> name [
    ^ name
]

{ #category : 'as yet unclassified' }
DdWidgetItem >> name: aString presenterClass: aClass [
    name := aString.
    presenterClass := aClass.
    ^ self
]
