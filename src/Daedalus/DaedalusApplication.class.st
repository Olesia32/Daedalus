Class {
	#name : 'DaedalusApplication',
	#superclass : 'SpApplication',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'running' }
DaedalusApplication class >> runOn: aPresenterClass [

	| app designer |
	app := self new.
	app initialize.
	designer := DdDesignerPresenter onPresenter: aPresenterClass.
	(self new: designer) open.
	Processor yield.
	(designer instVarNamed: #workArea) installClickHooks
]
