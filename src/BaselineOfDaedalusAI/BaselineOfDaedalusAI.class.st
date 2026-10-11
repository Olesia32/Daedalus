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
				with: [ spec repository: self class daedalusRepository ].
			spec
				package: 'Daedalus-AI' with: [ spec requires: #( 'Daedalus' ) ];
				package: 'Daedalus-AI-Tests'
				with: [ spec requires: #( 'Daedalus-AI' ) ].
			spec
				group: 'Core' with: #( 'Daedalus-AI' );
				group: 'Tests' with: #( 'Daedalus-AI-Tests' );
				group: 'default' with: #( 'Core' 'Tests' ) ]
]
