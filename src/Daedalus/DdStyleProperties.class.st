Class {
	#name : 'DdStyleProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'properties'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'as yet unclassified' }
DdStyleProperties class >> knownSelectors [

	^ #( 'backgroundColor:' 'color:' 'borderColor:' 'borderWidth:'
	     'width:' 'height:' 'fontSize:' 'fontFamily:' 'bold' 'italic'
	     'hResizing:' 'vResizing:' )
]

{ #category : 'operations' }
DdStyleProperties >> applyTo: aPresenter [

	properties keysAndValuesDo: [ :selector :value |
			[
				value
					ifNil: [ aPresenter perform: selector asSymbol ]
					ifNotNil: [ aPresenter perform: selector asSymbol with: value ] ]
				on: Error
				do: [ ] ]
]

{ #category : 'accessing' }
DdStyleProperties >> at: aKey put: aValue [ 
    properties at: aKey put: aValue 
]

{ #category : 'initialization' }
DdStyleProperties >> initialize [ 
    super initialize.
    properties := Dictionary new 
]

{ #category : 'translating' }
DdStyleProperties >> patchSource: anAst [ 
    | toRemove |
    toRemove := anAst body statements select: [ :stmt |
        stmt isMessage
            and: [ stmt receiver isVariable
            and: [ stmt receiver name = varName
            and: [ DdStyleProperties knownSelectors includes: stmt selector ] ] ] ].
    toRemove do: [ :node | anAst body removeNode: node ].

    properties keysAndValuesDo: [ :selector :value |
        | newNode |
        newNode := (selector endsWith: ':')
            ifTrue: [
                "keyword message — потребує аргумент"
                value isNil ifTrue: [ nil ] ifFalse: [
                    RBParser parseExpression:
                        varName , ' ' , selector , ' ' , value printString ] ]
            ifFalse: [
                "unary message — без аргументу"
                RBParser parseExpression: varName , ' ' , selector ].
        newNode ifNotNil: [ anAst body addNode: newNode ] ].

    ^ anAst
]

{ #category : 'accessing' }
DdStyleProperties >> properties [

	^ properties
]

{ #category : 'accessing' }
DdStyleProperties >> properties: anObject [

	properties := anObject
]
