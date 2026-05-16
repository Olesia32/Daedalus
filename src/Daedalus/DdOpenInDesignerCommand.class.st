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

	| class |
	class := Smalltalk at: aContext selectedClassItems first browserItem name ifAbsent: [ nil ].
	class ifNil: [ ^ false ].
	^ class inheritsFrom: SpPresenter
]

{ #category : 'accessing' }
DdOpenInDesignerCommand class >> defaultMenuIconName [

	^ #daedalusIcon
]

{ #category : 'accessing' }
DdOpenInDesignerCommand class >> defaultMenuItemName [ 
    ^ 'Open in Daedalus'
]

{ #category : 'execution' }
DdOpenInDesignerCommand >> execute [ 
    DaedalusApplication runOn: targetClass
]

{ #category : 'execution' }
DdOpenInDesignerCommand >> readParametersFromContext: aContext [

	targetClass := Smalltalk at: aContext selectedClassItems first browserItem name ifAbsent: [ nil ].
]
