Class {
	#name : #PRemoveOp,
	#superclass : #PNodeOp,
	#instVars : [
		'node'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/14/2024 10:15'
}
PRemoveOp >> node [

	^ node
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:44'
}
PRemoveOp >> node: aNode [

	node := aNode
]
