"
I represent a label: message sent to a presenter. I am used for widgets that display text via label: such as buttons, labels and checkboxes.

### Hierarchy
`Object`
`DdPresenterProperties`
`DdTextProperties` (this is me)

### Instance Variables
- _text_: `String` — the label text to set on the presenter
"
Class {
	#name : 'DdTextProperties',
	#superclass : 'DdPresenterProperties',
	#instVars : [
		'text'
	],
	#category : 'Daedalus-Daedalus-DataModel',
	#package : 'Daedalus',
	#tag : 'Daedalus-DataModel'
}

{ #category : 'operations' }
DdTextProperties >> applyTo: aPresenter [ 
    aPresenter label: text
]

{ #category : 'translating' }
DdTextProperties >> patchSource: anAst [
"Finds an existing varName label: call in anAst and replaces its string argument with text; inserts a new label: call after the
assignment node if none is found."

    | assignNode |
    assignNode := anAst body statements
        detect: [ :stmt |
            stmt isMessage
                and: [ stmt receiver isVariable
                and: [ stmt receiver name = varName
                and: [ stmt selector = #label: ] ] ] ]
        ifNone: [ nil ].

    assignNode
        ifNotNil: [
            assignNode arguments first replaceWith:
                (RBLiteralValueNode value: text) ]
        ifNil: [
            | initNode newNode |
            initNode := anAst body statements
                detect: [ :stmt |
                    stmt isAssignment
                        and: [ stmt variable name = varName ] ]
                ifNone: [ nil ].
            initNode ifNil: [ ^ anAst ].
            newNode := RBParser parseExpression:
                varName , ' label: ' , text printString.
            anAst body addNode: newNode after: initNode ].

    ^ anAst
]

{ #category : 'accessing' }
DdTextProperties >> text [

	^ text
]

{ #category : 'accessing' }
DdTextProperties >> text: anObject [

	text := anObject
]
