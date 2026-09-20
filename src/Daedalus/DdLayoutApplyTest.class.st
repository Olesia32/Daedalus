Class {
	#name : 'DdLayoutApplyTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenterClass'
	],
	#category : 'Daedalus-Tests',
	#package : 'Daedalus',
	#tag : 'Tests'
}

{ #category : 'helpers' }
DdLayoutApplyTest >> assertAdaptersBuilt: names in: aPresenter [
	names do: [ :each |
			self
				assert: (aPresenter instVarNamed: each) adapter notNil
				description: each , ' has no adapter, so it was not built' ]
]

{ #category : 'helpers' }
DdLayoutApplyTest >> buildPresenter [
	"The same path the canvas will use: new instance, then build."

	| presenter |
	presenter := presenterClass new.
	presenter build.
	^ presenter
]

{ #category : 'helpers' }
DdLayoutApplyTest >> currentTreeLines [
	^ (DdLayoutParser new parseMethodSource:
		   (presenterClass >> #defaultLayout) sourceCode) treeString lines
		  asArray
]

{ #category : 'helpers' }
DdLayoutApplyTest >> removeTemporaryClass [
	Smalltalk
		at: #DdTmpFormPresenter
		ifPresent: [ :cls | cls removeFromSystem ]
]

{ #category : 'running' }
DdLayoutApplyTest >> setUp [
	super setUp.
	self removeTemporaryClass.
	presenterClass := SpPresenter << #DdTmpFormPresenter
		slots: { #a. #b. #c. #d. #e };
		package: 'Daedalus-Tests';
		install.
	presenterClass compile: 'initializePresenters
	super initializePresenters.
	a := self newButton.
	b := self newButton.
	c := self newButton.
	d := self newButton.
	e := self newButton'.
	presenterClass compile: 'defaultLayout
	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: a expand: false;
		  add: b;
		  add: (SpBoxLayout newLeftToRight
				   add: c width: 50;
				   add: d;
				   yourself);
		  yourself'
]

{ #category : 'running' }
DdLayoutApplyTest >> tearDown [
	self removeTemporaryClass.
	super tearDown
]

{ #category : 'tests' }
DdLayoutApplyTest >> testApplyInsertedWidgetGetsBuilt [
	| editor presenter |
	editor := DdLayoutEditor forClass: presenterClass.
	editor insertWidget: 'e' into: #(  ) at: 2.
	editor applyTo: presenterClass.
	presenter := self buildPresenter.
	self assertAdaptersBuilt: #( 'a' 'b' 'c' 'd' 'e' ) in: presenter
]

{ #category : 'tests' }
DdLayoutApplyTest >> testApplyMoveKeepsAllWidgetsAndBuilds [
	| editor presenter |
	editor := DdLayoutEditor forClass: presenterClass.
	editor moveAt: #( 2 ) toBoxAt: #( 3 ) index: 1.
	editor applyTo: presenterClass.
	self
		assert: self currentTreeLines
		equals:
			{ 'Box #newTopToBottom spacing:'. '  a #add:expand: #(''false'')'.
			'  Box #newLeftToRight'. '    b #add: #()'. '    c #add:width: #(''50'')'.
			'    d #add: #()' }.
	presenter := self buildPresenter.
	self assertAdaptersBuilt: #( 'a' 'b' 'c' 'd' ) in: presenter
]

{ #category : 'tests' }
DdLayoutApplyTest >> testApplyRejectsUnknownVariable [
	| before editor |
	before := (presenterClass >> #defaultLayout) sourceCode.
	editor := (DdLayoutEditor forClass: presenterClass)
		          insertWidget: 'zzz'
		          into: #(  )
		          at: 1.
	self should: [ editor applyTo: presenterClass ] raise: Error.
	self
		assert: (presenterClass >> #defaultLayout) sourceCode
		equals: before
]

{ #category : 'tests' }
DdLayoutApplyTest >> testMoveAndMoveBackRestoresTree [
	"Two full editing rounds, each starting from the compiled code of the previous one."

	| presenter |
	(DdLayoutEditor forClass: presenterClass)
		moveAt: #( 2 ) toBoxAt: #( 3 ) index: 1;
		applyTo: presenterClass.
		(DdLayoutEditor forClass: presenterClass)
		moveAt: #( 2 1 ) toBoxAt: #(  ) index: 2;
		applyTo: presenterClass.
	self
		assert: self currentTreeLines
		equals:
			{ 'Box #newTopToBottom spacing:'. '  a #add:expand: #(''false'')'.
			'  b #add: #()'. '  Box #newLeftToRight'. '    c #add:width: #(''50'')'.
			'    d #add: #()' }.
	presenter := self buildPresenter.
	self assertAdaptersBuilt: #( 'a' 'b' 'c' 'd' ) in: presenter
]

{ #category : 'tests' }
DdLayoutApplyTest >> testUnattachedWidgetHasNoAdapter [
	"Characterisation test: the other tests rely on this to detect a widget lost from the layout."

	| presenter |
	presenter := self buildPresenter.
	self assertAdaptersBuilt: #( 'a' 'b' 'c' 'd' ) in: presenter.
	self assert: (presenter instVarNamed: 'e') adapter isNil
]
