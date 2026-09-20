Class {
	#name : 'DdWidgetNode',
	#superclass : 'DdLayoutNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'testing' }
DdWidgetNode >> isWidgetNode [
	^ true
]

{ #category : 'printing' }
DdWidgetNode >> printOn: aStream [
	aStream
		nextPutAll: self varName;
		space;
		print: self addSelector;
		space;
		print: self constraintArguments
]

{ #category : 'labels' }
DdWidgetNode >> treeLabel [
	| constraints |
	constraints := self constraintsLabel.
	^ constraints isEmpty
		  ifTrue: [ self varName ]
		  ifFalse: [ self varName , ' [' , constraints , ']' ]
]

{ #category : 'accessing' }
DdWidgetNode >> varName [
	^ addMessage arguments first name
]

{ #category : 'accessing' }
DdWidgetNode >> widgetNames [
	^ { self varName }
]
