Class {
	#name : 'DdFormSpecPrompt',
	#superclass : 'Object',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'prompt' }
DdFormSpecPrompt class >> copyablePromptFor: aRequest [
	^ self copyablePromptFor: aRequest current: nil
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> copyablePromptFor: aRequest current: aDescriptionOrNil [
	"Everything in one text, to paste into any chat assistant in a browser - the way to use the
	feature without an API key. Its JSON answer goes back through Import JSON."

	^ self systemInstruction , String cr , String cr , (aDescriptionOrNil
		   ifNil: [ 'The form to describe: ' , aRequest ]
		   ifNotNil: [ self requestFor: aRequest current: aDescriptionOrNil ])
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> describeConstraint: aConstraintProperty [

	| kind |
	kind := aConstraintProperty kind.
	kind = #boolean ifTrue: [ ^ 'true or false' ].
	kind = #number ifTrue: [ ^ 'whole number' ].
	kind = #point ifTrue: [ ^ '[x, y]' ].
	kind = #choice ifTrue: [
		^ ', ' join: (aConstraintProperty choices collect: [ :each | each asString ]) ].
	^ kind asString
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> describeEntries: anEntries [

	anEntries isEmpty ifTrue: [ ^ 'none' ].
	^ ', ' join: (anEntries collect: [ :each |
			   each first , ' (' , (self describeSettingKind: each third) , ')' ])
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> describeLayout: aKind on: aStream [

	(DdFormSpecSchema directionsFor: aKind) do: [ :direction |
		| node child props constraints |
		node := DdLayoutParser new parseExpressionSource:
			        (DdFormSpecSchema sampleSourceFor: aKind direction: direction).
		child := node children last.
		props := node layoutProperties collect: [ :each |
			         (DdFormSpecSchema jsonKeyFor: each) , ' ('
			         , (self describeLayoutProperty: each) , ')' ].
		constraints := (node constraintPropertiesFor: child) collect: [ :each |
			               each key asString , ' (' , (self describeConstraint: each) , ')' ].
		aStream
			nextPutAll: '- ';
			nextPutAll: aKind.
		direction ifNotNil: [
			aStream
				nextPutAll: ' with "direction": "';
				nextPutAll: direction;
				nextPut: $" ].
		aStream
			nextPutAll: '. props: ';
			nextPutAll: (props isEmpty
					 ifTrue: [ 'none' ]
					 ifFalse: [ ', ' join: props ]);
			nextPutAll: '. children constraints: ';
			nextPutAll: (constraints isEmpty
					 ifTrue: [ 'none' ]
					 ifFalse: [ ', ' join: constraints ]).
		(DdFormSpecSchema childRuleFor: aKind) ifNotNil: [ :rule |
			aStream
				nextPutAll: '. ';
				nextPutAll: rule ].
		aStream
			nextPut: $.;
			cr ]
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> describeLayoutProperty: aLayoutProperty [

	| kind |
	kind := aLayoutProperty kind.
	kind = #number ifTrue: [ ^ 'whole number' ].
	kind = #flag ifTrue: [ ^ 'true or false' ].
	kind = #align ifTrue: [ ^ 'start, center or end' ].
	kind = #slider ifTrue: [ ^ 'a fraction like 0.3 or pixels like 200' ].
	kind = #fraction ifTrue: [ ^ 'a fraction from 0 to 1' ].
	kind = #string ifTrue: [ ^ 'text' ].
	kind = #indexList ifTrue: [ ^ 'array of numbers from 1' ].
	^ kind asString
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> describeSettingKind: aKind [

	aKind = #string ifTrue: [ ^ 'text' ].
	aKind = #strings ifTrue: [ ^ 'array of texts' ].
	(aKind = #boolean or: [ aKind = #flag ]) ifTrue: [ ^ 'true or false' ].
	aKind = #number ifTrue: [ ^ 'number' ].
	aKind = #indexes ifTrue: [ ^ 'array of positions in items, from 1' ].
	^ 'position in items, from 1'
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> formatVersion [
	^ DdFormSpecSchema formatVersion
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> introduction [

	^ 'You generate UI form descriptions for a Pharo Spec2 visual designer. Reply with JSON only.
Format: {"version": ' , self formatVersion printString , ', "root": NODE}. The root is always a container.
A NODE is a container {"layout": KIND, "direction": ..., "props": {...}, "children": [NODE, ...]}, a widget {"widget": TYPE, "name": ID, "props": {...}, "style": {...}} or code {"code": "..."}.
Any child may have "constraints": they belong to the PARENT layout and say how the child sits in it.'
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> requestFor: aRequest current: aDescriptionOrNil [
	"What the user turn says: the request alone, or the current form and the change asked for."

	aDescriptionOrNil ifNil: [ ^ aRequest ].
	^ 'The current form:' , String cr , (STONJSON toString: aDescriptionOrNil) , String cr
	  , String cr
	  , 'Change it as follows and answer with the whole updated description: '
	  , aRequest
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> rules [

	^ 'Use only the layouts, widgets, props, style and constraints listed here, and leave out every value you do not need: all of them have sensible defaults.
Inside a vertical box give a height only when the user asks for sizes: captions, fields and buttons keep their natural height by themselves, lists and text areas grow.
Put a caption for a group or an input into a separate label widget placed before it.
A {"code": "..."} child is code the designer cannot edit: keep it unchanged and in its place.
A widget {"widget": "other", "name": ...} is one the designer does not know: it can be kept or moved, never created or changed.
When you are given the current form, change only what the request asks for and keep everything else as it is. Keep the names of the widgets that stay, so they keep their code.
ID: meaningful English camelCase derived from the content, unique, starting with a lowercase letter, e.g. readingCheckBox, emailInput.'
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> systemInstruction [
	"Written from the designer's own model: the layouts, their properties and their children's
	constraints are read from the nodes, the widgets from DdFormSpecSchema - so the prompt can
	never promise what the import refuses."

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: self introduction;
			  cr;
			  cr;
			  nextPutAll:
				  'Layouts ("layout"), their "props", and the "constraints" their children take:';
			  cr.
		  DdFormSpecSchema kindsInOrder do: [ :kind |
			  self describeLayout: kind on: stream ].
		  stream
			  cr;
			  nextPutAll: 'Widgets ("widget") and their "props":';
			  cr.
		  DdFormSpecSchema widgetProperties keys asSortedCollection do: [ :type |
			  stream
				  nextPutAll: '- ';
				  nextPutAll: type;
				  nextPutAll: ': ';
				  nextPutAll:
					  (self describeEntries: (DdFormSpecSchema widgetProperties at: type));
				  nextPut: $.;
				  cr ].
		  stream
			  nextPutAll: 'Any widget may also have "style": ';
			  nextPutAll: (self describeEntries: DdFormSpecSchema styleProperties);
			  nextPut: $.;
			  cr;
			  cr;
			  nextPutAll: self rules ]
]
