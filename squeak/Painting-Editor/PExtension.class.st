Class {
	#name : #PExtension,
	#superclass : #Object,
	#instVars : [
		'replacementDefinitions'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:11'
}
PExtension >> initialize [

	super initialize.
	
	replacementDefinitions := OrderedCollection new
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:11'
}
PExtension >> registerReplacement: aReplacement [

	replacementDefinitions add: aReplacement
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:11'
}
PExtension >> replacementDefinitions [

	^ replacementDefinitions
]
