"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestDaedalus',
	#superclass : 'PackageManifest',
	#category : 'Daedalus-Manifest',
	#package : 'Daedalus',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestDaedalus class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#'DdPropertyDescriptor class' #forPresenter: #true)) #'2026-05-17T12:13:21.811+03:00') #(#(#RGMethodDefinition #(#DdCanvasPresenter #ddOnMouseDown: #false)) #'2026-05-17T18:50:35.496+03:00') #(#(#RGPackageDefinition #(#Daedalus)) #'2026-05-18T01:43:02.335+03:00') )
]

{ #category : 'code-critics' }
ManifestDaedalus class >> ruleEmptyExceptionHandlerRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#DdLabelPropertyDescriptor #addSpecificFieldsTo:for: #false)) #'2026-05-17T12:49:04.284+03:00') #(#(#RGMethodDefinition #(#DdCheckboxGroupPropertyDescriptor #rebuildSelectionCheckboxes #false)) #'2026-05-17T14:32:56.327+03:00') )
]
