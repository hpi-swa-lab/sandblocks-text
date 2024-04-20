Class {
	#name : #PMarkerDefinition,
	#superclass : #Object,
	#instVars : [
		'query',
		'name',
		'attach',
		'detach',
		'model'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:46'
}
PMarkerDefinition >> attach [

	^ attach
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:49'
}
PMarkerDefinition >> attach: aBlock [

	attach := aBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:46'
}
PMarkerDefinition >> detach [

	^ detach
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:50'
}
PMarkerDefinition >> detach: aBlock [

	detach := aBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:33'
}
PMarkerDefinition >> model [

	^ model
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:34'
}
PMarkerDefinition >> model: aClass [

	model := aClass
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:40'
}
PMarkerDefinition >> name [

	^ name
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:40'
}
PMarkerDefinition >> name: aString [

	name := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:39'
}
PMarkerDefinition >> query [

	^ query
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 09:39'
}
PMarkerDefinition >> query: aQuery [

	query := aQuery
]

{
	#category : #utils,
	#'squeak_changestamp' : 'tobe 4/17/2024 11:49'
}
PMarkerDefinition >> style: anAttribute [

	self
		attach: [:shard :node | shard styleAdd: anAttribute for: node definition: self];
		detach: [:shard :node :data | shard styleRemove: data]
]
