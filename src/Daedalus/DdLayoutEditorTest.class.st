Class {
	#name : 'DdLayoutEditorTest',
	#superclass : 'TestCase',
	#category : 'Daedalus-Tests',
	#package : 'Daedalus',
	#tag : 'Tests'
}

{ #category : 'helpers' }
DdLayoutEditorTest >> aRow: n [
	^ self row: 'a #add:expand: #(''false'')' level: n
]

{ #category : 'helpers' }
DdLayoutEditorTest >> assertTree: anEditor equals: expectedLines [
	self
		assert: anEditor root treeString lines asArray
		equals: expectedLines asArray
]

{ #category : 'helpers' }
DdLayoutEditorTest >> bRow: n [
	^ self row: 'b #add: #()' level: n
]

{ #category : 'helpers' }
DdLayoutEditorTest >> boxRow: n [
	^ self row: 'Box #newLeftToRight' level: n
]

{ #category : 'helpers' }
DdLayoutEditorTest >> cRow: n [
	^ self row: 'c #add:width: #(''50'')' level: n
]

{ #category : 'helpers' }
DdLayoutEditorTest >> dRow: n [
	^ self row: 'd #add: #()' level: n
]

{ #category : 'helpers' }
DdLayoutEditorTest >> eRow: n [
	^ self row: 'e #add: #()' level: n
]

{ #category : 'fixtures' }
DdLayoutEditorTest >> editor [
	^ DdLayoutEditor on: self fixture
]

{ #category : 'fixtures' }
DdLayoutEditorTest >> fixture [
	^ 'defaultLayout
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

{ #category : 'helpers' }
DdLayoutEditorTest >> rootRow [
	^ self row: 'Box #newTopToBottom spacing:' level: 0
]

{ #category : 'helpers' }
DdLayoutEditorTest >> row: aString level: n [
	^ (String new: n * 2 withAll: Character space) , aString
]

{ #category : 'tests' }
DdLayoutEditorTest >> testBaselineAndFormatRoundTrip [
	| e expected |
	e := self editor.
	expected := {
		            self rootRow.
		            (self aRow: 1).
		            (self bRow: 1).
		            (self boxRow: 1).
		            (self cRow: 2).
		            (self dRow: 2) }.
	self assertTree: e equals: expected.
	self assertTree: (DdLayoutEditor on: e source) equals: expected
]

{ #category : 'tests' }
DdLayoutEditorTest >> testInsertIntoEmptyBox [
	| e |
	e := DdLayoutEditor on:
		     'defaultLayout
		^ SpBoxLayout newTopToBottom spacing: 5; yourself'.
	e insertWidget: 'e' into: #(  ) at: 1.
	self assertTree: e equals: {
			self rootRow.
			(self eRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testInsertWidgetAtEnd [
	| e |
	e := self editor insertWidget: 'e' into: #(  ) at: 4.
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2).
			(self eRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testInsertWidgetInMiddle [
	| e |
	e := self editor insertWidget: 'e' into: #(  ) at: 2.
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self eRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testInsertWidgetIntoNestedBox [
	| e |
	e := self editor insertWidget: 'e' into: #( 3 ) at: 3.
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2).
			(self eRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveDown [
	| e |
	e := self editor moveDownAt: #( 1 ).
	self assertTree: e equals: {
			self rootRow.
			(self bRow: 1).
			(self aRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveDownLastChildFails [
	self should: [ self editor moveDownAt: #( 3 ) ] raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveIntoItselfFails [
	self
		should: [ self editor moveAt: #( 3 ) toBoxAt: #( 3 ) index: 1 ]
		raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveIntoNestedBox [
	| e |
	e := self editor moveAt: #( 2 ) toBoxAt: #( 3 ) index: 1.
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self boxRow: 1).
			(self bRow: 2).
			(self cRow: 2).
			(self dRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveOutOfNestedBox [
	| e |
	e := self editor moveAt: #( 3 2 ) toBoxAt: #(  ) index: 1.
	self assertTree: e equals: {
			self rootRow.
			(self dRow: 1).
			(self aRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self cRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveToEndOfSameContainer [
	| e |
	e := self editor moveAt: #( 1 ) toBoxAt: #(  ) index: 3.
	self assertTree: e equals: {
			self rootRow.
			(self bRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2).
			(self aRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveToFrontOfSameContainer [
	| e |
	e := self editor moveAt: #( 2 ) toBoxAt: #(  ) index: 1.
	self assertTree: e equals: {
			self rootRow.
			(self bRow: 1).
			(self aRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveUp [
	| e |
	e := self editor moveUpAt: #( 3 ).
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2).
			(self bRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveUpFirstChildFails [
	self should: [ self editor moveUpAt: #( 1 ) ] raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveUpInsideNestedBox [
	| e |
	e := self editor moveUpAt: #( 3 2 ).
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self dRow: 2).
			(self cRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveUpRootFails [
	self should: [ self editor moveUpAt: #(  ) ] raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveWholeNestedBox [
	| e |
	e := self editor moveAt: #( 3 ) toBoxAt: #(  ) index: 1.
	self assertTree: e equals: {
			self rootRow.
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2).
			(self aRow: 1).
			(self bRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testMoveWithBadIndexFails [
	self
		should: [ self editor moveAt: #( 1 ) toBoxAt: #(  ) index: 9 ]
		raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testRemoveNestedBox [
	| e |
	e := self editor removeAt: #( 3 ).
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self bRow: 1) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testRemoveNestedWidget [
	| e |
	e := self editor removeAt: #( 3 1 ).
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self bRow: 1).
			(self boxRow: 1).
			(self dRow: 2) }
]

{ #category : 'tests' }
DdLayoutEditorTest >> testRemoveRootFails [
	self should: [ self editor removeAt: #(  ) ] raise: Error
]

{ #category : 'tests' }
DdLayoutEditorTest >> testRemoveWidget [
	| e |
	e := self editor removeAt: #( 2 ).
	self assertTree: e equals: {
			self rootRow.
			(self aRow: 1).
			(self boxRow: 1).
			(self cRow: 2).
			(self dRow: 2) }
]
