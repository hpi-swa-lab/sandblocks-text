Class {
	#name : #PEditScript,
	#superclass : #Object,
	#instVars : [
		'posBuf',
		'negBuf',
		'revertRanges'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:48'
}
PEditScript >> apply [

	negBuf do: [:b | b applyFor: self].
	posBuf do: [:b | b applyFor: self]
]

{
	#category : #operations,
	#'squeak_changestamp' : 'tobe 4/13/2024 13:43'
}
PEditScript >> attach: aNode to: aParentNode at: aNumber [

	self assert: aNode ~~ aParentNode.
	self assert: aNumber >= 1.
	posBuf add: (PAttachOp new node: aNode parent: aParentNode index: aNumber).
	self logChanges: {#attach. aNode. aParentNode. aNumber}
]

{
	#category : #operations,
	#'squeak_changestamp' : 'tobe 4/13/2024 13:43'
}
PEditScript >> detach: aNode [

	negBuf add: (PDetachOp new node: aNode).
	self logChanges: {#detach. aNode}
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:57'
}
PEditScript >> initPos: aCollection neg: anotherCollection [

	posBuf := aCollection.
	negBuf := anotherCollection
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:05'
}
PEditScript >> initialize [

	super initialize.
	
	posBuf := OrderedCollection new.
	negBuf := OrderedCollection new.
	
	revertRanges := OrderedCollection new
]

{
	#category : #operations,
	#'squeak_changestamp' : 'tobe 4/13/2024 13:45'
}
PEditScript >> load: aNode [

	posBuf add: (PLoadOp new node: aNode).
	self logChanges: {#load. aNode}
]

{ #category : #'as yet unclassified' }
PEditScript >> logChanges: aCollection [

	false ifTrue: [Transcript showln: aCollection]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:34'
}
PEditScript >> negBuf [

	^ negBuf
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:34'
}
PEditScript >> posBuf [

	^ posBuf
]

{
	#category : #operations,
	#'squeak_changestamp' : 'tobe 4/13/2024 13:44'
}
PEditScript >> remove: aNode [

	negBuf add: (PRemoveOp new node: aNode).
	self logChanges: {#remove. aNode}
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/14/2024 10:08'
}
PEditScript >> removeDo: aBlock [

	negBuf do: [:op | op class = PRemoveOp ifTrue: [aBlock value: op]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:05'
}
PEditScript >> undo [

	posBuf reverseDo: #undo.
	negBuf reverseDo: #undo.
	revertRanges do: [:pair | pair key range: pair value]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:05'
}
PEditScript >> update: aNode range: aRange [

	revertRanges add: aNode -> aNode range.
	aNode range: aRange
]

{
	#category : #operations,
	#'squeak_changestamp' : 'tobe 4/13/2024 13:46'
}
PEditScript >> update: aNode to: aString [

	posBuf add: (PUpdateOp new node: aNode text: aString).
	self logChanges: {#update. aNode. aString}
]
