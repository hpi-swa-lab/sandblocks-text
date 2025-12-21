Class {
	#name : #PShard,
	#superclass : #Morph,
	#instVars : [
		'nodes',
		'view',
		'editor',
		'extensions',
		'replacements',
		'lastActualSourceString',
		'attributes'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:27'
}
PShard >> adjustGlobalIndex: aNumber [

	| index |
	index := aNumber.
	self replacements do: [:replacement |
		replacement range first < index ifTrue: [
			" subtract the replaced range but add 1 for the startOfHeader character "
			index := index - replacement range size + 1]].
	index := index - self range first.
	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 10:59'
}
PShard >> adjustLocalIndex: aNumber [

	| index |
	index := aNumber + self range first.
	self replacements do: [:replacement |
		replacement range first < index ifTrue: [
			" add the replaced range but subtract 1 for the startOfHeader character "
			index := index + replacement range size - 1]].
	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/21/2025 23:09'
}
PShard >> allSelectedSourceString [

	^ Text streamContents: [:stream | 
		(self view text attributesAt: self view selectionInterval start - 1 + 0)
			detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
			ifFound: [:ea | | childShard |
				childShard := ea anchoredMorph firstSubmorph.
				stream nextPutAll: childShard allSelectedSourceString].
		
		stream nextPutAll:
			(self editor sourceString
				copyFrom: (self adjustLocalIndex: self view selectionInterval start)
				to: (self adjustLocalIndex: self view selectionInterval stop)).
		
		(self view text attributesAt: self view selectionInterval stop + 1 + 0)
			detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
			ifFound: [:ea | | childShard |
				childShard := ea anchoredMorph firstSubmorph.
				stream nextPutAll: childShard allSelectedSourceString]].
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/20/2025 23:11'
}
PShard >> allSelectedText [

	^ Text streamContents: [:stream | | myText |
		(self view text attributesAt: self view selectionInterval start - 1 + 0)
			detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
			ifFound: [:ea | | childShard |
				childShard := ea anchoredMorph firstSubmorph.
				stream nextPutAll: childShard allSelectedText].
		
		myText := self view text
			copyFrom: self view selectionInterval start
			to: self view selectionInterval stop.
		myText runs withStartStopAndValueDo: [:start :stop :attrs |
			attrs
				detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
				ifFound: [:ea | | childShard |
					childShard := ea anchoredMorph firstSubmorph.
					stream nextPutAll: childShard allSelectedText]
				ifNone: [
					stream nextPutAll: (myText copyFrom: start to: stop)]].
		
		(self view text attributesAt: self view selectionInterval stop + 1 + 0)
			detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
			ifFound: [:ea | | childShard |
				childShard := ea anchoredMorph firstSubmorph.
				stream nextPutAll: childShard allSelectedText]].
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/20/2024 08:17'
}
PShard >> allVisibleNodesDo: aBlock root: aRoot [

	| replaced |
	replaced := Array streamContents: [:s | self replacements do: [:r | r definition model = aRoot language ifTrue: [s nextPut: r node]]].
	
	self nodes first language = aRoot language
		ifTrue: [self nodes do: [:root | root allVisibleNodesDo: aBlock hidden: replaced]]
		ifFalse: [aRoot firstChildrenInRange: self range do: [:root | root allVisibleNodesDo: aBlock hidden: replaced]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:37'
}
PShard >> applyChanges: aCollection editScript: aScript [

	self updateReplacementsFor: aScript
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:45'
}
PShard >> applyRejectedChanges: aCollection [

	self updateText
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 16:17'
}
PShard >> basicApplyChanges: aCollection editScript: aScript [

	self halt.
	(aCollection reject: [:change | change sourceShard = self]) do: [:change |
		view handleEdit: [
			view
				selectInvisiblyFrom: (self adjustGlobalIndex: change from) + 1
					to: (self adjustGlobalIndex: change to);
				replaceSelectionWith: (change insert ifNil: [''])]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/22/2025 00:16'
}
PShard >> copySelection [

	| string |
	string := self allSelectedSourceString.
	string := string asString copyWithRegex: '(?<=sbWatchWithId\:\s*)\d+\b' matchesTranslatedUsing: [:match | match asNumber hashMultiply asString].
	Clipboard clipboardText: string.
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 08:10'
}
PShard >> editor [

	^ editor
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:06'
}
PShard >> editor: anEditor [

	anEditor shards add: self.
	editor := anEditor.
	
	anEditor ensureModels: self requiredModels
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:06'
}
PShard >> extensions: aBlock [

	extensions := aBlock.
	
	editor ifNotNil: [editor ensureModels: self requiredModels]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/20/2025 23:27'
}
PShard >> filterEvent: anEvent for: aMorph [

	anEvent isKeystroke ifFalse: [^ anEvent].
	aMorph hasKeyboardFocus ifFalse: [^ anEvent].
	
	(anEvent commandKeyPressed and: [anEvent keyCharacter = $c]) ifTrue: [
		| containingReplacement |
		((containingReplacement := self owner) isKindOf: PReplacementPluggable) ifTrue: [
			| containingTextMorph containingShard |
			containingTextMorph := containingReplacement owner.
			containingShard := containingTextMorph owner owner owner.
			^ containingShard filterEvent: anEvent for: aMorph].
		self copySelection.
		^ anEvent wasHandled: true].
	
	anEvent wasHandled ifTrue: [ "bubbling"
		| containingReplacement containingTextMorph |
		anEvent shiftPressed ifTrue: [^ anEvent].
		self replacements do: [:ea | | childTextMorph |
			childTextMorph := ea firstSubmorph view.
			(aMorph selectionInterval isEmpty and: [childTextMorph selectionInterval notEmpty]) ifTrue: [
				childTextMorph selectFrom: childTextMorph selectionInterval start to: childTextMorph selectionInterval start - 1]].
		((containingReplacement := self owner) isKindOf: PReplacementPluggable) ifFalse: [^ anEvent].
		containingTextMorph := containingReplacement owner.
		(aMorph selectionInterval isEmpty and: [containingTextMorph selectionInterval notEmpty]) ifTrue: [
			containingTextMorph selectFrom: aMorph selectionInterval start to: aMorph selectionInterval start - 1].
		^ anEvent].
	
	"capturing"
	(anEvent keyCharacter = Character arrowLeft and: [aMorph selectionInterval start <= 2]) ifTrue: [ | containingReplacement containingTextMorph containingShard index |
		((containingReplacement := self owner) isKindOf: PReplacementPluggable) ifFalse: [^ anEvent].
		containingTextMorph := containingReplacement owner.
		containingShard := containingTextMorph owner owner owner.
		anEvent hand newKeyboardFocus: containingTextMorph.
		index := (containingShard adjustGlobalIndex: containingReplacement range first) - (1 - aMorph selectionInterval start).
		aMorph selectFrom: 1 to: (anEvent shiftPressed ifFalse: [0] ifTrue: [aMorph selectionInterval stop]).
		containingTextMorph selectFrom: ((anEvent shiftPressed and: [containingTextMorph selectionInterval notEmpty]) ifFalse: [index] ifTrue: [containingTextMorph selectionInterval stop + 1]) to: index - 1.
		^ anEvent wasHandled: true].
	(anEvent keyCharacter = Character arrowRight and: [aMorph selectionInterval stop >= (aMorph text size - 1)]) ifTrue: [ | containingReplacement containingTextMorph index |
		((containingReplacement := self owner) isKindOf: PReplacementPluggable) ifFalse: [^ anEvent].
		containingTextMorph := containingReplacement owner.
		anEvent hand newKeyboardFocus: containingTextMorph.
		index := containingReplacement range first + 2.
		aMorph selectFrom: (anEvent shiftPressed ifFalse: [aMorph text size] ifTrue: [aMorph selectionInterval start]) to: (anEvent shiftPressed ifFalse: [aMorph text size - 1] ifTrue: [aMorph text size]).
		containingTextMorph selectFrom: ((anEvent shiftPressed and: [containingTextMorph selectionInterval notEmpty]) ifFalse: [index] ifTrue: [containingTextMorph selectionInterval start]) to: index - 1.
		^ anEvent wasHandled: true].
	anEvent keyCharacter = Character arrowLeft ifTrue: [
		1 to: 0 by: -1 do: [:i |
			| index |
			index := aMorph selectionInterval start - 1 - i.
			(aMorph text attributesAt: index)
				detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
				ifFound: [:ea | | childShard |
					childShard := ea anchoredMorph firstSubmorph.
					anEvent hand newKeyboardFocus: childShard view.
					aMorph selectFrom: (anEvent shiftPressed ifFalse: [index] ifTrue: [aMorph selectionInterval stop + 1]) to: (anEvent shiftPressed ifFalse: [index - 1] ifTrue: [index]).
					childShard view selectFrom: childShard view text size - (1 - i) + 1 to: childShard view text size - (1 - i).
					^ anEvent wasHandled: true]]].
	anEvent keyCharacter = Character arrowRight ifTrue: [
		1 to: 0 by: -1 do: [:i |
			| index |
			index := aMorph selectionInterval stop + 1 + i.
			(aMorph text attributesAt: index)
				detect: [:ea | ea anchoredMorph isKindOf: PReplacementPluggable]
				ifFound: [:ea | | childShard |
					childShard := ea anchoredMorph firstSubmorph.
					anEvent hand newKeyboardFocus: childShard view.
					aMorph selectFrom: (anEvent shiftPressed ifFalse: [index] ifTrue: [aMorph selectionInterval start]) to: (anEvent shiftPressed ifFalse: [index - 1] ifTrue: [index - 1]).
					childShard view selectFrom: (1 - i) + 1 to: 1 - i.
					^ anEvent wasHandled: true]]].
	
	^ anEvent
]

{
	#category : #utils,
	#'squeak_changestamp' : 'tobe 12/8/2025 21:52'
}
PShard >> findChange: aString b: anotherString preferredPos: preferredPos preferredSide: preferredSide [

	| diff |
	diff := self findDiff: aString b: anotherString preferredPos: preferredPos preferredSide: preferredSide.
	diff ifNil: [^ nil].
	
	^ ((diff at: #from) = (diff at: #toB)
		ifTrue: [
			{
				#delete -> (aString copyFrom: (diff at: #from) to: (diff at: #toA) - 1).
				#from -> (diff at: #from).
				#to -> (diff at: #toA)}]
		ifFalse: [
			{
				#insert -> (anotherString
					copyFrom: (diff at: #from)
					to: (diff at: #toB) - 1).
				#from -> (diff at: #from).
				#to -> (diff at: #toA)}]) as: Dictionary
]

{
	#category : #utils,
	#'squeak_changestamp' : 'tobe 4/13/2024 08:29'
}
PShard >> findDiff: aString b: anotherString preferredPos: myPreferredPos preferredSide: preferredSide [

	| minLen from toA toB adjust move preferredPos |
	"copied from codemirror: detect the change between to strings at the cursor position.
	`preferredSide` should be 'end' if backspace was pressed"
	preferredPos := myPreferredPos.
	minLen := aString size min: anotherString size.
	from := 1.
	[from <= minLen and: [(aString at: from) = (anotherString at: from)]] whileTrue: [from := from + 1].
	(from = minLen and: [aString size = anotherString size]) ifTrue: [^ nil].
	toA := aString size + 1.
	toB := anotherString size + 1.
	[(toA > 1 and: [toB > 1]) and: [(aString at: toA - 1) = (anotherString at: toB - 1)]] whileTrue: [
		toA := toA - 1.
		toB := toB - 1].
	
	preferredSide = #end ifTrue: [
		adjust := from - (toA min: toB) max: 0.
		preferredPos := preferredPos - (toA + adjust - from)].
	
	(toA < from and: [aString size < anotherString size])
		ifTrue: [
			move := (preferredPos <= from and: [preferredPos >= toA])
				ifTrue: [from - preferredPos]
				ifFalse: [0].
			from := from - move.
			toB := from + (toB - toA).
			toA := from]
		ifFalse: [
			toB < from ifTrue: [
				move := (preferredPos <= from and: [preferredPos >= toB])
					ifTrue: [from - preferredPos]
					ifFalse: [0].
				from := from - move.
				toA := from + (toA - toB).
				toB := from]].
	^ {#from -> from. #toA -> toA. #toB -> toB} as: Dictionary
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/9/2025 00:47'
}
PShard >> initialize [

	super initialize.
	
	replacements := SortedCollection sortBlock: [:a :b | a range first < b range first].
	attributes := OrderedCollection new.
	extensions := [{}].
	
	view := PluggableTextMorphPlus new
		setSelection: (0 to: 0);
		model: self;
		editTextSelector: #onChange:;
		setText: '';
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		yourself.
	view addKeyboardCaptureFilter: self. 
	view addKeyboardBubbleFilter: self.
	self
		addMorph: view;
		changeTableLayout;
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:14'
}
PShard >> installReplacement: aReplacementDefinition for: aNode [

	| replacement |
	" if we contain another replacement, uninstall that replacement first "
	self replacements copy do: [:r | (r node hasAnyParent: aNode) ifTrue: [self uninstallReplacement: r]].
	
	replacement := aReplacementDefinition buildReplacement
		definition: aReplacementDefinition;
		editor: self editor;
		node: aNode.
	
	replacements add: replacement
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:08'
}
PShard >> isShowing: aNode [

	(self nodes anySatisfy: [:node | aNode hasAnyParent: node]) ifFalse: [^ false].
	
	self replacements do: [:r | (aNode hasAnyParent: r node) ifTrue: [^ false]].
	
	^ true
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 16:56'
}
PShard >> isShowingIndex: aNumber [

	(self range includes: aNumber) ifFalse: [^ false].
	
	self replacements do: [:r | (r range containsIndex: aNumber) ifTrue: [^ false]].
	
	^ true
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 08:10'
}
PShard >> nodes [

	^ nodes
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 20:51'
}
PShard >> nodes: aCollection [

	nodes := aCollection.
	
	lastActualSourceString ifNil: [
		self editor models keysAndValuesDo: [:model :root |
			self
				updateReplacementsFor: (PEditScript new
					initPos: (Array streamContents: [:s | root firstChildrenInRange: self range do: [:node | s nextPutAll: node initOperations]])
					neg: {})
				root: root].
		self updateText]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:01'
}
PShard >> onChange: aNewString [

	| change |
	change := self
		findChange: lastActualSourceString
		b: aNewString string
		preferredPos: self editor selectionRange first
		preferredSide: nil.
	
	((change includesKey: #delete) and: [(change at: #delete) = Character startOfHeader asString])
		ifTrue: [ | replacement |
			replacement := self replacementForStartIndex: (self adjustLocalIndex: (change at: #from) - 1).
			self editor applyChanges: {
				(PChange range: (replacement range last - 1 to: replacement range last) insert: '')
					sourceShard: self;
					sideAffinity: ((change at: #from) = 1 ifTrue: [1] ifFalse: [-1])}]
		ifFalse: [
			self editor applyChanges: {
				(PChange
					range: ((self adjustLocalIndex: (change at: #from) - 1) to: (self adjustLocalIndex: (change at: #to) - 1))
					insert: (change at: #insert ifAbsent: ['']) string)
					sourceShard: self;
					sideAffinity: ((self isShowingIndex: (change at: #from) - 1)
						ifTrue: [-1]
						ifFalse: [1])}]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:51'
}
PShard >> range [

	^ self editor adjustRange: (PRange indexStart: self nodes first range first end: self nodes last range last)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:15'
}
PShard >> replacementForStartIndex: aNumber [

	^ self replacements detect: [:r | r range first = aNumber]
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/13/2024 10:23'
}
PShard >> replacements [

	^ replacements
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:07'
}
PShard >> requiredModels [

	^ (extensions value gather: [:ext | (ext markerDefinitions collect: #model), (ext replacementDefinitions collect: #model)]) asSet
]

{
	#category : #'marker api',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:49'
}
PShard >> styleAdd: anAttribute for: aNode definition: aDefinition [

	^ attributes add: (PMarker new
		definition: aDefinition;
		node: aNode;
		attribute: anAttribute)
]

{
	#category : #'marker api',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:49'
}
PShard >> styleRemove: aMarker [

	attributes remove: aMarker
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/20/2024 08:14'
}
PShard >> uninstallReplacement: aReplacement [

	aReplacement beforeUninstall.
	
	replacements remove: aReplacement
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:15'
}
PShard >> updateReplacementsFor: anEditScript root: aRoot [

	anEditScript removeDo: [:op |
		self replacements detect: [:r | op node = r node] ifFound: [:r | self uninstallReplacement: r].
		attributes do: [:attr | op node = attr node ifTrue: [attr definition detach value: self value: op node value: attr]]].
	
	extensions value do: [:ext |
		(ext replacementDefinitions select: [:def | def model = aRoot language]) do: [:def |
			self
				allVisibleNodesDo: [:node | | matches |
					matches := (PQuery script: def query with: node) notNil.
					self replacements
						detect: [:r | r definition name = def name and: [node = r node]]
						ifFound: [:r | matches ifFalse: [self uninstallReplacement: r]]
						ifNone: [matches ifTrue: [self installReplacement: def for: node]]]
				root: aRoot]].
	
	extensions value do: [:ext |
		(ext markerDefinitions select: [:def | def model = aRoot language]) do: [:def |
			self
				allVisibleNodesDo: [:node | | matches |
					matches := (PQuery script: def query with: node) notNil.
					attributes
						detect: [:attr | attr definition name = def name and: [node = attr node]]
						ifFound: [:attr | matches ifFalse: [def detach value: self value: node value: attr]]
						ifNone: [matches ifTrue: [def attach value: self value: node]]]
				root: aRoot]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 11:55'
}
PShard >> updateText [

	| out myRange |
	out := (self nodes inject: '' into: [:text :node | text, node sourceString]) asText.
	
	self editor pendingChanges withIndexDo: [:change :index |
		myRange := PRange
			indexStart: (self editor
				adjustIndex: self nodes first range first
				forChangeList: self editor pendingChanges
				upTo: index - 1
				sideAffinity: 1)
			end: (self editor
				adjustIndex: self nodes last range last
				forChangeList: self editor pendingChanges
				upTo: index - 1
				sideAffinity: -1).
		
		" TODO: show subrange if intersects "
		(myRange includesChange: change) ifTrue: [
			self
				updateText: out
				replaceFrom: change from - myRange first + 1
				to: change to - myRange first
				with: change insert]].
	
	myRange := PRange
		indexStart: (self editor
			adjustIndex: self nodes first range first
			forChangeList: self editor pendingChanges
			sideAffinity: 1)
		end: (self editor
			adjustIndex: self nodes last range last
			forChangeList: self editor pendingChanges
			sideAffinity: -1).
	attributes do: [:marker |
		out
			addAttribute: marker attribute
			from: marker node range first - myRange first + 1
			to: marker node range last - myRange first].
	
	replacements do: [:r |
		r localRangeIn: self do: [:from :to |
			out
				replaceFrom: from
				to: to
				with: (Text string: Character startOfHeader asString attribute: r asTextAnchor)]].
	
	view setText: out.
	lastActualSourceString := out string
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 09:44'
}
PShard >> updateText: aText replaceFrom: aNumber to: anotherNumber with: aStringOrNil [

	aNumber <= aText size
		ifTrue: [aText replaceFrom: aNumber to: anotherNumber with: (aStringOrNil ifNil: [''])]
		ifFalse: [
			self assert: (aNumber = (aText size + 1) and: [anotherNumber = (aText size)]).
			aText append: (aStringOrNil ifNil: [''])]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:03'
}
PShard >> view [

	^ view
]
