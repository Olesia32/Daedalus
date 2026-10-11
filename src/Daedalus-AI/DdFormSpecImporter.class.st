Class {
	#name : 'DdFormSpecImporter',
	#superclass : 'Object',
	#instVars : [
		'targetClass',
		'builder'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'building' }
DdFormSpecImporter class >> builderFor: aClass [
	"A builder that knows aClass: the names it uses and the widgets it already has. The import and
	the generator's check must use the same one, or they disagree about what is allowed."

	^ DdFormSpecLayoutBuilder new
		  reservedNames: aClass allInstVarNames;
		  existingWidgets: (self new existingWidgetsOf: aClass);
		  yourself

]

{ #category : 'importing' }
DdFormSpecImporter class >> importInto: aClass from: aDictionary [

	^ self new importInto: aClass from: aDictionary
]

{ #category : 'importing' }
DdFormSpecImporter >> compileProperties [
	"DdKeywordProperties / DdUnaryProperties put a new message right after the variable's
	assignment, so each widget's settings are handed over backwards to come out in order
	(items: before itemSelected:)."

	| properties |
	properties := OrderedCollection new.
	builder widgets do: [ :each |
		each third reverseDo: [ :setting |
			properties add: (setting third = #flag
					 ifTrue: [
						 DdUnaryProperties new
							 varName: each first;
							 selector: setting first;
							 state: true;
							 yourself ]
					 ifFalse: [
						 DdKeywordProperties new
							 varName: each first;
							 selector: setting first;
							 value: setting second;
							 yourself ]) ] ].
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
DdFormSpecImporter >> existingWidgetsOf: aClass [
	"Variable name -> JSON type, as the export reads initializePresenters."

	| types |
	types := Dictionary new.
	(DdFormSpecExporter new widgetsOf: aClass) keysAndValuesDo: [ :name :info |
		types at: name put: (info at: #type) ].
	^ types
]

{ #category : 'importing' }
DdFormSpecImporter >> importInto: aClass from: aDictionary [
	"Writes the description into aClass. A widget the class already has (same name, same type)
	keeps its variable and its code, and gets only the props of the description; a new one gets
	a variable and a line in initializePresenters. defaultLayout is replaced. When the
	description has a problem nothing is changed. Answers the builder."

	| source service |
	targetClass := aClass.
	builder := self class builderFor: aClass.
	source := builder sourceFor: aDictionary.
	service := DdAddWidgetService new
		           presenterClass: aClass;
		           yourself.
	"patchInitializePresenters: puts each new variable right after the super call: going
	backwards leaves them in document order"
	builder widgets reverseDo: [ :each |
		each fourth ifFalse: [
			service addInstVar: each first.
			service
				patchInitializePresenters: each first
				initExpression: (self descriptorFor: each second) initExpression ] ].
	self compileProperties.
	(DdLayoutEditor on: source) applyTo: aClass.
	^ builder

]
