Class {
	#name : #PDetachOp,
	#superclass : #PNodeOp,
	#instVars : [
		'node',
		'oldParent',
		'oldIndex'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:30'
}
PDetachOp >> applyFor: aScript [

	oldParent := node baseParent.
	oldIndex := node baseSiblingIndex.
	node baseRemoveFromParent
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:40'
}
PDetachOp >> node: aNode [

	node := aNode
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:41'
}
PDetachOp >> undo [

	oldParent addBaseChild: node at: oldIndex
]
