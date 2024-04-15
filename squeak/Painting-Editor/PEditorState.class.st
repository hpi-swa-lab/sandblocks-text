Class {
	#name : #PEditorState,
	#superclass : #Morph,
	#instVars : [
		'sourceString',
		'rootShard',
		'shards',
		'node'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:39'
}
PEditorState >> applyChanges: aCollection [

	| newSourceString oldTree newTree pair |
	newSourceString := aCollection
		inject: self sourceString
		into: [:new :change | change applyTo: new].
	oldTree := node.
	newTree := PNode parse: newSourceString old: oldTree language: oldTree language.
	oldTree allBaseChildrenDo: [:m | m clearDiffCache].
	
	pair := PTrueDiff new compare: oldTree to: newTree.
	
	node := pair first.
	node privateSource: newTree sourceString.
	
	self shards do: [:shard | shard applyChanges: aCollection editScript: pair second].
	
	self basicSourceString: newSourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:51'
}
PEditorState >> basicSourceString: aString [

	sourceString := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:44'
}
PEditorState >> initialize [

	super initialize.
	
	shards := Set new.
	rootShard := PShard new editor: self
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 07:52'
}
PEditorState >> range [

	^ 0 to: self sourceString size
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
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 07:52'
}
PEditorState >> shards [

	^ shards
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:47'
}
PEditorState >> sourceString [

	^ sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:42'
}
PEditorState >> sourceString: aString [

	self basicSourceString: aString.
	
	node := PNode parse: aString language: SBJavascript.
	rootShard nodes: {node}.
	
	self applyChanges: {PChange range: self range insert: aString}
]
