"
I represent a set of visual style properties (font, colors, borders, size) applied together to one presenter variable. I remove all
previously known style calls from the AST before inserting the new ones, ensuring a clean slate on every apply.

### Hierarchy
`Object`
`DdPresenterProperties`
`DdStyleProperties` (this is me)

### Instance Variables
- _properties_: `Dictionary` — maps style selector strings to their
  values; nil values denote unary selectors (bold, italic)
"
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
	"Removes all existing style calls for the known selectors from anAst, then inserts a fresh statement for each entry in properties."

	| toRemove |
	toRemove := anAst body statements select: [ :stmt |
			            stmt isMessage and: [
					            stmt receiver isVariable and: [
							            stmt receiver name = varName and: [
								            DdStyleProperties knownSelectors includes:
									            stmt selector ] ] ] ].
	toRemove do: [ :node | anAst body removeNode: node ].

	properties keysAndValuesDo: [ :selector :value |
			| newNode |
			newNode := (selector endsWith: ':')
				           ifTrue: [ "keyword message — потребує аргумент"
						           value ifNil: [ nil ] ifNotNil: [
								           RBParser parseExpression:
									           varName , ' ' , selector , ' ' , value printString ] ]
				           ifFalse: [ "unary message — без аргументу"
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
