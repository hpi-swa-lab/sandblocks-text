Class {
	#name : #PEditorTest,
	#superclass : #TestCase,
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:28'
}
PEditorTest >> testApplyChange [

	| e |
	e := PEditorState new.
	
	e sourceString: 'abc'.
	
	e applyChanges: {PChange range: (1 to: 1) insert: '1'}.
	self assert: 'a1bc' equals: e rootShard view text string.
	
	e applyChanges: {PChange range: (1 to: 1) insert: '2'}.
	self assert: 'a21bc' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:39'
}
PEditorTest >> testApplyChangeInReplacement [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	self assert: Character startOfHeader asString equals: e rootShard view text string.
	
	e applyChanges: {PChange range: (1 to: 1) insert: '4'}.
	self assert: Character startOfHeader asString equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:02'
}
PEditorTest >> testApplyChangeInReplacementRemovesIt [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:47'
}
PEditorTest >> testApplyRejectedChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false].
	e sourceString: '123'.
	
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string.
	self assert: '123' equals: e sourceString.
	
	e applyPendingChanges.
	self assert: 'a123' equals: e rootShard view text string.
	self assert: 'a123' equals: e sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:17'
}
PEditorTest >> testBackspaceIntoReplacementCharacter [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		deletionInteraction: #character;
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '12'.
	
	e rootShard onChange: ''.
	self assert: Character startOfHeader asString equals: e rootShard view text string.
	self assert: '1' equals: e sourceString.
	
	e rootShard onChange: ''.
	self assert: '' equals: e rootShard view text string.
	self assert: '' equals: e sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:01'
}
PEditorTest >> testEmbeddedShard [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		init: [:node :replacement | | s |
				s := replacement setProperty: #s toValue: replacement createShard.
				replacement addMorphBack: s]
			update: [:node :replacement | (replacement valueOfProperty: #s) nodes: {node}]).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:59'
}
PEditorTest >> testEnterChangeAtStart [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	
	e rootShard onChange: 'a', Character startOfHeader asString.
	self assert: 'a123' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:44'
}
PEditorTest >> testFindChange [

	| change |
	change := SBExampleWatch
		report: (PShard new findChange: 'ab' b: 'acb' preferredPos: 1 preferredSide: nil)
		for: 600362803
		modifying: [:each | each].
	self assert: ({#from -> 2. #to -> 2. #insert -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:44'
}
PEditorTest >> testFindChangeAtEnd [

	| change |
	change := SBExampleWatch
		report: (PShard new findChange: 'ab' b: 'abc' preferredPos: 1 preferredSide: nil)
		for: 600362803
		modifying: [:each | each].
	self assert: ({#from -> 3. #to -> 3. #insert -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:44'
}
PEditorTest >> testFindChangeDelete [

	| change |
	change := SBExampleWatch
		report: (PShard new findChange: 'acb' b: 'ab' preferredPos: 1 preferredSide: nil)
		for: 600362803
		modifying: [:each | each].
	self assert: ({#from -> 2. #to -> 3. #delete -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:44'
}
PEditorTest >> testFindChangeDeleteAtEnd [

	| change |
	change := SBExampleWatch
		report: (PShard new findChange: 'abc' b: 'ab' preferredPos: 1 preferredSide: nil)
		for: 600362803
		modifying: [:each | each].
	self assert: ({#from -> 3. #to -> 4. #delete -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:47'
}
PEditorTest >> testMultipleReplacements [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123+456'.
	self
		assert: Character startOfHeader asString, '+', Character startOfHeader asString
		equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:14'
}
PEditorTest >> testOverlappingReplacements [

	| e testExt |
	testExt := PExtension new
		registerReplacement: (PReplacementDefinition new
			name: 'test';
			query: {[:x | x type = #number]});
		registerReplacement: (PReplacementDefinition new
			name: 'test2';
			query: {[:x | x type = #array]}).
	
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: 1 equals: e rootShard replacements size.
	self assert: Character startOfHeader asString equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:55'
}
PEditorTest >> testRejectChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false].
	e sourceString: '123'.
	
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string.
	self assert: '123' equals: e sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:56'
}
PEditorTest >> testRevertRejectedChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false].
	e sourceString: '123'.
	
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string.
	self assert: '123' equals: e sourceString.
	
	e revertPendingChanges.
	self assert: '123' equals: e rootShard view text string.
	self assert: '123' equals: e sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:05'
}
PEditorTest >> testToggleReplacement [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	
	e rootShard onChange: 'a', Character startOfHeader asString.
	self assert: 'a123' equals: e rootShard view text string.
	
	e rootShard onChange: '123'.
	self assert: Character startOfHeader asString equals: e rootShard view text string.
	
	e rootShard onChange: 'a', Character startOfHeader asString.
	self assert: 'a123' equals: e rootShard view text string
]
