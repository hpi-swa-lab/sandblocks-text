Class {
	#name : #PReplacement,
	#superclass : #Morph,
	#instVars : [
		'definition',
		'node',
		'editor'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:21'
}
PReplacement class >> build [

	^ self new
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:25'
}
PReplacement >> beforeUninstall [

	
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:50'
}
PReplacement >> createShard [

	self assert: self editor notNil.
	^ PShard new editor: self editor
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:23'
}
PReplacement >> definition [

	^ definition
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:17'
}
PReplacement >> definition: aDefinition [

	definition := aDefinition
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:49'
}
PReplacement >> editor [

	^ editor
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:49'
}
PReplacement >> editor: anEditor [

	editor := anEditor
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:02'
}
PReplacement >> initialize [

	super initialize.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:47'
}
PReplacement >> localIndex: aNumber in: aShard [

	| index |
	index := aNumber.
	aShard replacements do: [:replacement |
		(self ~= replacement and: [replacement range first <= index]) ifTrue: [" subtract the replaced range but add 1 for the startOfHeader character "
		index := index - replacement range size + 1]].
	index := index - aShard range first.
	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:26'
}
PReplacement >> localRangeIn: aShard do: aBlock [

	aBlock
		value: (self localIndex: self range first in: aShard) + 1
		value: (self localIndex: self range last in: aShard)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:30'
}
PReplacement >> node [

	^ node
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:30'
}
PReplacement >> node: aNode [

	node := aNode
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:01'
}
PReplacement >> range [

	^ self editor adjustRange: node range
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:06'
}
PReplacement >> sourceString [

	^ self node sourceString
]
