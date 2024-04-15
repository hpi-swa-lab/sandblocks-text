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
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:35'
}
PEditorState >> applyChanges: aCollection [

	self applyChanges: aCollection force: false
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:56'
}
PEditorState >> applyChanges: aCollection force: aBoolean [

	| newSourceString oldTree newTree pair script |
	newSourceString := aCollection, pendingChanges
		inject: self sourceString
		into: [:new :change | change applyTo: new].
	oldTree := node.
	newTree := PNode parse: newSourceString old: oldTree language: oldTree language.
	oldTree allBaseChildrenDo: [:m | m clearDiffCache].
	
	pair := PTrueDiff new compare: oldTree to: newTree.
	
	node := pair first.
	script := pair second.
	node privateSource: newTree sourceString.
	
	aBoolean ifFalse: [
		validationBlocks do: [:b |
			(b value: pair first value: aCollection value: pair second) ifFalse: [
				script undo.
				node := oldTree.
				pendingChanges addAll: aCollection.
				pendingChangesRevert addAll: (aCollection collect: [:change |
					PChange
						range: (change from to: change from + change insert size)
						insert: (self sourceString copyFrom: change from + 1 to: change to)]).
				self shards do: [:shard | shard applyRejectedChanges: aCollection].
				^ false]]].
	
	self shards do: [:shard | shard applyChanges: aCollection editScript: pair second].
	
	pendingChanges := OrderedCollection new.
	self basicSourceString: newSourceString.
	
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
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 07:52'
}
PEditorState >> range [

	^ 0 to: self sourceString size
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
	#'squeak_changestamp' : 'tobe 4/15/2024 14:56'
}
PEditorState >> revertPendingChanges [

	self shards do: [:shard | shard basicApplyChanges: pendingChangesRevert editScript: nil]
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
	#'squeak_changestamp' : 'tobe 4/15/2024 14:35'
}
PEditorState >> sourceString: aString [

	self basicSourceString: aString.
	
	node := PNode parse: aString language: SBJavascript.
	rootShard nodes: {node}.
	
	self applyChanges: {PChange range: self range insert: aString} force: true
]
