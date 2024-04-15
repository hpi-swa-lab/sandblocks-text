Class {
	#name : #PUpdateOp,
	#superclass : #PNodeOp,
	#instVars : [
		'node',
		'text',
		'oldText'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:46'
}
PUpdateOp >> applyFor: aScript [

	oldText := node contents.
	node contents: text
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:46'
}
PUpdateOp >> node: aNode text: aString [

	node := aNode.
	text := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:46'
}
PUpdateOp >> undo [

	node contents: oldText
]
