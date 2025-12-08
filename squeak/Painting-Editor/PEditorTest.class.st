Class {
	#name : #PEditorTest,
	#superclass : #TestCase,
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 08:22'
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:40'
}
PEditorTest >> testApplyChangeInReplacement [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:40'
}
PEditorTest >> testApplyChangeInReplacementRemovesIt [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 08:23'
}
PEditorTest >> testApplyRejectedChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false] for: PBaseParser.
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:40'
}
PEditorTest >> testBackspaceIntoReplacementCharacter [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		deletionInteraction: #character;
		name: 'test';
		model: PSmalltalkParser;
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testEmbeddedShard [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		model: PSmalltalkParser;
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testEnterChangeAtStart [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
		query: {[:x | x type = #number]}).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '123'.
	
	e rootShard onChange: 'a', Character startOfHeader asString.
	self assert: 'a123' equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 9/26/2024 13:23'
}
PEditorTest >> testFindChange [

	| change |
	change := PShard new findChange: 'ab' b: 'acb' preferredPos: 1 preferredSide: nil.
	self assert: ({#from -> 2. #to -> 2. #insert -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 9/26/2024 13:23'
}
PEditorTest >> testFindChangeAtEnd [

	| change |
	change := PShard new findChange: 'ab' b: 'abc' preferredPos: 1 preferredSide: nil.
	self assert: ({#from -> 3. #to -> 3. #insert -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 9/26/2024 13:23'
}
PEditorTest >> testFindChangeDelete [

	| change |
	change := PShard new findChange: 'acb' b: 'ab' preferredPos: 1 preferredSide: nil.
	self assert: ({#from -> 2. #to -> 3. #delete -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 9/26/2024 13:23'
}
PEditorTest >> testFindChangeDeleteAtEnd [

	| change |
	change := PShard new findChange: 'abc' b: 'ab' preferredPos: 1 preferredSide: nil.
	self assert: ({#from -> 3. #to -> 4. #delete -> 'c'} as: Dictionary) equals: change
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testMarker [

	| e testExt attr |
	attr := TextColor red.
	testExt := PExtension new registerMarker: (PMarkerDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testMultipleReplacements [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testOverlappingReplacements [

	| e testExt |
	testExt := PExtension new
		registerReplacement: (PReplacementDefinition new
			name: 'test';
			model: PSmalltalkParser;
			query: {[:x | x type = #number]});
		registerReplacement: (PReplacementDefinition new
			name: 'test2';
			model: PSmalltalkParser;
			query: {[:x | x type = #array]}).
	
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: 1 equals: e rootShard replacements size.
	self assert: Character startOfHeader asString equals: e rootShard view text string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 08:24'
}
PEditorTest >> testRejectChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false] for: PBaseParser.
	e sourceString: '123'.
	
	e applyChanges: {PChange range: (0 to: 0) insert: 'a'}.
	self assert: 'a123' equals: e rootShard view text string.
	self assert: '123' equals: e sourceString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testRejectChangeAndEdit [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
	e registerValidation: [:node :changes :script | false] for: PBaseParser.
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	e applyChanges: {(PChange range: (3 to: 3) insert: '3') sideAffinity: -1}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	self assert: 1 equals: e rootShard replacements size.
	self assert: 3 equals: e shards size.
	self
		assert: {'123'. '123'}
		equals: ((e shards reject: [:s | s = e rootShard]) collect: [:s | s view text string] as: Array)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testRejectResetsIndizes [

	| e |
	e := PEditorState new.
	e models at: PSmalltalkParser put: nil.
	e registerValidation: [:node :changes :script | false] for: PBaseParser.
	e sourceString: '12'.
	
	e applyChanges: {PChange range: (2 to: 2) insert: '3'}.
	self
		assert: (PRange indexStart: 0 end: 2)
		equals: (e models at: PSmalltalkParser) baseChildren first baseChildren first range
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testRejectedChangeAffinity [

	| e testExt nestedShard |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
		query: {[:x | x type = #number]. [:x | x parent type = #array]};
		init: [:node :replacement | replacement addMorphBack: (replacement setProperty: #s1 toValue: replacement createShard)]
			update: [:node :replacement | (replacement valueOfProperty: #s1) nodes: {node}]).
	
	e := PEditorState new.
	e registerValidation: [:node :changes :script | false] for: PBaseParser.
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testRejectedChangesIndex [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
	e registerValidation: [:node :changes :script | false] for: PBaseParser.
	e rootShard extensions: [{testExt}].
	e sourceString: '[12]'.
	
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	
	e applyChanges: {PChange range: (1 to: 1) insert: '3'}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	self
		assert: {'312'. '312'}
		equals: ((e shards reject: [:s | s = e rootShard]) collect: [:s | s view text string] as: Array).
	
	e applyChanges: {(PChange range: (4 to: 4) insert: '4') sideAffinity: -1}.
	self assert: '[', Character startOfHeader, ']' equals: e rootShard view text string.
	self
		assert: {'3124'. '3124'}
		equals: ((e shards reject: [:s | s = e rootShard]) collect: [:s | s view text string] as: Array)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testRemoveIndent [

	| removeIndentExt testExt e |
	removeIndentExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'indent';
		model: PWhitespaceParser;
		query: {[:x | x type = #tab and: [x childBefore type = #newline]]};
		init: [:node :replacement | replacement extent: 0 @ 0] update: [:node :replacement | ]).
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
		query: {[:x | x type = #program]};
		init: [:node :replacement | replacement addMorphBack: (replacement createShard extensions: [{removeIndentExt}])]
			update: [:node :replacement | replacement firstSubmorph nodes: {node queryFirst: '(method_definition) @'}]).
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: 'class A {
	constructor() {
		console.log("b");
	}
}'
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 08:27'
}
PEditorTest >> testRevertRejectedChange [

	| e |
	e := PEditorState new.
	e registerValidation: [:root :change :diff | false] for: PBaseParser.
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
	#'squeak_changestamp' : 'tobe 12/8/2025 20:41'
}
PEditorTest >> testToggleReplacement [

	| e testExt |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
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
