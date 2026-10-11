Class {
	#name : 'DdAiPanelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'designer',
		'requestText',
		'newFormCheckBox',
		'generateButton',
		'statusText',
		'summaryLabel',
		'settingsButton'
	],
	#classVars : [
		'Panels'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'instance creation' }
DdAiPanelPresenter class >> forDesigner: aDesigner [
	"One panel per designer, kept while the designer lives: the notebook may ask for its page
	again, and a request in progress must find its panel."

	^ self panels
		  at: aDesigner
		  ifAbsentPut: [
			  self new
				  setDesigner: aDesigner;
				  yourself ]
]

{ #category : 'instance creation' }
DdAiPanelPresenter class >> panels [
	^ Panels ifNil: [ Panels := WeakIdentityKeyDictionary new ]
]

{ #category : 'actions' }
DdAiPanelPresenter >> apply: aDescription note: aString [
"Into the class open in the designer, then the designer's own refresh after an Undo/Redo:
code, tree and preview are rebuilt and the change is one history step."

	| builder |
	builder := [
	           DdFormSpecImporter
		           importInto: designer editedClass
		           from: aDescription ]
		           on: DdFormSpecError
		           do: [ :error | ^ self status: error messageText ].
	designer afterHistoryChange.
	self status: (String streamContents: [ :stream |
				 stream nextPutAll: aString.
				 builder notices do: [ :each |
						 stream
							 cr;
							 nextPutAll: each ] ])
]

{ #category : 'private' }
DdAiPanelPresenter >> busy: aBoolean [

	generateButton enabled: aBoolean not
]

{ #category : 'private' }
DdAiPanelPresenter >> currentDescription [
	"The form open in the designer, to be changed - nil for a new one: when 'Start a new form'
	is ticked, or the form is empty, or the designer cannot read it."

	| description |
	newFormCheckBox state ifTrue: [ ^ nil ].
	description := [
	               DdFormSpecExporter descriptionOf: designer editedClass ]
		               on: Error
		               do: [ ^ nil ].
	((description at: 'root') at: 'children') isEmpty ifTrue: [ ^ nil ].
	^ description
]

{ #category : 'layout' }
DdAiPanelPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: requestText;
		  add: newFormCheckBox expand: false;
		  add: generateButton expand: false;
		  add: statusText height: 45;
		  add: summaryLabel expand: false;
		  add: settingsButton expand: false;
		  yourself
]

{ #category : 'actions' }
DdAiPanelPresenter >> generate [
"Changes the current form when there is one; a new form replaces a non-empty one only when
the user agrees - asked before the request, so a No does not cost one."

	| request client current generator |
	request := requestText text asString trimBoth.
	request isEmpty ifTrue: [ ^ self status: 'Describe the form first.' ].
	client := DdAiSettings newClient.
	[ client checkReady ]
		on: DdAiError
		do: [ :error | ^ self status: error messageText ].
	current := self currentDescription.
	current ifNil: [ self mayReplace ifFalse: [ ^ self ] ].
	generator := DdFormSpecGenerator new client: client.
	self busy: true.
	self status: 'Asking ' , DdAiSettings summary , ' to '
		,
		(current
			 ifNil: [ 'make a new form' ]
			 ifNotNil: [ 'change the form' ]) , ' ...'.
	[
		| description failure |
		failure := nil.
		description := [ generator descriptionFor: request current: current ]
			               on: Error
			               do: [ :error |
					               failure := error messageText.
					               nil ].
		UIManager default defer: [
				self busy: false.
				failure ifNotNil: [ self status: failure ] ifNil: [
						self
							apply: description
							note:
							'Done in ' , generator attempts printString , ' attempt(s).' ] ] ]
		forkAt: Processor userBackgroundPriority
		named: 'Daedalus AI request'
]

{ #category : 'initialization' }
DdAiPanelPresenter >> initializePresenters [

	requestText := self newText.
	requestText placeholder:
		'e.g. a feedback form with a rating, or: put the buttons in one row'.
	newFormCheckBox := self newCheckBox.
	newFormCheckBox label: 'Start a new form'.
	generateButton := self newButton.
	generateButton
		label: 'Generate';
		action: [ self generate ].
	statusText := self newText.
	statusText beNotEditable.
	summaryLabel := self newLabel.
	settingsButton := self newButton.
	settingsButton
		label: 'Settings';
		action: [ self openSettings ].
	self refreshSummary
]

{ #category : 'private' }
DdAiPanelPresenter >> mayReplace [
"An empty form is simply filled; one with widgets is replaced only when the user agrees."

	| hasWidgets |
	hasWidgets := [
		              (DdLayoutEditor forClass: designer editedClass) root
			              widgetNames notEmpty ]
		              on: Error
		              do: [ false ].
	hasWidgets ifFalse: [ ^ true ].
	^ UIManager default confirm:
		  'Replace the form of ' , designer editedClass name
		  , '? Undo brings it back.'
]

{ #category : 'actions' }
DdAiPanelPresenter >> openSettings [

	DdAiSettingsPresenter new open whenClosedDo: [ self refreshSummary ]
]

{ #category : 'private' }
DdAiPanelPresenter >> refreshSummary [

	summaryLabel label: DdAiSettings summary
]

{ #category : 'initialization' }
DdAiPanelPresenter >> setDesigner: aDesigner [

	designer := aDesigner
]

{ #category : 'private' }
DdAiPanelPresenter >> status: aString [

	statusText text: aString
]
