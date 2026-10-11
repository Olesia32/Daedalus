Class {
	#name : 'BaselineOfDaedalusAI',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDaedalusAI',
	#package : 'BaselineOfDaedalusAI'
}

{ #category : 'repository' }
BaselineOfDaedalusAI class >> daedalusRepository [
"Where BaselineOfDaedalus is - replace with the real one."

	^ 'github://OWNER/REPO:main/src'
]

{ #category : 'baselines' }
BaselineOfDaedalusAI >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				baseline: 'Daedalus'
				with: [ spec repository: 'github://Olesia32/Daedalus/src' ].
			spec
				package: 'Daedalus-AI'
				with: [ spec requires: #( 'Daedalus' ) ] ]
]
