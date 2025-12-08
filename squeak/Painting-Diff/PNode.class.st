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
				ifTrue: [aNode baseAndMorphAdd: (PText new contents: String cr; range: (SBTSRange start: start size: 1))]
				ifFalse: [
					aNode baseAndMorphAdd: (PText new
						contents: part;
						range: (SBTSRange start: start size: part size))]].
		start := start + part size].
	aCursor advance: text size.
	
	aBoolean ifTrue: [
		text := aCursor uncapturedText.
		aNode baseAndMorphAdd: (PText new
			contents: text;
			range: aCursor range)]
]

{ #category : #'text modify' }
PNode class >> deleteFrom: aString at: aNumber do: aBlock [

	| new deleted |
	deleted := aString copyFrom: aNumber to: aNumber.
	new := (aString first: aNumber - 1), (aString allButFirst: aNumber).
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aNumber - 1;
			oldEndByte: aNumber;
			newEndByte: aNumber - 1;
			bytesToPointsIn: aString new: new)
		value: [:source :block | self insert: deleted in: source at: aNumber do: block]
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

{ #category : #'text modify' }
PNode class >> insert: aString in: aContainerString at: aNumber do: aBlock [

	| new |
	new := (aNumber > aContainerString size or: [aContainerString isEmpty])
		ifTrue: [aContainerString, aString]
		ifFalse: [(aContainerString first: aNumber - 1), aString, (aContainerString allButFirst: aNumber - 1)].
	aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aNumber - 1;
			oldEndByte: aNumber - 1;
			newEndByte: aNumber - 1 + aString size;
			bytesToPointsIn: aContainerString new: new)
		value: [:source :block | self deleteFrom: source at: aNumber do: block]
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
	aBlock baseAndMorphAdd: (PText new contents: String cr; range: (SBTSRange start: last range end end: last range end + 1)).
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
PNode class >> replace: aRange in: aContainerString with: aString do: aBlock [

	| new original newLength |
	self
		example: [PNode]
		args: [{SBTSRange start: 3 size: 3. 'abcxxxghi'. 'def'. [:a :b | ]}]
		label: 'example'.
	
	original := aContainerString copyFrom: aRange start index + 1 to: aRange end index.
	newLength := aString size.
	new := (aContainerString first: aRange start index), aString, (aContainerString allButFirst: aRange end index).
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aRange start index;
			oldEndByte: aRange end index;
			newEndByte: aRange start index + aString size;
			bytesToPointsIn: aString new: new)
		value: [:source :block | self replace: (aRange withSize: newLength) in: source with: original do: block]
]

{
	#category : #'text modify',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:43'
}
PNode class >> swap: aRange with: anotherRange in: aString do: aBlock [

	| first second new |
	self
		example: [PNode new]
		args: [
			{
				SBTSRange
					start: (SBTSPosition line: 0 character: 8 index: 8)
					end: (SBTSPosition line: 0 character: 9 index: 9).
				SBTSRange
					start: (SBTSPosition line: 0 character: 2 index: 2)
					end: (SBTSPosition line: 0 character: 5 index: 5).
				'1234567890'}]
		label: 'example'.
	first := aRange start index < anotherRange start index
		ifTrue: [aRange]
		ifFalse: [anotherRange].
	second := aRange start index < anotherRange start index
		ifTrue: [anotherRange]
		ifFalse: [aRange].
	new := (aString first: first start index), (aString copyFrom: second start index + 1 to: second end index), (aString copyFrom: first end index + 1 to: second start index), (aString copyFrom: first start index + 1 to: first end index), (aString allButFirst: second end index).
	
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: first start index;
			oldEndByte: second end index;
			newEndByte: second end index;
			bytesToPointsIn: aString new: new)
		value: [:source :block |
			self
				swap: (first withSize: second size)
				with: (second withSize: first size) + (second size - first size)
				in: source
				do: block]
]

{
	#category : #'text modify',
	#'squeak_changestamp' : 'tobe 4/13/2024 11:43'
}
PNode class >> wrap: aRange in: aString open: anotherString close: aThirdString [

	self
		example: [PNode new]
		args: [{SBTSRange start: 3 size: 3. 'abcdefghi'. '('. ')'}]
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

{ #category : #'query actions' }
PNode >> addOwnSuggestions: aCollection label: aString [

	self addSuggestions: ((self class sortedSuggestions: aCollection for: self contents addAll: false max: 10) collect: [:sel | DCSuggestionItem new selector: sel label: aString source: sel])
]

{ #category : #'query actions' }
PNode >> addSuggestions: aCollection [

	self queryState addSuggestions: aCollection for: self
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

{ #category : #'as yet unclassified' }
PNode >> allLayoutMorphsDo: aBlock [

	aBlock value: self.
	self submorphs do: [:m | m allLayoutMorphsDo: aBlock].
	aBlock value: {#leave. self}
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

{ #category : #'as yet unclassified' }
PNode >> allTextMorphsDo: aBlock [
	"iterate over morphs, not children, as we're looking for visible text morphs"

	self allMorphsDo: [:m | m isTextMorph ifTrue: [aBlock value: m]]
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

{ #category : #'as yet unclassified' }
PNode >> applyEditsIn: newTree to: oldTree [

	true ifTrue: [
		oldTree allBaseChildrenDo: [:m | m clearDiffCache].
		^ DCTrueDiff new compare: oldTree to: newTree].
	DCMatcher new performEditsIn: newTree to: oldTree
]

{ #category : #'as yet unclassified' }
PNode >> artefactChanged: aMethodBlock [

	(self containingArtefact = aMethodBlock and: [self isRootBlock]) ifTrue: [self queryState updateChangeQueries]
]

{ #category : #'as yet unclassified' }
PNode >> artefactSaved: aMethodBlock [

	(self containingArtefact = aMethodBlock and: [self isRootBlock]) ifTrue: [self queryState updateQueriesFor: #save at: self]
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

{ #category : #'query actions' }
PNode >> attachHighlight [

	self queryState highlight: self
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

{ #category : #'as yet unclassified' }
PNode >> borderVertices [

	| level endLevel corners first last |
	corners := self cornerMorphs.
	first := corners first.
	last := corners last.
	
	level := 0 asEdgeInsets.
	first = self ifFalse: [
		first firstOwnerSuchThat: [:o |
			level := level + o layoutInset asEdgeInsets.
			o = self]].
	endLevel := 0 asEdgeInsets.
	last = self ifFalse: [
		last firstOwnerSuchThat: [:o |
			endLevel := endLevel + o layoutInset asEdgeInsets.
			o = self]].
	
	^ {
		self bounds bottomLeft.
		self left @ (first bottom + level bottom).
		first left - level left @ (first bottom + level bottom).
		first left - level left @ self top.
		self bounds topRight.
		self right @ (last top - endLevel top).
		last right + endLevel right @ (last top - endLevel top).
		last right + endLevel right @ self bottom}
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
PNode >> clearInput [
	<action>

	self infoForEditDo: [:source :textMorph | self class replace: (self activeTextMorph ifNil: [self]) range in: source with: '' do: self applyBlock]
]

{ #category : #grammar }
PNode >> commandForInsert: aNode at: aNumber [

	| children |
	children := self childNodes readStream.
	self match: self grammarRule with: children do: [:child :rule | {rule. child}]
]

{ #category : #'as yet unclassified' }
PNode >> compatibleWithType: aSymbol [

	^ self type = aSymbol
]

{ #category : #'as yet unclassified' }
PNode >> containingArtefact [

	^ self isArtefact
		ifTrue: [self]
		ifFalse: [self parent ifNotNil: [:b | b containingArtefact]]
]

{ #category : #'as yet unclassified' }
PNode >> containsPoint: aPoint [

	| inside |
	(super containsPoint: aPoint) ifFalse: [^ false].
	inside := false.
	self borderVertices overlappingPairsLoopedDo: [:a :b | (a y > aPoint y ~= (b y > aPoint y) and: [aPoint x < (b x - a x * (b y - a y) / (b y - a y) + a x)]) ifTrue: [inside := inside not]].
	^ inside
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
PNode >> currentTextMorph [

	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> cursorPositionsDo: aBlock shallow: aBoolean [

	true ifTrue: [^ super cursorPositionsDo: aBlock shallow: aBoolean].
	
	aBlock value: (SBCursorSelect new block: self).
	self match: self grammarRule with: self childNodes readStream do: [:child :rule |
		(rule type = 'SYMBOL' or: [rule type = 'ALIAS'])
			ifTrue: [aBoolean ifFalse: [child cursorPositionsDo: aBlock shallow: aBoolean]]
			ifFalse: [
				(child containingSandblock startInputCommandIn: child) ifNotNil: [:command |
					aBlock value: (SBCursorText new
						block: child containingSandblock;
						currentCommand: command)]]]
]

{ #category : #'as yet unclassified' }
PNode >> deleteAfterCursor [
	<action>

	self infoForEditDo: [:source :textMorph :cursorIndex | self class deleteFrom: source at: cursorIndex + 1 do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
PNode >> deleteBeforeCursor [
	<action>

	self infoForEditDo: [:source :textMorph :cursorIndex | self class deleteFrom: source at: cursorIndex do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
PNode >> deleteBlock [
	<action>

	self isArtefact ifTrue: [^ super deleteBlock].
	
	self infoForEditDo: [:source :textMorph :cursorIndex | | delRange |
		delRange := textMorph range.
		self trailingTerminator ifNotNil: [:t | | clearUntil |
			clearUntil := (t nextMorphThat: [:m | m submorphAfter isNil or: [m submorphAfter isExtra not]]) ifNil: [t].
			delRange := SBTSRange merging: {delRange. clearUntil range}].
		self class replace: delRange in: source with: '' do: self applyBlock]
]

{ #category : #'as yet unclassified' }
PNode >> deleteBlockWithCopy [
	<action>

	self sandblockEditor copyBuffer: self preferQuick: true.
	self deleteBlock
]

{ #category : #'as yet unclassified' }
PNode >> doLayoutIn: layoutBounds [

	| info |
	self isLayoutRoot ifFalse: [
		" if we've been called as a child, just assign whatever we have stored. the root will take of correcting things if needed "
		fullBounds := self bounds.
		^ self].
	
	info := DCLayoutInfo new layoutRoot: self at: layoutBounds origin.
	
	self assert: fullBounds notNil
]

{ #category : #'as yet unclassified' }
PNode >> doubleClick: anEvent [

	self queryState updateQueriesFor: #doubleClick at: self
]

{ #category : #'as yet unclassified' }
PNode >> drawBackgroundOn: aCanvas [

	| policy |
	policy := self colorPolicy.
	self allMorphsDo: [:c |
		c isLineBreak ifTrue: [ | level |
			level := 0.
			c firstOwnerSuchThat: [:o |
				level := level + 1.
				o = self].
			aCanvas
				drawPolygon: self borderVertices
				color: self drawnColor
				borderWidth: (policy borderWidthForBlock: self)
				borderColor: (policy borderColorForBlock: self).
			^ self]].
	
	^ aCanvas
		frameAndFillRoundRect: self bounds
		radius: policy cornerRadius
		fillStyle: self drawnColor
		borderWidth: (policy borderWidthForBlock: self)
		borderColor: (policy borderColorForBlock: self)
]

{ #category : #'as yet unclassified' }
PNode >> drawnColor [

	^ self prefersNoBorder
		ifTrue: [super drawnColor alpha: 0]
		ifFalse: [super drawnColor]
]

{ #category : #'as yet unclassified' }
PNode >> emphasis [

	self highlight ifNotNil: [:h |
		(h beginsWith: 'major_declaration') ifTrue: [^ TextEmphasis bold].
		self type = #comment ifTrue: [^ TextEmphasis italic]].
	^ self colorPolicy defaultEmphasis
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

{ #category : #'as yet unclassified' }
PNode >> grammarHandler [

	^ DCGrammarHandler new
]

{ #category : #grammar }
PNode >> grammarRule [

	^ (self language grammarRule: self type) ifNil: [self resolveAlias: self type in: self owner grammarRule]
]

{ #category : #'as yet unclassified' }
PNode >> handleInsertEvent: anEvent in: textMorph [

	| pairMap input |
	pairMap := self pairMap.
	input := anEvent keyCharacter asString.
	pairMap at: input ifPresent: [:complete |
		"do not autocomplete quotes in words"
		((textMorph characterBeforeCursor
			ifNotNil: #isAlphaNumeric
			ifNil: [false]) and: [complete = '''']) ifTrue: [^ textMorph insertString: input].
		
		"do not autocomplete after backslash"
		textMorph characterBeforeCursor = $\ ifTrue: [^ textMorph insertString: input].
		
		^ textMorph
			insertString: input, complete;
			moveCursor: -1].
	
	SBToggledCode comment: '' active: 0 do: {
		[
			(pairMap keyAtValue: input ifAbsent: [nil]) ifNotNil: [:key |
				"jump to a matching closing bracket just after us"
				(textMorph nextMorphThat: #isTextMorph) ifNotNil: [:m |
					m contents = input ifTrue: [
						^ self sandblockEditor
							startInput: m containingSandblock
							at: 900000000
							replacingContents: false
							in: m]].
				
				"skip inserting closing parens that already exist"
				(textMorph contents notEmpty and: [textMorph contents includesSubstring: input]) ifTrue: [^ self]]]}.
	
	^ super keyStroke: anEvent
]

{ #category : #'as yet unclassified' }
PNode >> handleMouseEnter: anEvent [

	super handleMouseEnter: anEvent.
	self queryState updateQueriesFor: #hover at: self
]

{ #category : #'as yet unclassified' }
PNode >> handleMouseLeave: anEvent [

	super handleMouseLeave: anEvent.
	self addAlarm: #triggerEvent: with: #mouseLeaveNextTick after: 1
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
	
	range := SBTSRange null.
	baseParent := nil.
	baseChildren := OrderedCollection new: 1
]

{ #category : #'as yet unclassified' }
PNode >> inputClosestTextMorphTo: cursorPosition [

	| best bestDistance atStart |
	best := nil.
	bestDistance := Float infinity.
	atStart := false.
	
	"match on same line"
	self allChildrenDo: [:t |
		t isTextMorph ifTrue: [
			t range start line = cursorPosition line ifTrue: [ | distance |
				distance := (t range start character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := true.
					best := t]].
			t range end line = cursorPosition line ifTrue: [ | distance |
				distance := (t range end character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	"match on different line"
	best ifNil: [
		self allChildrenDo: [:t |
			t isTextMorph ifTrue: [ | distance |
				distance := (t range start line - cursorPosition line) abs min: (t range end line - cursorPosition line) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	best ifNotNil: [
		self sandblockEditor
			startInput: best containingSandblock
			at: (atStart ifTrue: [1] ifFalse: [900000000])
			replacingContents: false
			in: best]
]

{ #category : #'as yet unclassified' }
PNode >> insert: aString [

	self infoForEditDo: [:source :textMorph :cursorIndex | self class insert: aString in: source at: cursorIndex + 1 do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
PNode >> insert: aString atChildIndex: aNumber [

	self infoForEditDo: [:source :textMorph :cursorIndex |
		self class
			insert: aString
			in: source
			at: (self children at: aNumber) range start index + 1
			do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
PNode >> insertAfter: aString [

	self infoForEditDo: [:source :textMorph :cursorIndex |
		self class
			insert: aString
			in: source
			at: self range end index + 1
			do: (self applyBlockWithCursor: self range end index)].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
PNode >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ nil
]

{ #category : #'as yet unclassified' }
PNode >> insertStatementAboveOrBelow: anAboveBoolean [

	| lineBreak target |
	target := self activeTextMorph ifNil: [self].
	lineBreak := anAboveBoolean
		ifTrue: [target previousMorphThat: [:c | c isLineBreak]]
		ifFalse: [target nextMorphThat: [:c | c isLineBreak]].
	
	lineBreak ifNil: [^ self].
	lineBreak containingSandblock containingArtefact = self containingArtefact ifFalse: [^ self].
	
	self infoForEditDo: [:source :textMorph :cursorIndex |
		self class
			insert: String cr, lineBreak getIndentString
			in: source
			at: lineBreak range start index + 1
			do: (self applyBlockWithCursor: lineBreak range start index + 2)]
]

{ #category : #'as yet unclassified' }
PNode >> insertStatementHasCandidate [

	^ true
]

{ #category : #'as yet unclassified' }
PNode >> installActiveReplacement: aBlock [

	self sandblockEditor do: (SBCombinedCommand newWith: {
		SBReplaceCommand new target: self replacer: (aBlock source: self).
		SBMutatePropertyCommand new
			target: self;
			selector: #replacedParent;
			value: aBlock})
]

{ #category : #'as yet unclassified' }
PNode >> installActiveReplacement: aBlock do: aClosure [

	self sandblockEditor do: (SBCombinedCommand newWith: {
		SBReplaceCommand new target: self replacer: (aBlock source: self).
		SBMutatePropertyCommand new
			target: self;
			selector: #replacedParent;
			value: aBlock}).
	aClosure value: aBlock
]

{ #category : #'as yet unclassified' }
PNode >> installPassiveReplacement: aBlock [

	aBlock source: self.
	self replaceNodeBy: aBlock.
	self replacedParent: aBlock
]

{ #category : #'as yet unclassified' }
PNode >> installPassiveReplacement: aBlock do: aClosure [

	aBlock source: self.
	self replaceNodeBy: aBlock.
	self replacedParent: aBlock.
	aClosure value: aBlock
]

{ #category : #'as yet unclassified' }
PNode >> intoWorld: aWorld [

	super intoWorld: aWorld.
	
	self isRootBlock ifTrue: [
		self sandblockEditor
			when: #selectionChanged
			send: #updateSelectionQueries
			to: self queryState.
		self sandblockEditor
			when: #batchedChange
			send: #updateTypeQueries
			to: self queryState.
		self queryState
			updateQueriesFor: #open;
			updateQueriesFor: #always]
]

{ #category : #hierarchy }
PNode >> is: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ matches includes: self type
]

{ #category : #'as yet unclassified' }
PNode >> isArtefact [

	^ self isRootBlock and: [self valueOfProperty: #isArtefact ifAbsent: [false]]
]

{ #category : #'as yet unclassified' }
PNode >> isBlockBody [

	^ self language ifNotNil: [:l | l blockBodyTypes includes: self type] ifNil: [false]
]

{ #category : #'as yet unclassified' }
PNode >> isExpression [

	(self type = #ERROR and: [self submorphCount = 1]) ifTrue: [^ self firstSubmorph isExpression].
	
	^ self language expressionTypes anySatisfy: [:type | self language instance grammar is: self type subtypeOf: type]
]

{ #category : #testing }
PNode >> isExtra [

	^ false
]

{ #category : #'as yet unclassified' }
PNode >> isLayoutRoot [

	^ self owner ifNotNil: [:o | o class ~= self class] ifNil: [true]
]

{ #category : #'as yet unclassified' }
PNode >> isLeafIdentifier [

	^ self contents anySatisfy: [:c | c isLetter]
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
PNode >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
PNode >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
PNode >> keyStroke: anEvent [

	| editor artefact |
	editor := self sandblockEditor.
	artefact := self containingArtefact.
	
	self infoForEditDo: [:source :textMorph :cursorIndex | | input |
		input := anEvent keyCharacter asString.
		(input first isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
			(self adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent) ifNotEmpty: [:text |
				self class
					insert: (self maybeAddSeparator: text textMorph: textMorph)
					in: source
					at: cursorIndex + 1
					do: (self applyBlockWithCursor: cursorIndex + (text indexOf: anEvent keyCharacter))]]].
	editor batchedChangeStep: artefact
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

{ #category : #'as yet unclassified' }
PNode >> layoutInset [

	false ifTrue: [^ 5 sbScaled].
	self isBlockBody ifTrue: [^ (4 @ 3) sbScaled].
	
	^ (2 @ (self submorphCount > 3 ifTrue: [2] ifFalse: [0])) sbScaled
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
PNode >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	self isRootBlock ifTrue: [
		self queryState onDelete.
		self sandblockEditor
			removeActionsWithReceiver: self queryState forEvent: #selectionChanged;
			removeActionsWithReceiver: self queryState forEvent: #batchedChange]
]

{ #category : #'as yet unclassified' }
PNode >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
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

{ #category : #'actions smalltalk' }
PNode >> pasteReplace [
	<action>

	self infoForEditDo: [:source :textMorph :cursorIndex | | str |
		str := Clipboard clipboardText string.
		
		cursorIndex class = SBTSRange
			ifTrue: [self class replace: cursorIndex in: source with: str do: self applyBlock]
			ifFalse: [self class insert: str in: source at: cursorIndex + 1 do: self applyBlock]]
]

{ #category : #'as yet unclassified' }
PNode >> performAction: aSymbol [

	
	(self queryState performShortcut: aSymbol for: self) ifTrue: [^ true].
	
	(super performAction: aSymbol) ifTrue: [^ true].
	
	^ false
]

{ #category : #'as yet unclassified' }
PNode >> placeCursorIn: newTree at: newIndex [

	newIndex ifNil: [^ self].
	
	^ newIndex isNumber ifTrue: [newTree startInputAtSourceIndex: newIndex] ifFalse: [ | target |
		target := (newTree blockFor: newIndex) ifNil: [^ self].
		target isTextMorph
			ifTrue: [
				newTree sandblockEditor
					startInput: target containingSandblock
					at: 1
					replacingContents: false
					in: target]
			ifFalse: [newTree sandblockEditor selectNoInput: target]]
]

{ #category : #'as yet unclassified' }
PNode >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
PNode >> prefersNoBorder [

	^ self isPart
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

{ #category : #accessing }
PNode >> queryState [

	^ self rootBlock
		valueOfProperty: #queryState
		ifAbsentPut: [DCQueryState new rootBlock: self]
]

{ #category : #'as yet unclassified' }
PNode >> range [

	^ range
]

{ #category : #'as yet unclassified' }
PNode >> range: aRange [

	range := aRange
]

{ #category : #'query actions' }
PNode >> registerShortcut: aSymbol do: aBlock [

	" a previous shortcut may have removed us from the world, abort "
	(self rootBlock isNil or: [self rootBlock isInWorld not]) ifTrue: [^ self].
	
	self queryState tryShortcut: aSymbol do: aBlock
]

{ #category : #'as yet unclassified' }
PNode >> rejectsEvent: anEvent [

	^ (self containsPoint: anEvent position) not
]

{ #category : #'as yet unclassified' }
PNode >> replace: oldTree with: newTree [

	^ SBToggledCode comment: '' active: 1 do: {
		[ | editor |
			editor := self sandblockEditor.
			DCMatcher new doCommandForEditsIn: newTree to: oldTree in: editor.
			self sandblockEditor do: (SBCombinedCommand newWith: {
				SBMutatePropertyCommand new
					target: oldTree;
					selector: #privateSource;
					value: newTree privateSource}).
			oldTree].
		[
			self sandblockEditor do: (SBReplaceCommand new
				target: oldTree replacer: newTree;
				shouldMergeWithNext: true).
			newTree
				position: oldTree position;
				width: oldTree width;
				yourself]}
]

{ #category : #'as yet unclassified' }
PNode >> replaceWith: aString [

	self infoForEditDo: [:source :textMorph :cursorIndex | self class replace: textMorph range in: source with: aString do: self applyBlock]
]

{ #category : #'query actions' }
PNode >> reportError: anError [

	self queryState reportError: anError for: self
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
PNode >> sandblockEditor [

	" allow embedded nodes to access the editor "
	^ (self owner ifNil: [self parent]) ifNotNil: [:o | o sandblockEditor]
]

{ #category : #'as yet unclassified' }
PNode >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	self queryState errors ifNotEmpty: [:errors | aFixBoolean ifTrue: [errors do: [:error | error tryFixIfFail: [^ false]]] ifFalse: [^ false]].
	^ true
]

{ #category : #'as yet unclassified' }
PNode >> selectRightMostBlock [
	<action>
	<inputAction>

	| lineBreak |
	(self activeTextMorph notNil and: [self activeTextMorph isLineBreak]) ifTrue: [^ self].
	
	lineBreak := (self activeTextMorph ifNil: [self]) nextMorphThat: [:m | m isLineBreak].
	(lineBreak isNil or: [lineBreak containingSandblock containingFloat ~= self containingFloat]) ifTrue: [^ self selectLast].
	self sandblockEditor
		startInput: lineBreak containingSandblock
		at: 1
		replacingContents: false
		in: lineBreak
]

{ #category : #'as yet unclassified' }
PNode >> selectStartOfStatement [
	<action>
	<inputAction>

	| lineBreak first |
	lineBreak := (self activeTextMorph ifNil: [self]) previousMorphThat: [:m | m isLineBreak].
	(lineBreak isNil or: [lineBreak containingSandblock containingFloat ~= self containingFloat]) ifTrue: [^ self containingFloat firstDeepChild startInputAtStart].
	first := lineBreak nextMorphThat: [:m | m isExtra not].
	self sandblockEditor
		startInput: first containingSandblock
		at: 1
		replacingContents: false
		in: first
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
PNode >> slot [

	^ DCMockSlot new for: self
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
PNode >> startInputAtSourceIndex: aNumber [

	self allTextMorphsDo: [:m | | range |
		range := m isTSMorph
			ifTrue: [m range]
			ifFalse: [(m ownerSatisfying: [:o | o isTSMorph]) ifNotNil: [:o | o range]].
		(range notNil and: [range end index >= aNumber]) ifTrue: [
			^ aNumber <= range end index
				ifTrue: [
					"we're now inside!"
					self sandblockEditor
						startInput: m containingSandblock
						at: aNumber - range start index + 1
						replacingContents: false
						in: m]
				ifFalse: [
					"we just went past"
					self sandblockEditor
						startInput: m containingSandblock
						at: 1
						replacingContents: false
						in: m]]]
]

{ #category : #'as yet unclassified' }
PNode >> startInputCommandIn: aTextMorph [

	^ aTextMorph ifNotNil: [SBTextCommand new textMorph: aTextMorph] ifNil: [nil]
]

{ #category : #'as yet unclassified' }
PNode >> statementWithTerminatorRange [

	^ self trailingTerminator
		ifNotNil: [:t | SBTSRange merging: {self range. t range}]
		ifNil: [self range]
]

{ #category : #'as yet unclassified' }
PNode >> statements [

	^ self childSandblocks
]

{ #category : #'as yet unclassified' }
PNode >> suggestions [

	^ self queryState suggestionsFor: self
]

{ #category : #'as yet unclassified' }
PNode >> swap: aNumber [

	self infoForEditDo: [:source :textMorph :cursorIndex | | pivot outerPivot |
		pivot := (self sandblockEditor mode = #input
			ifTrue: [textMorph]
			ifFalse: [self]) orOwnerSuchThat: [:morph | morph owner submorphCount > 1].
		outerPivot := pivot orOwnerSuchThat: [:morph |
			(aNumber > 0
				ifTrue: [morph morphAfterThat: #isSandblock]
				ifFalse: [morph morphBeforeThat: #isSandblock]) notNil].
		outerPivot ifNotNil: [ | target startIndex targetRange pivotRange |
			target := aNumber > 0
				ifTrue: [outerPivot morphAfterThat: #isSandblock]
				ifFalse: [outerPivot morphBeforeThat: #isSandblock].
			targetRange := target statementWithTerminatorRange.
			pivotRange := pivot statementWithTerminatorRange.
			startIndex := targetRange start index + (aNumber > 0 ifTrue: [targetRange size - pivotRange size] ifFalse: [0]).
			self class
				swap: pivotRange
				with: targetRange
				in: source
				do: (self applyBlockWithCursor: (SBTSRange start: startIndex size: pivot range size))]]
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

{ #category : #'as yet unclassified' }
PNode >> typeNewLine [
	<inputAction>

	self insert: String lf
]

{ #category : #'as yet unclassified' }
PNode >> updateAllHighlights [

	^ self slot updateAllHighlightsFor: self
]

{ #category : #'as yet unclassified' }
PNode >> useSuggestion: anItem [

	self infoForEditDo: [:source :textMorph :cursorIndex | self class replace: textMorph range in: source with: anItem source do: self applyBlock]
]

{ #category : #'as yet unclassified' }
PNode >> valid [

	^ self type ~= 'ERROR'
]

{ #category : #'action helpers' }
PNode >> wrapIn: aString [

	self wrapWithBefore: aString after: (self pairMap at: aString)
]

{ #category : #actions }
PNode >> wrapInBackticks [
	<action>

	self wrapIn: '`'
]

{ #category : #actions }
PNode >> wrapInCurlyBraces [
	<action>

	self wrapIn: '{'
]

{ #category : #actions }
PNode >> wrapInDoubleQuotes [
	<action>

	self wrapIn: '"'
]

{ #category : #actions }
PNode >> wrapInRoundParenthesis [
	<action>

	self wrapIn: '('
]

{ #category : #actions }
PNode >> wrapInSingleQuotes [
	<action>

	self wrapIn: ''''
]

{ #category : #actions }
PNode >> wrapInSquareBrackets [
	<action>

	self wrapIn: '['
]

{ #category : #'as yet unclassified' }
PNode >> wrapWithBefore: aString after: anotherString [

	self infoForEditDo: [:source :textMorph :cursorIndex |
		self class
			replace: textMorph range
			in: source
			with: aString, self sourceString, anotherString
			do: (self applyBlockWithCursor: textMorph range start index + aString size)]
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
