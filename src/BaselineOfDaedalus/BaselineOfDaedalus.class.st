Class {
	#name : 'BaselineOfDaedalus',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDaedalus',
	#package : 'BaselineOfDaedalus'
}

{ #category : 'baselines' }
BaselineOfDaedalus >> baseline: spec [ 
	<baseline>
	spec for: #common do: [
		spec
			baseline: 'SpecComponentsLibrary'
			with: [ spec repository: 'github://Olesia32/pharo-spec-components/src' ].
 
		spec
			package: 'Daedalus-AbsoluteLayout';
			package: 'Daedalus'
			with: [ spec requires: #( 'SpecComponentsLibrary' 'Daedalus-AbsoluteLayout' ) ].
 
		spec postLoadDoIt: #patchSpNullApplication ]
]

{ #category : 'as yet unclassified' }
BaselineOfDaedalus >> patchSpNullApplication [ 
 
	(SpNullApplication classVarNames includes: #SkipReset) ifFalse: [
		(RBAddClassVariableRefactoring
			 variable: 'SkipReset'
			 class: SpNullApplication) execute ].
 
	(SpNullApplication class includesSelector: #skipReset:) ifFalse: [
		SpNullApplication class
			compile: 'skipReset: aBoolean
	SkipReset := aBoolean'
			classified: 'accessing' ].
 
	(SpNullApplication class includesSelector: #skipReset) ifFalse: [
		SpNullApplication class
			compile: 'skipReset
	^ SkipReset ifNil: [ false ]'
			classified: 'accessing' ].

	((SpNullApplication class sourceCodeAt: #reset ifAbsent: [ '' ])
		 includesSubstring: 'skipReset') ifFalse: [
		SpNullApplication class
			compile: 'reset
	<script>
	self skipReset ifTrue: [
		DefaultApplication := nil.
		^ self ].
	DefaultApplication ifNotNil: [ DefaultApplication reset ].
	DefaultApplication := nil'
			classified: ((SpNullApplication class includesSelector: #reset)
					 ifTrue: [ (SpNullApplication class >> #reset) protocolName ]
					 ifFalse: [ 'instance creation' ]) ]
]
