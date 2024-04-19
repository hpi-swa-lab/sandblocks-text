Class {
	#name : #PEditorState,
	#superclass : #Morph,
	#instVars : [
		'sourceString',
		'rootShard',
		'shards',
		'node',
		'validationBlocks',
		'pendingChanges',
		'pendingChangesRevert'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:30'
}
PEditorState >> adjustIndex: aNumber forChangeList: aCollection sideAffinity: anotherNumber [

	^ self
		adjustIndex: aNumber
		forChangeList: aCollection
		upTo: aCollection size
		sideAffinity: anotherNumber
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:32'
}
PEditorState >> adjustIndex: aNumber forChangeList: aCollection upTo: anotherNumber sideAffinity: aThirdNumber [

	| index |
	index := aNumber.
	aCollection
		from: 1
		to: anotherNumber
		do: [:change | (((change sideAffinity = aThirdNumber or: [aThirdNumber = 0]) and: [index >= change from]) or: [change sideAffinity ~= aThirdNumber and: [index > change from]]) ifTrue: [index := index + ((change insert ifNil: ['']) size - ((index clampLow: change from high: change to) - change from))]].
	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:31'
}
PEditorState >> adjustRange: aRange [

	^ SBTSRange
		indexStart: (self adjustIndex: aRange first forChangeList: self pendingChanges sideAffinity: 1)
		end: (self adjustIndex: aRange last forChangeList: self pendingChanges sideAffinity: -1)
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:35'
}
PEditorState >> applyChanges: aCollection [

	self applyChanges: aCollection force: false
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/19/2024 18:14'
}
PEditorState >> applyChanges: aCollection force: aBoolean [

	| newSourceString oldTree newTree pair script oldSourceString |
	newSourceString := aCollection, pendingChanges
		inject: self sourceString
		into: [:new :change | change applyTo: new].
	oldSourceString := node sourceString.
	oldTree := node.
	newTree := "PNode parse: newSourceString old: oldTree language: oldTree language"PWhitespaceParser parse: newSourceString old: oldTree.
	oldTree allBaseChildrenDo: [:m | m clearDiffCache].
	
	pair := PTrueDiff new compare: oldTree to: newTree.
	
	node := pair first.
	script := pair second.
	node privateSource: newSourceString.
	
	aBoolean ifFalse: [
		validationBlocks do: [:b |
			(b value: pair first value: aCollection value: pair second) ifFalse: [
				script undo.
				node := oldTree.
				node privateSource: oldSourceString.
				pendingChanges addAll: aCollection.
				pendingChangesRevert addAll: (aCollection collect: [:change |
					PChange
						range: (change from to: change from + change insert size)
						insert: (self sourceString copyFrom: change from + 1 to: change to)]).
				self shards do: [:shard | shard applyRejectedChanges: aCollection].
				^ false]]].
	
	pendingChanges := OrderedCollection new.
	self basicSourceString: newSourceString.
	
	self shards do: [:shard | shard applyChanges: aCollection editScript: pair second].
	
	^ true
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:45'
}
PEditorState >> applyPendingChanges [

	self applyChanges: {} force: true
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/12/2024 10:51'
}
PEditorState >> basicSourceString: aString [

	sourceString := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:45'
}
PEditorState >> initialize [

	super initialize.
	
	shards := Set new.
	rootShard := PShard new editor: self.
	validationBlocks := OrderedCollection new.
	pendingChanges := OrderedCollection new.
	pendingChangesRevert := OrderedCollection new
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 15:48'
}
PEditorState >> pendingChanges [

	^ pendingChanges
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:22'
}
PEditorState >> range [

	^ SBTSRange indexStart: 0 end: self sourceString size
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:27'
}
PEditorState >> registerValidation: aBlock [

	validationBlocks add: aBlock.
	^ [validationBlocks remove: aBlock]
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/16/2024 06:57'
}
PEditorState >> revertPendingChanges [

	pendingChanges := OrderedCollection new.
	self shards do: [:shard |
		shard updateText
		"shard basicApplyChanges: pendingChangesRevert editScript: nil"]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 07:56'
}
PEditorState >> rootShard [

	
	^ rootShard
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 08:12'
}
PEditorState >> selectionRange [

	^ 0 to: 0
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 07:52'
}
PEditorState >> shards [

	^ shards
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/12/2024 10:47'
}
PEditorState >> sourceString [

	^ sourceString
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/19/2024 18:31'
}
PEditorState >> sourceString: aString [

	self basicSourceString: aString.
	
	node := PBaseParser parse: aString old: nil.
	rootShard nodes: {node}.
	
	self applyChanges: {PChange range: self range insert: aString} force: true
]
