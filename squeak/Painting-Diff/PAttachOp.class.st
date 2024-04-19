Class {
	#name : #PAttachOp,
	#superclass : #PNodeOp,
	#instVars : [
		'parent',
		'node',
		'index',
		'oldParent',
		'oldIndex'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:57'
}
PAttachOp >> applyFor: aScript [

	oldParent := node baseParent.
	oldIndex := oldParent ifNotNil: [node baseSiblingIndex].
	
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
	#'squeak_changestamp' : 'tobe 4/16/2024 08:56'
}
PAttachOp >> undo [

	oldParent
		ifNotNil: [oldParent addBaseChild: node at: oldIndex]
		ifNil: [node baseRemoveFromParent]
]
