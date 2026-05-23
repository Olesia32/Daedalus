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
        spec baseline: 'SpecComponentsLibrary'
            with: [ spec repository: 'github://Olesia32/pharo-spec-components/src' ].
        
        spec package: 'Daedalus'
            with: [ spec requires: #('SpecComponentsLibrary') ].
        
        spec postLoadDoIt: #patchSpNullApplication ]
]

{ #category : 'as yet unclassified' }
BaselineOfDaedalus >> patchSpNullApplication [ 
    (SpNullApplication class includesSelector: #skipReset:) ifFalse: [
        SpNullApplication class compile: 
'skipReset: aBoolean
    skipReset := aBoolean'
            classified: 'accessing' ].
    
    (SpNullApplication class includesSelector: #skipReset) ifFalse: [
        SpNullApplication class compile:
'skipReset
    ^ skipReset ifNil: [ false ]'
            classified: 'accessing' ]
]
