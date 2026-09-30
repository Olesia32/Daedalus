Class {
	#name : 'DdDesignerTheme',
	#superclass : 'Object',
	#category : 'Daedalus-Daedalus-UI',
	#package : 'Daedalus',
	#tag : 'Daedalus-UI'
}

{ #category : 'colors' }
DdDesignerTheme class >> accent [
"#7354C7 - violet."

	^ Color r: 0.45 g: 0.33 b: 0.78
]

{ #category : 'colors' }
DdDesignerTheme class >> accentSoft [
"Translucent accent for filled areas (drop target) that must not hide what is underneath."

	^ self accent alpha: 0.18
]

{ #category : 'colors' }
DdDesignerTheme class >> drop [
"#1F9E8A - teal."

	^ Color r: 0.12 g: 0.62 b: 0.54
]

{ #category : 'colors' }
DdDesignerTheme class >> dropSoft [

	^ self drop alpha: 0.2
]

{ #category : 'colors' }
DdDesignerTheme class >> ink [
"#2B3039 - almost black with a cool tint."

	^ Color r: 0.17 g: 0.19 b: 0.23
]

{ #category : 'colors' }
DdDesignerTheme class >> onAccent [

	^ Color white
]

{ #category : 'colors' }
DdDesignerTheme class >> outline [

	^ (Color r: 0.35 g: 0.38 b: 0.45) alpha: 0.4
]

{ #category : 'colors' }
DdDesignerTheme class >> selection [
"#5473DB - soft indigo."

	^ Color r: 0.33 g: 0.45 b: 0.86
]

{ #category : 'colors' }
DdDesignerTheme class >> selectionSoft [
"Translucent selection color for filled drop targets (empty container, grid cell)."

	^ self selection alpha: 0.18
]
