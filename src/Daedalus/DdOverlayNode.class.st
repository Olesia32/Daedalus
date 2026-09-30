Class {
	#name : 'DdOverlayNode',
	#superclass : 'DdBoxNode',
	#category : 'Daedalus-Daedalus-LayoutModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-LayoutModel'
}

{ #category : 'constraints' }
DdOverlayNode >> addMessageFor: aChild values: aDictionary [

	| argument parts |
	argument := aChild addMessage arguments first.
	parts := OrderedCollection new.
	parts addAll: (#( #hAlign #vAlign ) reject: [ :key |
				 | value |
				 value := aDictionary at: key.
				 value = #none ]).
	parts isEmpty ifTrue: [
			^ OCMessageNode
				  receiver: (OCVariableNode named: 'layout')
				  selector: #addOverlay:
				  arguments: { argument } ].
	^ OCMessageNode
		  receiver: (OCVariableNode named: 'layout')
		  selector: #addOverlay:withConstraints:
		  arguments: {
				  argument.
				  (DdLayoutNode blockSource: parts) }
]

{ #category : 'resizing' }
DdOverlayNode >> childResizeHandles [
"Overlays are placed by alignment, not by size - nothing to drag yet."

	^ #(  )
]

{ #category : 'constraints' }
DdOverlayNode >> constraintPropertiesFor: aChild [
"Only overlays are aligned; the main child fills the whole layout."

	aChild addSelector = #child: ifTrue: [ ^ #(  ) ].
	^ {
		  (DdConstraintProperty
			   key: #hAlign
			   label: 'Horizontal align'
			   choices: #( #none #start #center #end )
			   default: #none).
		  (DdConstraintProperty
			   key: #vAlign
			   label: 'Vertical align'
			   choices: #( #none #start #center #end )
			   default: #none) }
]

{ #category : 'constraints' }
DdOverlayNode >> constraintValuesOf: aChild [

	| values message |
	values := Dictionary new.
	values
		at: #hAlign put: #none;
		at: #vAlign put: #none.
	message := aChild addMessage.
	message selector = #child: ifTrue: [ ^ Dictionary new ].
	message selector = #addOverlay: ifTrue: [ ^ values ].
	message selector = #addOverlay:withConstraints: ifFalse: [ ^ nil ].
	(DdLayoutNode blockMessagesOf: message arguments second)
		ifNil: [ ^ nil ]
		ifNotNil: [ :messages |
				messages do: [ :each |
						| name |
						name := each selector asString.
						((name beginsWith: 'hAlign') or: [ name beginsWith: 'vAlign' ])
							ifFalse: [ ^ nil ].
						(#( 'Start' 'Center' 'End' ) includes: (name allButFirst: 6))
							ifFalse: [ ^ nil ].
						values
							at: (name first: 6) asSymbol
							put: (name allButFirst: 6) asLowercase asSymbol ] ].
	^ values
]

{ #category : 'testing' }
DdOverlayNode >> hasMainChild [

	^ children anySatisfy: [ :each | each addSelector = #child: ]
]

{ #category : 'testing' }
DdOverlayNode >> isChildMessage: aMessage [

	^ #( #child: #addOverlay: #addOverlay:withConstraints: ) includes:
		  aMessage selector
]

{ #category : 'labels' }
DdOverlayNode >> kindLabel [

	^ 'Overlay'
]

{ #category : 'properties' }
DdOverlayNode >> layoutProperties [

	^ #(  )
]

{ #category : 'editing' }
DdOverlayNode >> newAddMessageFor: aNode [
"The first child becomes the main one (child:), every other one an overlay on top of it.
An overlay that already has constraints keeps them."

	self hasMainChild ifFalse: [
			^ OCMessageNode
				  receiver: cascade receiver copy
				  selector: #child:
				  arguments: { aNode addMessage arguments first } ].
	(#( #addOverlay: #addOverlay:withConstraints: ) includes:
		 aNode addSelector) ifTrue: [
			^ OCMessageNode
				  receiver: cascade receiver copy
				  selector: aNode addSelector
				  arguments: aNode addMessage arguments asArray ].
	^ OCMessageNode
		  receiver: cascade receiver copy
		  selector: #addOverlay:
		  arguments: { aNode addMessage arguments first }
]

{ #category : 'printing' }
DdOverlayNode >> printOn: aStream [

	aStream nextPutAll: 'Overlay'.
	propertyMessages do: [ :m |
			aStream
				space;
				nextPutAll: m selector ]
]
