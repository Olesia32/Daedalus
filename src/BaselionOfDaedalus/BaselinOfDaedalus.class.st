Class {
	#name : 'BaselinOfDaedalus',
	#superclass : 'BaselineOf',
	#category : 'BaselionOfDaedalus',
	#package : 'BaselionOfDaedalus'
}

{ #category : 'baselines' }
BaselinOfDaedalus >> baseline: spec [ 
    <baseline>
    spec for: #common do: [
        spec package: 'Daedalus'.
        spec postLoadDoIt: #patchSpNullApplication ]
]

{ #category : 'as yet unclassified' }
BaselinOfDaedalus >> patchSpNullApplication [ 
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
