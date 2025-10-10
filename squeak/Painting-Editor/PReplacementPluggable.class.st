Class {
	#name : #PReplacementPluggable,
	#superclass : #PReplacement,
	#instVars : [
		'init',
		'update',
		'didInit',
		'delete'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:26'
}
PReplacementPluggable >> beforeUninstall [

	delete valueWithEnoughArguments: {node. self}
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:25'
}
PReplacementPluggable >> init: aBlock update: anotherBlock [

	self init: aBlock update: anotherBlock delete: []
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:25'
}
PReplacementPluggable >> init: aBlock update: anotherBlock delete: aThirdBlock [

	init := aBlock.
	update := anotherBlock.
	delete := aThirdBlock
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
