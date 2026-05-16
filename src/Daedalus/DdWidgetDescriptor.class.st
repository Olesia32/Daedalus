"
I am a data object that describes a single entry in the widget palette. I carry the display label, the icon, and the presenter
class that should be instantiated when the widget is added to the canvas.

### Hierarchy
`Object`
`DdWidgetDescriptor` (this is me)

### Instance Variables
- _label_: `String` — the name shown in the palette list
- _icon_: `Form` — the icon shown next to the label
- _presenterClass_: `Class` — the presenter class to wrap on add
"
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
"Returns the initialisation expression used by DdAddWidgetService to create the widget, wrapping presenterClass in a PresenterDecorator."
	
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
