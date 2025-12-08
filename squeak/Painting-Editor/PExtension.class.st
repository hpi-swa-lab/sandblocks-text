Class {
	#name : #PExtension,
	#superclass : #Object,
	#instVars : [
		'replacementDefinitions',
		'markerDefinitions'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 20:43'
}
PExtension >> initialize [

	super initialize.
	
	replacementDefinitions := OrderedCollection new.
	markerDefinitions := OrderedCollection new
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
