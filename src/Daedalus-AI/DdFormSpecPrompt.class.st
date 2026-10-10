Class {
	#name : 'DdFormSpecPrompt',
	#superclass : 'Object',
	#category : 'Daedalus-AI',
	#package : 'Daedalus-AI'
}

{ #category : 'prompt' }
DdFormSpecPrompt class >> copyablePromptFor: aRequest [
"Everything in one text, to paste into any chat assistant in a browser - the way to use the
feature without an API key. Its JSON answer goes back through the JSON import."

	^ self systemInstruction , String cr , String cr
	  , 'The form to describe: ' , aRequest
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> formatVersion [

	^ 1
]

{ #category : 'prompt' }
DdFormSpecPrompt class >> systemInstruction [
	"Kept in step with DdFormSpecLayoutBuilder: the same layouts, widget types, props and
	constraints. No apostrophes in it, so it needs no escaping."

	^ 'You generate UI form descriptions for a Pharo Spec2 visual designer. Reply with JSON only.
	Format: {"version": 1, "root": NODE}. The root is always a container.
	NODE is either a container or a widget.
	Container: {"layout": "box" | "grid" | "paned", "name": ID, "children": [NODE, ...]}.
	A box has "direction": "vertical" | "horizontal" and optional "spacing": number.
	A paned has "direction": "horizontal" (left and right) | "vertical" (top and bottom) and exactly 2 children.
	Widget: {"widget": TYPE, "name": ID, "props": {...}}.
	Props per widget type (use only these):
	label: text. button: label. checkbox: label, checked. textInput: text, placeholder, password (boolean).
	textArea: text. list, comboBox: items. radioGroup, checkboxGroup: items, selected (1-based index).
	slider: label, min, max, value. progressBar: value. datePicker, timePicker: no props.
	Put a caption for a group or input into a separate label widget placed before it.
	Any node may have "constraints", which depend on the PARENT layout: inside a vertical box use height and expand, inside a horizontal box use width and expand,
	inside a grid use "position": [column, row] starting at 1 and optional "span": [columns, rows]. Children of a paned take no constraints.
	Use height or width only when the user asks for sizes. Use expand true only for widgets that should grow, such as lists and text areas, and expand false for rows
	that should keep their natural size.
	ID: meaningful English camelCase derived from the content, unique, starting with a lowercase letter, e.g. readingCheckBox, emailInput.'
]
