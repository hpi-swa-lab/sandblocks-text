Class {
	#name : #PReplacementDefinition,
	#superclass : #Object,
	#instVars : [
		'name',
		'query',
		'selectionInteraction',
		'deletionInteraction',
		'replacementClass',
		'buildReplacement',
		'model'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:25'
}
PReplacementDefinition >> buildReplacement [

	^ (buildReplacement ifNil: [[PReplacement new]]) value
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:22'
}
PReplacementDefinition >> buildReplacement: aBlock [

	buildReplacement := aBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:08'
}
PReplacementDefinition >> deletionInteraction [

	^ deletionInteraction
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:08'
}
PReplacementDefinition >> deletionInteraction: aSymbol [

	deletionInteraction := aSymbol
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:40'
}
PReplacementDefinition >> init: aBlock update: anotherBlock [

	self buildReplacement: [PReplacementPluggable new init: aBlock update: anotherBlock]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:09'
}
PReplacementDefinition >> initialize [

	super initialize.
	
	selectionInteraction := #skip.
	deletionInteraction := #character
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:34'
}
PReplacementDefinition >> model [

	^ model
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:03'
}
PReplacementDefinition >> model: aModel [

	model := aModel
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:10'
}
PReplacementDefinition >> name [

	^ name
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:10'
}
PReplacementDefinition >> name: aString [

	name := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:10'
}
PReplacementDefinition >> query [

	^ query
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:10'
}
PReplacementDefinition >> query: aQuery [

	query := aQuery
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:08'
}
PReplacementDefinition >> selectionInteraction: aSymbol [

	selectionInteraction := aSymbol
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:08'
}
PReplacementDefinition >> selectionInteractive [

	^ selectionInteraction
]
