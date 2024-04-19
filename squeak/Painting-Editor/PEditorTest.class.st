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
	#'squeak_changestamp' : 'tobe 4/16/2024 06:57'
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
	#'squeak_changestamp' : 'tobe 4/17/2024 11:57'
}
PEditorTest >> testMarker [

	| e testExt attr |
	attr := TextColor red.
	testExt := PExtension new
		requireModel: SBJavascript;
		registerMarker: (PMarkerDefinition new
			name: 'test';
			query: {[:x | x type = #number]};
			style: attr).
	
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: 'a+12'.
	
	self assert: {attr} equals: (e rootShard view text attributesAt: 3).
	self assert: {attr} equals: (e rootShard view text attributesAt: 4)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:27'
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
	#'squeak_changestamp' : 'tobe 4/16/2024 08:22'
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
	#'squeak_changestamp' : 'tobe 4/17/2024 08:39'
}
PEditorTest >> testRejectChangeAndEdit [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		init: [:node :replacement | | s2 s1 |
				s1 := replacement setProperty: #s1 toValue: replacement createShard.
				s2 := replacement setProperty: #s2 toValue: replacement createShard.
				replacement addMorphBack: s1.
				replacement addMorphBack: s2]
			update: [:node :replacement |
				(replacement valueOfProperty: #s1) nodes: {node}.
				(replacement valueOfProperty: #s2) nodes: {node}]).
	
	e := PEditorState new.
	e registerValidation: [:node :changes :script | false].
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	e applyChanges: {(PChange range: (3 to: 3) insert: '3') sideAffinity: -1}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	self assert: 1 equals: e rootShard replacements size.
	self assert: 3 equals: e shards size.
	self assert: {'123'. '123'} equals: ((e shards reject: [:s | s = e rootShard])
		collect: [:s | s view text string]
		as: Array)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:22'
}
PEditorTest >> testRejectResetsIndizes [

	| e |
	e := PEditorState new.
	e registerValidation: [:node :changes :script | false].
	e sourceString: '12'.
	
	e applyChanges: {PChange range: (2 to: 2) insert: '3'}.
	self
		assert: (SBTSRange indexStart: 0 end: 2)
		equals: e rootShard nodes first baseChildren first baseChildren first range
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 08:38'
}
PEditorTest >> testRejectedChangeAffinity [

	| e testExt nestedShard |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		init: [:node :replacement | replacement addMorphBack: (replacement setProperty: #s1 toValue: replacement createShard)]
			update: [:node :replacement | (replacement valueOfProperty: #s1) nodes: {node}]).
	
	e := PEditorState new.
	e registerValidation: [:node :changes :script | false].
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	nestedShard := e shards detect: [:s | s ~= e rootShard].
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	nestedShard onChange: '123'.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	self assert: '123' equals: nestedShard view text string.
	
	e rootShard onChange: '[', Character startOfHeader, '4]'.
	self assert: '[', Character startOfHeader, '4]' equals: e rootShard view text string.
	self assert: '123' equals: nestedShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 08:28'
}
PEditorTest >> testRejectedChangesIndex [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		init: [:node :replacement | | s2 s1 |
				s1 := replacement setProperty: #s1 toValue: replacement createShard.
				s2 := replacement setProperty: #s2 toValue: replacement createShard.
				replacement addMorphBack: s1.
				replacement addMorphBack: s2]
			update: [:node :replacement |
				(replacement valueOfProperty: #s1) nodes: {node}.
				(replacement valueOfProperty: #s2) nodes: {node}]).
	
	e := PEditorState new.
	e registerValidation: [:node :changes :script | false].
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	e applyChanges: {PChange range: (1 to: 1) insert: '3'}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	self assert: {'312'. '312'} equals: ((e shards reject: [:s | s = e rootShard])
		collect: [:s | s view text string]
		as: Array).
	
	e applyChanges: {(PChange range: (4 to: 4) insert: '4') sideAffinity: -1}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	self assert: {'3124'. '3124'} equals: ((e shards reject: [:s | s = e rootShard])
		collect: [:s | s view text string]
		as: Array)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 06:58'
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
