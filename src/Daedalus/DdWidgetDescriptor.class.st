Class {
	#name : 'DdWidgetDescriptor',
	#superclass : 'Object',
	#instVars : [
		'label',
		'icon',
		'presenterClass',
		'propertyDescriptor'
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
DdWidgetDescriptor >> label: arg1 icon: arg2 presenter: arg3 [

	label := arg1.
	icon := arg2.
	presenterClass := arg3
]

{ #category : 'as yet unclassified' }
DdWidgetDescriptor >> label: aString icon: anIcon presenter: aClass descriptor: aDescriptor [ 
    label := aString.
    icon := anIcon.
    presenterClass := aClass.
    propertyDescriptor := aDescriptor.
    ^ self
]

{ #category : 'accessing' }
DdWidgetDescriptor >> presenterClass [

	^ presenterClass
]

{ #category : 'accessing' }
DdWidgetDescriptor >> propertyDescriptor [

	^ propertyDescriptor
]

{ #category : 'accessing' }
DdWidgetDescriptor >> propertyDescriptor: anObject [

	propertyDescriptor := anObject
]
