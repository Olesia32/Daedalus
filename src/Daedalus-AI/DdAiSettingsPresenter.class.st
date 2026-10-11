Class {
	#name : 'DdAiSettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'providerList',
		'baseUrlInput',
		'keyInput',
		'keyHint',
		'modelInput',
		'loadModelsButton',
		'modelList',
		'statusLabel'
	],
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'layout' }
DdAiSettingsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 6;
		  add: (self rowLabeled: 'Provider' with: providerList) expand: false;
		  add: (self rowLabeled: 'Address' with: baseUrlInput) expand: false;
		  add: (self rowLabeled: 'API key' with: keyInput) expand: false;
		  add: keyHint expand: false;
		  add: (self rowLabeled: 'Model' with: modelInput) expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 6;
				   add: loadModelsButton width: 90;
				   add: modelList;
				   yourself)
		  expand: false;
		  add: statusLabel expand: false;
		  add: (self newLabel
				   label:
					   'Changes apply at once. The key is kept in this image: before giving the image away, evaluate DdAiSettings forgetKeys.';
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
DdAiSettingsPresenter >> initializePresenters [

	providerList := self newDropList.
	providerList
		items: DdLlmProvider all;
		display: [ :each | each label ].
	baseUrlInput := self newTextInput.
	keyInput := self newTextInput.
	keyInput bePassword.
	keyHint := self newLabel.
	modelInput := self newTextInput.
	modelInput placeholder: 'Type a model, or List models and pick one'.
	loadModelsButton := self newButton.
	loadModelsButton
		label: 'List models';
		action: [ self loadModels ].
	modelList := self newDropList.
	modelList display: [ :each | each ].
	statusLabel := self newLabel.
	providerList selectItem: DdAiSettings provider.
	self showProvider: DdAiSettings provider.
	"handlers last, so filling the fields above writes nothing"
	providerList whenSelectedItemChangedDo: [ :each |
		each ifNotNil: [
			DdAiSettings providerId: each id.
			self showProvider: each ] ].
	baseUrlInput whenTextChangedDo: [ :text |
		DdAiSettings baseUrl: text asString trimBoth for: self provider ].
	keyInput whenTextChangedDo: [ :text |
		DdAiSettings key: text asString trimBoth for: self provider ].
	modelInput whenTextChangedDo: [ :text |
		DdAiSettings model: text asString trimBoth for: self provider ].
	modelList whenSelectedItemChangedDo: [ :each |
		each ifNotNil: [ modelInput text: each ] ]
]

{ #category : 'initialization' }
DdAiSettingsPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Daedalus AI settings';
		initialExtent: 480 @ 330
]

{ #category : 'actions' }
DdAiSettingsPresenter >> loadModels [
	"Asked in the background: a slow or unreachable server must not freeze the image."

	| client |
	client := DdAiSettings newClientFor: self provider.
	loadModelsButton enabled: false.
	statusLabel label: 'Asking ' , self provider label , ' for its models ...'.
	[
	| names failure |
	failure := nil.
	names := [ client modelNames ]
		         on: Error
		         do: [ :error |
			         failure := error messageText.
			         #(  ) ].
	UIManager default defer: [
		loadModelsButton enabled: true.
		modelList items: names.
		statusLabel label: (failure ifNil: [
				 names size printString , ' models - pick one in the list' ]) ] ]
		forkAt: Processor userBackgroundPriority
		named: 'Daedalus AI models'
]

{ #category : 'private' }
DdAiSettingsPresenter >> provider [
	^ providerList selectedItem ifNil: [ DdAiSettings provider ]
]

{ #category : 'layout' }
DdAiSettingsPresenter >> rowLabeled: aString with: aPresenter [

	^ SpBoxLayout newLeftToRight
		  spacing: 6;
		  add: (self newLabel
				   label: aString;
				   yourself)
		  width: 70;
		  add: aPresenter;
		  yourself
]

{ #category : 'actions' }
DdAiSettingsPresenter >> showProvider: aProvider [

	baseUrlInput text: (DdAiSettings baseUrlFor: aProvider).
	keyInput text: (DdAiSettings storedKeyFor: aProvider).
	keyHint label: (aProvider keyVariable
			 ifNil: [
				 aProvider keyRequired
					 ifTrue: [ '' ]
					 ifFalse: [ 'No key needed - enter one only if your server asks for it.' ] ]
			 ifNotNil: [ :variable |
			 'Or leave it empty and set the ' , variable , ' environment variable.' ]).
	modelInput text: (DdAiSettings modelFor: aProvider).
	modelList items: #(  ).
	statusLabel label: ''
]
