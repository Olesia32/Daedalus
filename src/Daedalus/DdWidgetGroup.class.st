Class {
	#name : 'DdWidgetGroup',
	#superclass : 'Object',
	#instVars : [
		'name',
		'items'
	],
	#category : 'Daedalus',
	#package : 'Daedalus'
}

{ #category : 'accessing' }
DdWidgetGroup >> children [
    ^ items
]

{ #category : 'accessing' }
DdWidgetGroup >> name [
    ^ name
]

{ #category : 'as yet unclassified' }
DdWidgetGroup >> name: aName items: anArray [
    name := aName.
    items := anArray.
    ^ self
]
