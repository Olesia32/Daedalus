Class {
	#name : 'DdComponentTreePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'treePresenter',
		'refreshButton',
		'presenterClass',
		'upButton',
		'downButton',
		'deleteButton',
		'notifier',
		'changeAction',
		'selectionAction',
		'rootNode',
		'kindList',
		'addContainerButton',
		'wrapButton'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'instance creation' }
DdComponentTreePresenter class >> onClass: aClass [
	^ self new
		  presenterClass: aClass;
		  yourself
]

{ #category : 'actions' }
DdComponentTreePresenter >> addContainerToSelection [
	"Adds an empty container of the chosen kind inside the selected container, or after the selected widget."

	| kind |
	kind := self selectedContainerKind.
	kind ifNil: [ ^ self ].
	self
		editNode: (treePresenter selectedItem ifNil: [ rootNode ])
		with: [ :editor :path | editor addContainer: kind near: path ]
]

{ #category : 'layout' }
DdComponentTreePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: treePresenter;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: upButton;
				   add: downButton;
				   add: deleteButton;
				   add: refreshButton;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: kindList;
				   add: addContainerButton width: 50;
				   add: wrapButton width: 50;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'accessing' }
DdComponentTreePresenter >> deleteButton [
	^ deleteButton
]

{ #category : 'actions' }
DdComponentTreePresenter >> deleteSelection [
	self editSelection: [ :editor :path |
			editor removeAt: path.
			path allButLast ]
]

{ #category : 'accessing' }
DdComponentTreePresenter >> downButton [
	^ downButton
]

{ #category : 'private' }
DdComponentTreePresenter >> editNode: aNode with: aBlock [
"aBlock receives an editor and the path of aNode, edits, and answers the path to select
afterwards (or nil). The edit is compiled into the class, then the tree rebuilt from that
same editor's model (see showModelFrom:) rather than by re-parsing the class again."

	| path editor current newPath |
	aNode ifNil: [ ^ self ].
	path := aNode path.
	[
		editor := DdLayoutEditor forClass: presenterClass.
		current := [ editor nodeAt: path ]
			           on: Error
			           do: [ nil ].
		(current notNil and: [ current treeLabel = aNode treeLabel ])
			ifFalse: [ ^ self error: 'The tree is out of date - press Refresh' ].
		newPath := aBlock value: editor value: path.
		editor applyTo: presenterClass ]
		on: Error
		do: [ :error | ^ self notifyUser: error messageText ].
	self showModelFrom: editor.
	newPath ifNotNil: [ self selectNodeAtPath: newPath ].
	changeAction ifNotNil: [ :action | action value ]
]

{ #category : 'private' }
DdComponentTreePresenter >> editSelection: aBlock [
	self editNode: treePresenter selectedItem with: aBlock
]

{ #category : 'initialization' }
DdComponentTreePresenter >> initializePresenters [
	super initializePresenters.
	treePresenter := self newTree.
	treePresenter
		children: [ :node | node children ];
		display: [ :node | node treeLabel ].
	upButton := self newButton.
	upButton
		label: 'Up';
		action: [ self moveSelectionUp ].
	downButton := self newButton.
	downButton
		label: 'Down';
		action: [ self moveSelectionDown ].
	deleteButton := self newButton.
	deleteButton
		label: 'Delete';
		action: [ self deleteSelection ].
	refreshButton := self newButton.
	refreshButton
		label: 'Refresh';
		action: [ self refresh ].
	kindList := self newDropList.
	kindList
		items: DdLayoutEditor containerKinds;
		display: [ :each | each value ].
	kindList selectIndex: 1.
	addContainerButton := self newButton.
	addContainerButton
		label: 'Add';
		action: [ self addContainerToSelection ].
	wrapButton := self newButton.
	wrapButton
		label: 'Wrap';
		action: [ self wrapSelection ].
	treePresenter whenSelectionChangedDo: [ :selection |
		self selectionChanged ].
	self updateButtons
]

{ #category : 'initialization' }
DdComponentTreePresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: 'Component tree';
		initialExtent: 320 @ 420
]

{ #category : 'actions' }
DdComponentTreePresenter >> moveNodeAt: aSourcePath into: aContainerPath at: anIndex [
"Moves the node at aSourcePath into the container at aContainerPath (position anIndex among its
children once the node has been taken out) and selects it at its new place."

	| node |
	node := rootNode ifNotNil: [ :root |
			        [ root nodeAtPath: aSourcePath ]
				        on: Error
				        do: [ nil ] ].
	node ifNil: [
		^ self notifyUser: 'The tree is out of date - press Refresh' ].
	self editNode: node with: [ :editor :path |
			editor moveAt: path toBoxAt: aContainerPath index: anIndex.
			DdLayoutEditor movedPathFor: path into: aContainerPath at: anIndex ]
]

{ #category : 'actions' }
DdComponentTreePresenter >> moveSelectionDown [
	self editSelection: [ :editor :path |
			editor moveDownAt: path.
			path allButLast , { (path last + 1) } ]
]

{ #category : 'actions' }
DdComponentTreePresenter >> moveSelectionUp [
	self editSelection: [ :editor :path |
			editor moveUpAt: path.
			path allButLast , { (path last - 1) } ]
]

{ #category : 'accessing' }
DdComponentTreePresenter >> notifier: aOneArgBlock [
	"Receives the text of messages meant for the user. Default: a dialog."

	notifier := aOneArgBlock
]

{ #category : 'private' }
DdComponentTreePresenter >> notifyUser: aString [
	notifier ifNil: [ ^ self inform: aString ].
	notifier value: aString
]

{ #category : 'accessing' }
DdComponentTreePresenter >> presenterClass: aClass [
	presenterClass := aClass.
	self refresh
]

{ #category : 'actions' }
DdComponentTreePresenter >> refresh [
"Re-reads defaultLayout of the edited class and rebuilds the tree."

	presenterClass ifNil: [ ^ self ].
	self showModelFrom: (DdLayoutEditor forClass: presenterClass)
]

{ #category : 'accessing' }
DdComponentTreePresenter >> rootNode [

	^ rootNode
]

{ #category : 'actions' }
DdComponentTreePresenter >> selectContainerKind: aKey [
	kindList selectItem:
		(DdLayoutEditor containerKinds detect: [ :each | each key = aKey ])
]

{ #category : 'actions' }
DdComponentTreePresenter >> selectNodeAtPath: aPath [
	"aPath is relative to the root node; the tree's own path starts with the index among roots."

	treePresenter selectPath: #( 1 ) , aPath
]

{ #category : 'actions' }
DdComponentTreePresenter >> selectedContainerKind [
	^ kindList selectedItem ifNotNil: [ :each | each key ]
]

{ #category : 'accessing' }
DdComponentTreePresenter >> selectedNode [
	^ treePresenter selectedItem
]

{ #category : 'private' }
DdComponentTreePresenter >> selectionChanged [
	self updateButtons.
	selectionAction ifNotNil: [ :action |
		action value: treePresenter selectedItem ]
]

{ #category : 'actions' }
DdComponentTreePresenter >> showModelFrom: anEditor [
"Rebuilds the tree from anEditor's own current model, without re-reading and re-parsing the
edited class - used right after an edit whose editor we already know matches what was just
compiled, so re-parsing the class from scratch would just redo work already done."

	rootNode := anEditor root.
	treePresenter roots:
		(rootNode ifNil: [ #(  ) ] ifNotNil: [ :r | { r } ]).
	treePresenter expandAll.
	self updateButtons
]

{ #category : 'accessing' }
DdComponentTreePresenter >> treePresenter [
	^ treePresenter
]

{ #category : 'accessing' }
DdComponentTreePresenter >> upButton [
	^ upButton
]

{ #category : 'private' }
DdComponentTreePresenter >> updateButtons [
	| node |
	node := treePresenter selectedItem.
	upButton enabled: (node notNil and: [ node canMoveUp ]).
	downButton enabled: (node notNil and: [ node canMoveDown ]).
	deleteButton enabled: (node notNil and: [ node canDelete ]).
	addContainerButton enabled: rootNode notNil.
	wrapButton enabled: (node notNil and: [ node canDelete ])
]

{ #category : 'accessing' }
DdComponentTreePresenter >> whenLayoutChangedDo: aBlock [
	"Called after the edited class has been recompiled by an action of this tree."

	changeAction := aBlock
]

{ #category : 'accessing' }
DdComponentTreePresenter >> whenNodeSelectedDo: aOneArgBlock [	
	"Called with the selected node, or nil when the selection is cleared."

	selectionAction := aOneArgBlock
]

{ #category : 'accessing' }
DdComponentTreePresenter >> wrapButton [
	^ wrapButton
]

{ #category : 'actions' }
DdComponentTreePresenter >> wrapSelection [
"Wraps the selected node in a new container of the chosen kind."

	| kind |
	kind := self selectedContainerKind.
	kind ifNil: [ ^ self ].
	self editSelection: [ :editor :path | editor wrapAt: path in: kind ]
]
