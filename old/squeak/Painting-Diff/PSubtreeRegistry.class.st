Class {
	#name : #PSubtreeRegistry,
	#superclass : #Object,
	#instVars : [
		'subtrees'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:30'
}
PSubtreeRegistry >> assignShare: aNode [

	| share |
	aNode assigned: nil.
	share := subtrees at: aNode structureHash ifAbsentPut: [PSubtreeShare new].
	aNode share: share.
	^ share
]

{ #category : #'as yet unclassified' }
PSubtreeRegistry >> assignShareAndRegisterTree: aNode [

	| share |
	share := self assignShare: aNode.
	share registerAvailableTree: aNode.
	^ share
]

{ #category : #'as yet unclassified' }
PSubtreeRegistry >> initialize [

	subtrees := Dictionary new
]
