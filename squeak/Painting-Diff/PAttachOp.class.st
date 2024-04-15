Class {
	#name : #PAttachOp,
	#superclass : #PNodeOp,
	#instVars : [
		'parent',
		'node',
		'index'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:39'
}
PAttachOp >> applyFor: aScript [

	parent addBaseChild: node at: index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:30'
}
PAttachOp >> index [

	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:30'
}
PAttachOp >> node [

	^ node
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:30'
}
PAttachOp >> node: aNode parent: aParent index: aNumber [

	node := aNode.
	parent := aParent.
	index := aNumber
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:30'
}
PAttachOp >> parent [

	^ parent
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:40'
}
PAttachOp >> undo [

	node delete
]
