Class {
	#name : 'DdFormSpecImporter',
	#superclass : 'Object',
	#instVars : [
		'targetClass',
		'builder'
	],
	#category : 'Daedalus-Daedalus-Import',
	#package : 'Daedalus',
	#tag : 'Daedalus-Import'
}

{ #category : 'importing' }
DdFormSpecImporter class >> importInto: aClass from: aDictionary [

	^ self new importInto: aClass from: aDictionary
]

{ #category : 'importing' }
DdFormSpecImporter >> compileProperties [
"DdKeywordProperties>>patchSource: puts a new message right after the variable's
assignment, so each widget's messages are handed over backwards to come out in order
(items: before itemSelected:)."

	| properties |
	properties := OrderedCollection new.
	builder widgets do: [ :each |
			each third reverseDo: [ :pair |
					properties add: (DdKeywordProperties new
							 varName: each first;
							 selector: pair key;
							 value: pair value;
							 yourself) ] ].
	properties isEmpty ifTrue: [ ^ self ].
	targetClass compile: (DdInitializeCodeBuilder new
			 presenterClass: targetClass properties: properties;
			 generate)
]

{ #category : 'importing' }
DdFormSpecImporter >> descriptorFor: aJsonType [

	| label |
	label := DdFormSpecLayoutBuilder widgetTypes at: aJsonType.
	^ DdWidgetRegistry all detect: [ :each | each label = label ]
]

{ #category : 'importing' }
DdFormSpecImporter >> importInto: aClass from: aDictionary [

	| source service |
	targetClass := aClass.
	builder := DdFormSpecLayoutBuilder new.
	builder reservedNames: aClass allInstVarNames.
	source := builder sourceFor: aDictionary.
	service := DdAddWidgetService new
		           presenterClass: aClass;
		           yourself.
	
	builder widgets reverseDo: [ :each |
			service addInstVar: each first.
			service
				patchInitializePresenters: each first
				initExpression: (self descriptorFor: each second) initExpression ].
	self compileProperties.
	(DdLayoutEditor on: source) applyTo: aClass.
	^ builder
]
