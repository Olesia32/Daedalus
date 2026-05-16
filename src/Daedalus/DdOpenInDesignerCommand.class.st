"
I am a Calypso browser command that adds an ""Open in Daedalus"" context menu entry to any class that inherits from `SpPresenter`.
When executed I launch the designer for the selected class.

### Hierarchy
`CmdCommand`
`DdOpenInDesignerCommand` (this is me)

### Instance Variables
- _targetClass_: `Class` — the presenter class selected in the browser
"
Class {
	#name : 'DdOpenInDesignerCommand',
	#superclass : 'CmdCommand',
	#instVars : [
		'targetClass'
	],
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'activation' }
DdOpenInDesignerCommand class >> browserMenuActivation [

	<classAnnotation>
	^ CmdContextMenuActivation
		  for: ClyFullBrowserClassContext
]

{ #category : 'execution' }
DdOpenInDesignerCommand class >> canBeExecutedInContext: aContext [
"Returns true if the selected class inherits from SpPresenter, controlling menu item visibility."

	| class |
	class := Smalltalk at: aContext selectedClassItems first browserItem name ifAbsent: [ nil ].
	class ifNil: [ ^ false ].
	^ class inheritsFrom: SpPresenter
]

{ #category : 'accessing' }
DdOpenInDesignerCommand class >> defaultMenuIconName [

	^ #editThiner
]

{ #category : 'accessing' }
DdOpenInDesignerCommand class >> defaultMenuItemName [ 
    ^ 'Open in Daedalus'
]

{ #category : 'execution' }
DdOpenInDesignerCommand >> execute [ 
"Launches the designer for targetClass via DaedalusApplication."

    DaedalusApplication runOn: targetClass
]

{ #category : 'execution' }
DdOpenInDesignerCommand >> readParametersFromContext: aContext [
"Reads the selected class from aContext and stores it as targetClass."

	targetClass := Smalltalk at: aContext selectedClassItems first browserItem name ifAbsent: [ nil ].
]
