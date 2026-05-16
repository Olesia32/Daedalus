Class {
	#name : 'DaedalusApplication',
	#superclass : 'SpApplication',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'running' }
DaedalusApplication class >> runOn: aPresenterClass [

	| designer |
	designer := DdDesignerPresenter onPresenter: aPresenterClass.
	designer open.
   designer withWindowDo: [ :w | w title: 'Daedalus — ' , aPresenterClass name ].
	Processor yield.
	(designer instVarNamed: #workArea) installClickHooks
]
