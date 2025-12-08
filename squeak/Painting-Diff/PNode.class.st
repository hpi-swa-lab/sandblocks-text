Class {
	#name : #PNode,
	#superclass : #Object,
	#instVars : [
		'type',
		'language',
		'range',
		'highlight',
		'field',
		'baseChildren',
		'baseParent',
		'tsTree',
		'tsSource',
		'treeHash',
		'treeSize',
		'treeHeight',
		'structureHash',
		'assigned',
		'share',
		'literalHash',
		'literalMatch'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'parsing - tree-sitter',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PNode class >> addUncapturedTextTo: aNode in: aCursor language: aLanguage isLeaf: aBoolean [

	| text start |
	text := aCursor textToNext.
	start := aCursor position.
	text isolateLineBreaks do: [:part |
		part isEmpty ifFalse: [
			part = String cr
				ifTrue: [aNode baseAndMorphAdd: (PText new contents: String cr; range: (PRange start: start size: 1))]
				ifFalse: [
					aNode baseAndMorphAdd: (PText new
						contents: part;
						range: (PRange start: start size: part size))]].
		start := start + part size].
	aCursor advance: text size.
	
	aBoolean ifTrue: [
		text := aCursor uncapturedText.
		aNode baseAndMorphAdd: (PText new
			contents: text;
			range: aCursor range)]
]

{ #category : #'parsing - tree-sitter' }
PNode class >> findChangeRangeFrom: original to: new [

	| start end maxSize |
	start := 1.
	[start <= (original size min: new size) and: [(original at: start) = (new at: start)]] whileTrue: [start := start + 1].
	
	end := 1.
	maxSize := original size min: new size.
	[end <= maxSize and: [maxSize - (end - 1) >= start and: [(original atLast: end) = (new atLast: end)]]] whileTrue: [end := end + 1].
	
	^ SBTSInputEdit new
		startByte: start - 1;
		oldEndByte: original size - (end - 1);
		newEndByte: new size - (end - 1);
		bytesToPointsIn: original new: new
]

{
	#category : #'parsing - tree-sitter',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PNode class >> fromCursor: aCursor language: aLanguage [

	^ aCursor isNamed
		ifTrue: [ | node |
			node := PNode new
				type: aCursor type;
				field: aCursor fieldName;
				language: aLanguage;
				range: aCursor range.
			
			aCursor gotoFirstChild
				ifTrue: [
					[
						self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: false.
						node baseAndMorphAdd: (self fromCursor: aCursor language: aLanguage)] doWhileFalse: [aCursor gotoNextSibling].
					self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: false.
					aCursor gotoParent]
				ifFalse: [self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: true].
			node]
		ifFalse: [
			PText new
				contents: aCursor text;
				field: aCursor fieldName;
				range: aCursor range]
]

{ #category : #'parsing - tree-sitter' }
PNode class >> language: aLanguage [

	^ self parse: '' language: aLanguage
]

{
	#category : #'parsing - tree-sitter',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PNode class >> maybeAddTrailingLineBreak: aBlock [

	| last |
	last := aBlock lastDeepBaseChild.
	aBlock baseAndMorphAdd: (PText new contents: String cr; range: (PRange start: last range end end: last range end + 1)).
	^ aBlock
]

{
	#category : #'parsing - tree-sitter',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:24'
}
PNode class >> parse: aString language: aLanguage [

	^ self parseBlock: aString language: aLanguage
]

{
	#category : #'parsing - tree-sitter',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:25'
}
PNode class >> parse: aString old: oldBlock language: aLanguage [

	| api oldTree |
	api := SBTreeSitter new.
	oldTree := oldBlock ifNotNil: [
		oldBlock privateTSTreeOrNilDo: [:tsTree |
			api treeEdit: tsTree edit: (self findChangeRangeFrom: oldBlock privateSource to: aString).
			tsTree]].
	
	^ self maybeAddTrailingLineBreak: (api parseAsCursor: aString language: aLanguage language oldTree: oldTree do: [:cursor :newTree |
		(self
			fromCursor: (SBTSCursorRaw new library: api cursor: cursor factory: aLanguage instance grammar)
			language: aLanguage)
			privateTSTree: newTree;
			privateSource: aString;
			yourself])
]

{ #category : #'parsing - tree-sitter' }
PNode class >> parseBlock: aString language: aLanguage [

	^ self parse: aString old: nil language: aLanguage
]

{
	#category : #'parsing - smalltalk',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:00'
}
PNode class >> parseSt: aString [

	| node parser |
	parser := Parser new.
	node := parser parse: aString class: Object.
	^ node accept: (PSmalltalkParser new
		encoder: parser encoder;
		source: aString)
]

{
	#category : #'text modify',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:43'
}
PNode class >> wrap: aRange in: aString open: anotherString close: aThirdString [

	self
		example: [PNode new]
		args: [{PRange start: 3 size: 3. 'abcdefghi'. '('. ')'}]
		label: 'example'.
	
	^ (aString first: aRange start index), anotherString, (aString copyFrom: aRange start index + 1 to: aRange end index), aThirdString, (aString allButFirst: aRange end index)
]

{ #category : #'as yet unclassified' }
PNode >> absolutePositionOf: aMorph [

	| n |
	n := 0.
	self allChildrenDo: [:m |
		n := n + 1.
		m = aMorph ifTrue: [^ n]].
	^ self assert: false
]

{ #category : #'as yet unclassified' }
PNode >> adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent [
	"do not place closing pair characters if they are coming up right after"

	| index |
	index := cursorIndex isNumber ifTrue: [cursorIndex] ifFalse: [cursorIndex start index].
	(self pairMap keyAtValue: input ifAbsent: nil) ifNotNil: [:openChar |
		(source at: index + 1 ifPresent: [:char | input first = char] ifAbsent: [false]) ifTrue: [
			self owner startInputAtSourceIndex: index + 1.
			^ '']].
	
	self pairMap at: input ifPresent: [:complete |
		"do not autocomplete quotes in words"
		(complete = '''' and: [source at: index ifPresent: #isAlphaNumeric ifAbsent: [false]]) ifTrue: [^ input].
		
		"do not autocomplete after backslash"
		(source at: index ifPresent: [:c | c = $\] ifAbsent: [false]) ifTrue: [^ input].
		
		^ input, complete].
	
	^ input
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:53'
}
PNode >> addBaseChild: aNode at: aNumber [

	aNode baseParent ifNotNil: [aNode baseRemoveFromParent].
	self baseChildren add: aNode beforeIndex: aNumber.
	aNode baseParent: self
]

{ #category : #'as yet unclassified' }
PNode >> alias [

	^ nil
]

{
	#category : #queries,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:14'
}
PNode >> all: aCollection [

	^ Array streamContents: [:s | self allBlocksDo: [:b | (PQuery script: aCollection with: b) ifNotNil: [:res | s nextPut: res]]]
]

{
	#category : #queries,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:14'
}
PNode >> all: aCollection do: aBlock [

	(self allBlocksSelect: [:b | (PQuery script: aCollection with: b) notNil]) do: aBlock
]

{ #category : #'base accessing' }
PNode >> allBaseChildrenDo: aBlock [

	self baseChildren do: [:c | c allBaseChildrenDo: aBlock].
	aBlock value: self
]

{ #category : #'base accessing' }
PNode >> allBaseChildrenExceptSelfDo: aBlock [

	self baseChildren do: [:c | c allBaseChildrenDo: aBlock]
]

{ #category : #'as yet unclassified' }
PNode >> allChildrenDetect: aBlock ifFound: aSuccessBlock ifNone: aFailBlock [

	self allChildrenDo: [:block | (aBlock value: block) ifTrue: [^ aSuccessBlock value: block]].
	^ aFailBlock value
]

{ #category : #hierarchy }
PNode >> allDomainBlocksWithDepthDo: aBlock leafDo: anotherBlock depth: aNumber [

	self submorphs do: [:m | m allDomainBlocksWithDepthDo: aBlock leafDo: anotherBlock depth: aNumber + 1].
	aBlock value: self value: aNumber
]

{ #category : #hierarchy }
PNode >> allParents [

	^ self allParentsUpTo: self rootBlock
]

{ #category : #hierarchy }
PNode >> allParentsUpTo: aBlock [

	| current parents |
	self = aBlock ifTrue: [^ #()].
	
	current := self parent.
	parents := OrderedCollection new.
	
	[
		parents add: current.
		current = aBlock ifTrue: [^ parents].
		current := current parent] repeat
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:10'
}
PNode >> allVisibleNodesDo: aBlock hidden: aCollection [

	(aCollection includes: self) ifFalse: [
		self baseChildren do: [:c | c allVisibleNodesDo: aBlock hidden: aCollection].
		aBlock value: self]
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:18'
}
PNode >> appendBaseChild: aNode [

	self addBaseChild: aNode at: self baseChildren size + 1
]

{ #category : #'as yet unclassified' }
PNode >> applyBlock [

	^ [:new :edit :undo | self applyEdit: edit source: new cursorAt: edit newEndByte undoDo: undo]
]

{ #category : #'as yet unclassified' }
PNode >> applyBlockWithCursor: aNumber [

	^ [:new :edit :undo | self applyEdit: edit source: new cursorAt: aNumber undoDo: undo]
]

{
	#category : #'query actions',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PNode >> assertConsecutiveRanges [

	| current |
	current := 0.
	self allMorphsDo: [:m |
		m class = PText ifTrue: [
			self assert: m range start index = current.
			current := m range end index].
		m isLineBreak ifTrue: [
			self assert: m range start index = current.
			current := m range end index]]
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:39'
}
PNode >> assigned [

	^ assigned
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:37'
}
PNode >> assigned: aBlock [

	(aBlock notNil and: [self treeLabel ~= aBlock treeLabel]) ifTrue: [self halt].
	assigned := aBlock
]

{ #category : #'as yet unclassified' }
PNode >> atField: aSymbol [

	^ self children detect: [:c | c field = aSymbol]
]

{ #category : #queries }
PNode >> atType: aSymbol [

	^ self children detect: [:c | c type = aSymbol]
]

{ #category : #'as yet unclassified' }
PNode >> atType: aSymbol ifPresent: aBlock ifAbsent: anotherBlock [

	^ self children detect: [:c | c type = aSymbol] ifFound: aBlock ifNone: anotherBlock
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:51'
}
PNode >> baseAndMorphAdd: aNode [

	self addBaseChild: aNode at: self baseChildren size + 1
]

{ #category : #'base accessing' }
PNode >> baseChildren [

	^ baseChildren
]

{ #category : #'base accessing' }
PNode >> baseChildren: aCollection [

	baseChildren := aCollection
]

{ #category : #'base accessing' }
PNode >> baseMorph [

	^ self replacedParent ifNotNil: [:p | p] ifNil: [self]
]

{ #category : #'base accessing' }
PNode >> baseParent [

	^ baseParent
]

{ #category : #'base accessing' }
PNode >> baseParent: aNode [

	baseParent := aNode
]

{ #category : #'base accessing' }
PNode >> baseRemoveFromParent [

	self baseParent baseChildren remove: self.
	self baseParent: nil
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:56'
}
PNode >> baseSiblingIndex [

	| i |
	self baseParent ifNil: [^ 0].
	
	i := 1.
	self baseParent baseChildren do: [:c |
		c = self ifTrue: [^ i].
		i := i + 1].
	^ 0
]

{ #category : #'base accessing' }
PNode >> baseTreeHeight [

	^ self baseChildren size = 0 ifTrue: [0] ifFalse: [ | max |
		max := 0.
		self baseChildren do: [:c | max := c baseTreeHeight max: max].
		max + 1]
]

{ #category : #'as yet unclassified' }
PNode >> blockFor: aRange [

	self allChildrenDo: [:block | (block isTSMorph and: [block range = aRange]) ifTrue: [^ block]].
	^ nil
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/21/2024 18:03'
}
PNode >> childBefore [

	^ self baseParent baseChildren
		at: self baseSiblingIndex - 1
		ifAbsent: [nil]
]

{ #category : #'as yet unclassified' }
PNode >> childNodes [

	^ self children reject: [:c | c isExtra]
]

{ #category : #'as yet unclassified' }
PNode >> childOfType: aSymbol [

	self childrenDo: [:c | c type = aSymbol ifTrue: [^ c]].
	^ nil
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:37'
}
PNode >> children [

	^ self baseChildren
]

{ #category : #'as yet unclassified' }
PNode >> childrenDo: aBlock [

	^ self baseChildren do: [:c |
		(c replacedParent notNil and: [c replacedParent showInQuery]) ifTrue: [aBlock value: c replacedParent] ifFalse: [aBlock value: c]]
]

{ #category : #'as yet unclassified' }
PNode >> childrenHaveErrors [

	^ self childNodes anySatisfy: [:c | c type = 'ERROR']
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:32'
}
PNode >> clearDiffCache [

	treeHash := nil.
	treeSize := nil.
	treeHeight := nil.
	structureHash := nil.
	literalMatch := nil.
	literalHash := nil
]

{ #category : #'as yet unclassified' }
PNode >> compatibleWithType: aSymbol [

	^ self type = aSymbol
]

{ #category : #'as yet unclassified' }
PNode >> contentsToDisplay [

	^ self contents
]

{ #category : #'as yet unclassified' }
PNode >> copyRangesFrom: newTree to: oldTree [

	oldTree range: newTree range.
	newTree children with: oldTree children do: [:a :b | self copyRangesFrom: a to: b]
]

{ #category : #'as yet unclassified' }
PNode >> encompasses: aRange [

	^ self range encompasses: aRange
]

{ #category : #'query actions' }
PNode >> ensureReplacement: aClass embed: aCollection initDo: aBlock [

	self queryState ensureReplacement: aClass for: self embed: aCollection initDo: aBlock
]

{ #category : #'query actions' }
PNode >> ensureReplacement: aClass initDo: aBlock [

	self queryState ensureReplacement: aClass for: self embed: [:m | {}] initDo: aBlock
]

{ #category : #'as yet unclassified' }
PNode >> field [

	^ field
]

{ #category : #'as yet unclassified' }
PNode >> field: aString [

	field := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:55'
}
PNode >> firstChildrenInRange: aRange do: aBlock [

	(aRange containsRange: self range)
		ifTrue: [aBlock value: self]
		ifFalse: [self baseChildren do: [:c | c firstChildrenInRange: aRange do: aBlock]]
]

{ #category : #'as yet unclassified' }
PNode >> firstSourceCharacter [

	self writeSourceOn: (SBImmediateStream with: [:c | ^ c]) indent: 0 forCompare: false.
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> fixedNumberOfChildren [

	^ false
]

{ #category : #'as yet unclassified' }
PNode >> generatedSourceString [

	^ String streamContents: [:s | self writeSourceOn: s indent: 0 forCompare: false]
]

{ #category : #'as yet unclassified' }
PNode >> getSourceStringAndMark [

	| stream |
	stream := SBLineInfoStream on: ''.
	self writeSourceOn: stream indent: 0 forCompare: false.
	^ stream contents
]

{ #category : #grammar }
PNode >> grammarRule [

	^ (self language grammarRule: self type) ifNil: [self resolveAlias: self type in: self owner grammarRule]
]

{ #category : #hierarchy }
PNode >> hasAnyParent: aBlock [

	| p |
	self isRootBlock ifTrue: [^ false].
	
	p := self parent.
	p ifNil: [
		self assert: self type = 'ERROR'.
		^ false].
	
	p = aBlock ifTrue: [^ true].
	
	^ p hasAnyParent: aBlock
]

{ #category : #hierarchy }
PNode >> hasParent: aCollectionOrSymbol [

	| matches |
	self isRootBlock ifTrue: [^ false].
	
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ matches includes: self parent type
]

{ #category : #'as yet unclassified' }
PNode >> highlight [

	^ highlight ifNil: [self updateAllHighlights]
]

{ #category : #'as yet unclassified' }
PNode >> highlight: aString [

	highlight := aString
]

{ #category : #'as yet unclassified' }
PNode >> indentFor: aBlock current: aNumber [

	^ (self language indentMatch: aBlock)
		ifTrue: [aNumber + 1]
		ifFalse: [aNumber]
]

{ #category : #'as yet unclassified' }
PNode >> infoForEditDo: aClosure [

	| oldCursorOffset oldSource |
	oldCursorOffset := self activeTextMorph ifNotNil: #cursor.
	oldSource := self rootBlock privateSource.
	
	aClosure valueWithEnoughArguments: {
		oldSource.
		self activeTextMorph ifNil: [self].
		self activeTextMorph
			ifNotNil: [self activeTextMorph range start index + (oldCursorOffset - 1)]
			ifNil: [self range]}
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:56'
}
PNode >> initOperations [

	^ {PLoadOp new node: self. PAttachOp new node: self parent: self baseParent index: self baseSiblingIndex}, (self baseChildren gather: #initOperations)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:51'
}
PNode >> initialize [

	super initialize.
	
	range := PRange null.
	baseParent := nil.
	baseChildren := OrderedCollection new: 1
]

{ #category : #hierarchy }
PNode >> is: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ matches includes: self type
]

{ #category : #testing }
PNode >> isExtra [

	^ false
]

{ #category : #'as yet unclassified' }
PNode >> isLeafIdentifier [

	^ self contents anySatisfy: [:c | c isLetter]
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:37'
}
PNode >> isLiterallyEqual: aNode [

	^ self literalHash = aNode literalHash
]

{ #category : #hierarchy }
PNode >> isOrHasParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ (matches includes: self type) or: [matches includes: self parent type]
]

{ #category : #'as yet unclassified' }
PNode >> isPart [

	^ self highlight notNil and: [self highlight endsWith: '.part']
]

{ #category : #'as yet unclassified' }
PNode >> isReplacement [

	^ false
]

{ #category : #'as yet unclassified' }
PNode >> isRootBlock [

	^ self type = (self language ifNotNil: #rootRuleName)
]

{ #category : #'as yet unclassified' }
PNode >> language [

	^ language ifNil: [self owner ifNotNil: #language]
]

{ #category : #'as yet unclassified' }
PNode >> language: aLanguage [

	language := aLanguage
]

{ #category : #'base accessing' }
PNode >> lastDeepBaseChild [

	| current |
	current := self.
	[current baseChildren isEmpty] whileFalse: [current := current baseChildren last].
	^ current
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:38'
}
PNode >> lastDeepChild [

	^ self children ifNotEmpty: [:c | c last lastDeepChild] ifEmpty: [self]
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:38'
}
PNode >> literalHash [

	^ literalHash
		ifNil: [literalHash := self baseChildren inject: 0 into: [:compound :node | compound + node literalHash]]
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:39'
}
PNode >> literalMatch [

	^ literalMatch
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:38'
}
PNode >> literalMatch: aBoolean [

	literalMatch := aBoolean
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PNode >> match: aRule with: aStream do: aBlock [

	^ aRule type caseOf: {
		['STRING'] -> [
			aRule value = aStream peek contents
				ifTrue: [
					aBlock value: aStream next value: aRule.
					true]
				ifFalse: [false]].
		['TOKEN'] -> [
			" TODO match contents"
			aStream peek class = PText
				ifTrue: [
					aBlock value: aStream next value: aRule.
					true]
				ifFalse: [false]].
		['IMMEDIATE_TOKEN'] -> [
			" TODO match contents"
			aStream peek class = PText
				ifTrue: [
					aBlock value: aStream next value: aRule.
					true]
				ifFalse: [false]].
		['PATTERN'] -> [
			" TODO match contents"
			aStream peek class = PText
				ifTrue: [
					aBlock value: aStream next value: aRule.
					true]
				ifFalse: [false]].
		['SYMBOL'] -> [
			(self language ruleIsInlined: aRule name)
				ifTrue: [
					self
						match: ((self language grammarRule: aRule name) ifNil: ["TODO external symbols"
						JsonObject fromAssociations: {'type' -> 'BLANK'}])
						with: aStream
						do: aBlock]
				ifFalse: [
					(self language supertype: aRule name includes: aStream peek type)
						ifTrue: [
							aBlock value: aStream next value: aRule.
							true]
						ifFalse: [false]]].
		['ALIAS'] -> [
			(self language supertype: aRule value includes: aStream peek type)
				ifTrue: [
					aBlock value: aStream next value: aRule.
					true]
				ifFalse: [false]].
		['SEQ'] -> [aRule members allSatisfy: [:childRule | self match: childRule with: aStream do: aBlock]].
		['PREC_LEFT'] -> [self match: aRule content with: aStream do: aBlock].
		['PREC_RIGHT'] -> [self match: aRule content with: aStream do: aBlock].
		['PREC'] -> [self match: aRule content with: aStream do: aBlock].
		['PREC_DYNAMIC'] -> [self match: aRule content with: aStream do: aBlock].
		['FIELD'] -> [self match: aRule content with: aStream do: aBlock].
		['CHOICE'] -> [
			aRule members
				detect: [:childRule | self match: childRule with: aStream copy do: [:child :rule | ]]
				ifFound: [:childRule | self match: childRule with: aStream do: aBlock]
				ifNone: [false]].
		['BLANK'] -> [true].
		['REPEAT'] -> [
			[aStream atEnd not and: [self match: aRule content with: aStream do: aBlock]] whileTrue.
			true].
		['REPEAT1'] -> [
			(self match: aRule content with: aStream do: aBlock)
				ifTrue: [
					[aStream atEnd not and: [self match: aRule content with: aStream do: aBlock]] whileTrue.
					true]
				ifFalse: [false]]}
]

{ #category : #'as yet unclassified' }
PNode >> maybeAddSeparator: input textMorph: aTextMorph [

	self language statementTerminator ifNil: [^ input].
	(aTextMorph isLineBreak and: [input ~= self language statementTerminator]) ifTrue: [^ input, self language statementTerminator].
	^ input
]

{ #category : #'as yet unclassified' }
PNode >> minBoundsWith: info [

	self submorphs do: [:morph | info measure: morph].
	^ info bounds
]

{ #category : #'as yet unclassified' }
PNode >> namedChildren [

	^ self children select: [:c | c type notEmpty]
]

{ #category : #'as yet unclassified' }
PNode >> nonExtraChildrenBounds [

	| box |
	self submorphs do: [:m | m isExtra ifFalse: [box ifNil: [box := m fullBounds copy] ifNotNil: [box := box quickMerge: m fullBounds]]].
	box ifNil: [^ self bounds].
	^ box
]

{ #category : #hierarchy }
PNode >> orAllParents: aCollectionOrSymbol [

	| matches current res |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	
	current := self.
	res := OrderedCollection new.
	[
		(matches includes: current type) ifTrue: [res add: current].
		current isRootBlock ifTrue: [^ res].
		current := current parent] repeat
]

{ #category : #hierarchy }
PNode >> orAnyParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isString
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	(matches includes: self type) ifTrue: [^ self].
	self parent ifNil: [^ nil].
	self isRootBlock ifTrue: [^ nil].
	self parent isTSMorph ifFalse: [^ nil].
	^ self parent orAnyParent: aCollectionOrSymbol
]

{ #category : #hierarchy }
PNode >> orParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	(matches includes: self type) ifTrue: [^ self].
	self isRootBlock ifTrue: [^ nil].
	(matches includes: self parent type) ifTrue: [^ self parent].
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> orParentExpression [

	| current |
	current := self.
	[current notNil] whileTrue: [
		current isExpression ifTrue: [^ current].
		current isRootBlock ifTrue: [^ nil].
		current := current parent].
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> pairMap [

	^ Dictionary newFrom: {'(' -> ')'. '''' -> ''''. '"' -> '"'. '`' -> '`'. '{' -> '}'. '[' -> ']'}
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'tobe 4/15/2024 11:25'
}
PNode >> parent [

	^ self baseParent
]

{ #category : #'as yet unclassified' }
PNode >> parentNode [

	^ self parentSandblock ifNotNil: [:p | p isTSBlock ifTrue: [p] ifFalse: [nil]]
]

{ #category : #'as yet unclassified' }
PNode >> prettyPrint [

	self infoForEditDo: [:source :textMorph :index | | new |
		new := [
			PPFormatter
				formatString: source
				class: (self containingArtefact ifNotNil: #relatedClass ifNil: [nil class])
				noPattern: false]
			on: SyntaxErrorNotification
			do: [source].
		source = new ifFalse: [
			self restoreCursorAfter: [
				self
					applyEdit: nil
					source: new
					cursorAt: index start index
					undoDo: [:undoSource :block | block value: source value: nil value: nil]]]]
]

{ #category : #'as yet unclassified' }
PNode >> prettySourceString [

	self allBlocksDo: [:b | b valid ifFalse: [^ self sourceString]].
	^ self language runtime
		ifNotNil: [:r | r prettyPrint: self sourceString]
		ifNil: [self sourceString]
]

{ #category : #'as yet unclassified' }
PNode >> printOn: aStream [

	aStream nextPutAll: self type
]

{ #category : #'as yet unclassified' }
PNode >> printTree [

	| s |
	s := '' writeStream.
	self printTreeOn: s indent: 0.
	^ s contents
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:04'
}
PNode >> printTreeOn: aStream indent: aNumber [

	aNumber timesRepeat: [aStream tab].
	aStream nextPutAll: '('.
	aStream nextPutAll: self type.
	aStream space.
	aStream print: self range.
	aStream cr.
	self children do: [:c | c printTreeOn: aStream indent: aNumber + 1] separatedBy: [aStream cr].
	aStream nextPutAll: ')'
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:24'
}
PNode >> privateSource [

	^ tsSource
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:23'
}
PNode >> privateSource: aString [

	tsSource := aString
]

{ #category : #accessing }
PNode >> privateTSTree [

	^ self valueOfProperty: #tsTree
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:23'
}
PNode >> privateTSTree: aTree [

	tsTree := aTree
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:24'
}
PNode >> privateTSTreeOrNilDo: aBlock [

	^ tsTree ifNotNil: [:tree | tree isNull ifFalse: [aBlock value: tree] ifTrue: [nil]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:15'
}
PNode >> queryAll: aString [

	aString isString ifFalse: [^ PQuery script: aString allDeep: self].
	
	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	^ Array streamContents: [:stream |
		self allChildrenDo: [:block |
			block isTSMorph ifTrue: [
				(SBTSQuery new
					prepare: aString;
					executeCaptureAgainst: block) do: [:assoc | stream nextPut: assoc value]]]]
]

{ #category : #'as yet unclassified' }
PNode >> queryChildrenFirst: aString [

	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	self children do: [:block |
		block isTSMorph ifTrue: [
			(SBTSQuery new
				prepare: aString;
				executeCaptureAgainst: block) do: [:assoc | ^ assoc value]]].
	^ nil
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:15'
}
PNode >> queryFirst: aString [

	aString isString ifFalse: [^ PQuery script: aString firstDeep: self].
	
	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	self allBaseChildrenDo: [:block |
		block isTSMorph ifTrue: [
			(SBTSQuery new
				prepare: aString;
				executeCaptureAgainst: block) do: [:assoc | ^ assoc value]]].
	^ nil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:30'
}
PNode >> queryState [

	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> range [

	^ range
]

{ #category : #'as yet unclassified' }
PNode >> range: aRange [

	range := aRange
]

{ #category : #'as yet unclassified' }
PNode >> replaceWith: aString [

	self infoForEditDo: [:source :textMorph :cursorIndex | self class replace: textMorph range in: source with: aString do: self applyBlock]
]

{ #category : #grammar }
PNode >> resolveAlias: aSymbol in: aNode [

	(aNode type = 'ALIAS' and: [(aNode at: #value) = aSymbol]) ifTrue: [
		^ aNode content type = 'SYMBOL'
			ifTrue: [self language grammarRule: aNode content name]
			ifFalse: [aNode content]].
	
	aNode members ifNotNil: [aNode members do: [:m | (self resolveAlias: aSymbol in: m) ifNotNil: [:g | ^ g]]].
	
	aNode content ifNotNil: [^ self resolveAlias: aSymbol in: aNode content].
	
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> restoreCursorAfter: aBlock [

	| current textMorph index editor |
	editor := self sandblockEditor.
	editor ifNil: [^ aBlock value].
	
	current := editor selection.
	textMorph := current activeTextMorph.
	index := textMorph ifNotNil: #cursor.
	aBlock value.
	
	(textMorph ifNotNil: #isInWorld ifNil: [false]) ifFalse: [textMorph := nil].
	
	current isInWorld ifFalse: [^ self].
	
	textMorph
		ifNotNil: [editor startInput: current at: index replacingContents: false in: textMorph]
		ifNil: [current select]
]

{ #category : #'as yet unclassified' }
PNode >> rootBlock [

	| current |
	current := self.
	[current isRootBlock] whileFalse: [current := current baseParent].
	^ current
]

{
	#category : #queries,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:15'
}
PNode >> run: aCollection [

	^ PQuery script: aCollection with: self
]

{ #category : #'as yet unclassified' }
PNode >> shallowCopyBlock [

	^ self class new
		type: type;
		language: language;
		range: range;
		field: field;
		highlight: highlight
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:37'
}
PNode >> share [

	^ self valueOfProperty: #share
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:38'
}
PNode >> share: aShare [

	self assert: (aShare class = PSubtreeShare or: [aShare isNil]).
	share := aShare
]

{ #category : #'as yet unclassified' }
PNode >> showInQuery [

	^ true
]

{ #category : #hierarchy }
PNode >> siblingIndex [

	| i p |
	self replacedParent ifNotNil: [^ self replacedParent siblingIndex].
	
	p := self parent.
	p ifNil: [^ 0].
	
	i := 1.
	p childrenDo: [:c |
		c = self ifTrue: [^ i].
		i := i + 1].
	^ 0
]

{ #category : #'as yet unclassified' }
PNode >> smallestBlockEncompassig: aRange [

	| min |
	min := self.
	self allBlocksDo: [:block | (block isTSMorph and: [block encompasses: aRange]) ifTrue: [min range size > block range size ifTrue: [min := block]]].
	^ min
]

{ #category : #accessing }
PNode >> source [

	^ self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/19/2024 18:13'
}
PNode >> sourceString [

	| root |
	tsSource ifNotNil: [^ tsSource].
	root := self rootBlock.
	self assert: root ~= self.
	^ root sourceString
		copyFrom: self range first + 1
		to: self range last
]

{ #category : #'as yet unclassified' }
PNode >> statementWithTerminatorRange [

	^ self trailingTerminator
		ifNotNil: [:t | PRange merging: {self range. t range}]
		ifNil: [self range]
]

{ #category : #'as yet unclassified' }
PNode >> statements [

	^ self childSandblocks
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:38'
}
PNode >> structureHash [

	^ structureHash ifNil: [ | writer |
		writer := #[] writeStream.
		writer nextPutAll: self type.
		self baseChildren do: [:c | writer nextLittleEndianNumber: 4 put: c structureHash].
		structureHash := SecureHashAlgorithm new hashStream: writer contents readStream]
]

{ #category : #'as yet unclassified' }
PNode >> suggestions [

	^ self queryState suggestionsFor: self
]

{ #category : #'as yet unclassified' }
PNode >> template [

	^ self language rule: self type
]

{ #category : #'as yet unclassified' }
PNode >> textMorphForPosition: aPosition [

	self allChildrenDo: [:t | (t isTextMorph and: [t range contains: aPosition]) ifTrue: [^ t]].
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> textMorphs [

	^ self submorphs select: [:t | t isTextMorph]
]

{ #category : #'as yet unclassified' }
PNode >> trailingTerminator [

	| nextLeaf |
	self language isStatementTerminatorBetween ifFalse: [^ nil].
	nextLeaf := self nextMorphThat: [:m | m hasSubmorphs not].
	(nextLeaf ifNotNil: [:l | l isTSMorph ifTrue: [l treeLabel] ifFalse: ['']] ifNil: ['']) = self language statementTerminator ifTrue: [^ nextLeaf].
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> treeHash [

	false ifTrue: [^ self treeHashCount: {0}].
	^ self valueOfProperty: #treeHash ifAbsentPut: [self treeHashCount: {0}]
]

{ #category : #'as yet unclassified' }
PNode >> treeHashChildren: anotherNumber [

	^ ((((self type hash bitXor: 'ENTER' hash) bitXor: anotherNumber) bitXor: self siblingIndex hash) bitXor: self childCount) bitXor: 'LEAVE' hash
]

{ #category : #'as yet unclassified' }
PNode >> treeHashChildren: anotherNumber countPtr: aCollection [

	aCollection at: 1 put: aCollection first + 1.
	
	^ ((self type hash + 'ENTER' hash + anotherNumber bitXor: (2 * aCollection first + 1) hash) bitXor: self childCount) bitXor: 'LEAVE' hash
]

{ #category : #'as yet unclassified' }
PNode >> treeHashCount: aPtr [

	| hash |
	self hasChildren ifFalse: [^ self treeHashChildren: 0 countPtr: aPtr].
	hash := 0.
	
	self childrenDo: [:morph | hash := (hash + (morph treeHashCount: aPtr)) hashMultiply].
	
	^ self
		treeHashChildren: hash
		countPtr: aPtr
]

{ #category : #'as yet unclassified' }
PNode >> treeHeight [

	^ self valueOfProperty: #treeHeight ifAbsentPut: [super treeHeight]
]

{ #category : #'as yet unclassified' }
PNode >> treeLabel [

	^ ''
]

{ #category : #hierarchy }
PNode >> treeSize [

	^ self valueOfProperty: #treeSize ifAbsentPut: [super treeSize]
]

{ #category : #'as yet unclassified' }
PNode >> type [

	^ type
]

{ #category : #'as yet unclassified' }
PNode >> type: aSymbol [

	type := aSymbol.
	
	
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:37'
}
PNode >> unassignTree [

	self assigned assigned: nil.
	self assigned: nil
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:37'
}
PNode >> uri [

	
]

{ #category : #'as yet unclassified' }
PNode >> valid [

	^ self type ~= 'ERROR'
]

{ #category : #'as yet unclassified' }
PNode >> writeSourceOn: aStream [

	self valueOfProperty: #tsSource ifPresentDo: [:source | ^ aStream nextPutAll: source].
	
	self assert: self rootBlock ~= self.
	
	self rootBlock
		ifNotNil: [
			aStream nextPutAll: (self rootBlock privateSource
				copyFrom: self range start index + 1
				to: self range end index)]
		ifNil: [self writeSourceOn: aStream indent: 0 forCompare: false]
]

{ #category : #'as yet unclassified' }
PNode >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	self children ifEmpty: [^ self].
	(self language indentMatch: self) ifTrue: [self slot indent: 1 on: aStream].
	aStream hasLineInfo ifTrue: [
		range start
			line: aStream currentLine
			character: aStream currentIndexInLine
			index: aStream position].
	self children overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber) forCompare: aBoolean.
		aStream nextPutAll: (self slot
			separatorBetween: first
			and: second
			indent: aNumber
			lastCharacterOfFirst: (aStream position > 0 ifFalse: [$ ] ifTrue: [aStream last]))].
	self children last
		writeSourceOn: aStream
		indent: (self indentFor: self children last current: aNumber)
		forCompare: aBoolean.
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine index: aStream position]
]
