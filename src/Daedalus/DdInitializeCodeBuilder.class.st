Class {
	#name : 'DdInitializeCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'presenterClass',
		'propertiesList'
	],
	#category : 'Daedalus-Daedalus-Services',
	#package : 'Daedalus',
	#tag : 'Daedalus-Services'
}

{ #category : 'as yet unclassified' }
DdInitializeCodeBuilder >> factoryMethodFor: props [ 
    (props isKindOf: DdLabelProperties) ifTrue: [ ^ 'newLabel' ].
    ^ 'new' "fallback"
]

{ #category : 'translating' }
DdInitializeCodeBuilder >> generate [ 
    | existingSource |
    existingSource := presenterClass 
        sourceCodeAt: #initializePresenters 
        ifAbsent: [ ^ self generateFresh ].
    ^ self patchSource: existingSource
]

{ #category : 'as yet unclassified' }
DdInitializeCodeBuilder >> generateFresh [ 
    | stream props |
    stream := WriteStream on: String new.
    stream nextPutAll: 'initializePresenters'; cr.
    stream tab; nextPutAll: 'super initializePresenters.'; cr.
    propertiesList do: [ :p |
        stream tab; nextPutAll: p varName; nextPutAll: ' := self newLabel.'; cr.
        stream tab; nextPutAll: p varName; nextPutAll: ' label: '; print: p label; nextPutAll: '.'; cr.
    ].
    ^ stream contents
]

{ #category : 'translating' }
DdInitializeCodeBuilder >> patchSource: source [ 
    | ast props targetVarName newValue assignNode |

    props := propertiesList first.
    targetVarName := props varName.
    newValue := props label.

    ast := RBParser parseMethod: source.

    assignNode := ast body statements 
        detect: [ :stmt |
            stmt isMessage
                and: [ stmt receiver isVariable
                and: [ stmt receiver name = targetVarName
                and: [ stmt selector = #label: ] ] ] ]
        ifNone: [ nil ].

    assignNode 
        ifNotNil: [
            assignNode arguments first replaceWith: 
                (RBLiteralValueNode value: newValue) ]
        ifNil: [
            | initNode newNode |
            initNode := ast body statements
                detect: [ :stmt |
                    stmt isAssignment
                        and: [ stmt variable name = targetVarName ] ]
                ifNone: [ nil ].

            initNode ifNil: [ ^ ast formattedCode ].

            newNode := RBParser parseExpression: 
                targetVarName , ' label: ' , newValue printString.
            ast body addNode: newNode after: initNode ].

    ^ ast formattedCode
]

{ #category : 'as yet unclassified' }
DdInitializeCodeBuilder >> presenterClass: aClass properties: aCollection [ 
    presenterClass := aClass.
    propertiesList := aCollection.
]
