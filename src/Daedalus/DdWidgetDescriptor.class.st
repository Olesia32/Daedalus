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
DdWidgetDescriptor >> initExpression [

	^ 'PresenterDecorator wrap: ' , presenterClass name
]

{ #category : 'accessing' }
DdWidgetDescriptor >> label [

	^ label
]

{ #category : 'as yet unclassified' }
DdWidgetDescriptor >> label: arg1 icon: arg2 presenter: arg3 [

	label := arg1.
	icon := arg2.
	presenterClass := arg3.
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
DdWidgetDescriptor >> propertyDescriptor: arg1 [

	propertyDescriptor := arg1
]
