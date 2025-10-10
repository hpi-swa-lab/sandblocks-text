Class {
	#name : #PSubtreeShare,
	#superclass : #Object,
	#instVars : [
		'availableTrees',
		'preferredTrees'
	],
	#category : #'Painting-Diff'
}

{ #category : #'as yet unclassified' }
PSubtreeShare >> availableTrees [

	^ availableTrees
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> deregisterAvailableTree: aNode subtreeReg: aRegistry [

	aNode share
		ifNotNil: [
			aNode share availableTrees removeKey: aNode uri.
			aNode share: nil.
			aNode baseChildren do: [:t | self deregisterAvailableTree: t subtreeReg: aRegistry]]
		ifNil: [
			aNode assigned ifNotNil: [ | that |
				that := aNode assigned.
				aNode unassignTree.
				that allBaseChildrenDo: [:t | aRegistry assignShare: t]]]
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> hasPreferredTrees [

	^ preferredTrees notNil
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> initialize [

	preferredTrees := nil.
	availableTrees := Dictionary new
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> preferredTrees [

	^ preferredTrees ifNil: [
		preferredTrees := Dictionary new.
		availableTrees do: [:t | preferredTrees at: t literalHash put: t]]
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> registerAvailableTree: aNode [

	availableTrees at: aNode uri put: aNode.
	preferredTrees ifNotNil: [self halt.preferredTrees at: aNode literalHash put: aNode]
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> takeAvailableTree: that preferred: aBoolean subtreeReg: aRegistry [

	^ (aBoolean
		ifTrue: [self preferredTrees at: that literalHash ifAbsent: [nil]]
		ifFalse: [availableTrees ifNotEmpty: #anyOne ifEmpty: [nil]]) ifNotNil: [:node | self takeTree: node that: that subtreeReg: aRegistry]
]

{ #category : #'as yet unclassified' }
PSubtreeShare >> takeTree: aNode that: anotherNode subtreeReg: aRegistry [

	aNode share availableTrees removeKey: aNode uri.
	aNode share hasPreferredTrees ifTrue: [aNode share preferredTrees removeKey: aNode literalHash ifAbsent: []].
	aNode share: nil.
	aNode baseChildren do: [:t | self deregisterAvailableTree: t subtreeReg: aRegistry].
	anotherNode allBaseChildrenExceptSelfDo: [:thatNode |
		thatNode assigned ifNotNil: [ | thisNode |
			thisNode := thatNode assigned.
			aRegistry assignShareAndRegisterTree: thisNode]].
	^ aNode
]
