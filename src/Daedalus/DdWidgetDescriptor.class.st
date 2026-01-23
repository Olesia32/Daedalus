Class {
	#name : 'DdWidgetDescriptor',
	#superclass : 'Object',
	#instVars : [
		'label',
		'icon',
		'presenterClass'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'accessing' }
DdWidgetDescriptor >> icon [
    ^ icon
]

{ #category : 'accessing' }
DdWidgetDescriptor >> label [
    ^ label
]

{ #category : 'as yet unclassified' }
DdWidgetDescriptor >> label: aString icon: anIcon presenter: aClass [
    label := aString.
    icon := anIcon.
    presenterClass := aClass.
    ^ self
]

{ #category : 'accessing' }
DdWidgetDescriptor >> presenterClass [
    ^ presenterClass
]
