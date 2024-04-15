Class {
	#name : #PReplacementPluggable,
	#superclass : #PReplacement,
	#instVars : [
		'init',
		'update',
		'didInit'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:32'
}
PReplacementPluggable >> init: aBlock update: anotherBlock [

	init := aBlock.
	update := anotherBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:41'
}
PReplacementPluggable >> initialize [

	super initialize.
	
	didInit := false
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:42'
}
PReplacementPluggable >> node: aNode [

	super node: aNode.
	
	didInit ifFalse: [
		init valueWithEnoughArguments: {aNode. self}.
		didInit := true].
	update valueWithEnoughArguments: {aNode. self}
]
