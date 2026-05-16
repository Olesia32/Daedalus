"
I am the entry point of the Daedalus visual UI designer. My sole responsibility is to launch the designer window for a given
`SpPresenter` subclass, wire up the click-handling hooks, and give the window an appropriate title.

### Hierarchy
`SpApplication`
`DaedalusApplication` (this is me)

### Public API
- `DaedalusApplication class>>#runOn:` — creates and opens a designer window for the given presenter class, sets the
  window title, and installs mouse-click hooks on the canvas

### Usage
```smalltalk
DaedalusApplication runOn: MyFormPresenter.
"
Class {
	#name : 'DaedalusApplication',
	#superclass : 'SpApplication',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'running' }
DaedalusApplication class >> runOn: aPresenterClass [
	"Open a designer window for aPresenterClass, set its title, yield the processor so the window renders, then install click hooks on the 
	work area so the canvas can respond to widget selection."

	| designer |
	designer := DdDesignerPresenter onPresenter: aPresenterClass.
	designer open.
	designer withWindowDo: [ :w |
		w title: 'Daedalus — ' , aPresenterClass name ].
	Processor yield.
	(designer instVarNamed: #workArea) installClickHooks
]
