Class {
	#name : #PExtension,
	#superclass : #Object,
	#instVars : [
		'replacementDefinitions',
		'markerDefinitions',
		'requiredModels'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:56'
}
PExtension >> initialize [

	super initialize.
	
	replacementDefinitions := OrderedCollection new.
	markerDefinitions := OrderedCollection new.
	requiredModels := OrderedCollection new
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:45'
}
PExtension >> markerDefinitions [

	^ markerDefinitions
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:37'
}
PExtension >> registerMarker: aMarker [

	markerDefinitions add: aMarker
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

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:56'
}
PExtension >> requireModel: aLanguage [

	requiredModels add: aLanguage
]
