Class {
	#name : #PShard,
	#superclass : #Morph,
	#instVars : [
		'nodes',
		'view',
		'editor',
		'extensions',
		'replacements',
		'lastActualSourceString'
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
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PShard >> allVisibleNodesDo: aBlock [

	| replaced |
	replaced := self replacements collect: #node.
	self nodes do: [:root | root allVisibleNodesDo: aBlock hidden: replaced]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:42'
}
PShard >> applyChanges: aCollection editScript: aScript [

	self basicApplyChanges: aCollection editScript: aScript.
	
	self updateReplacementsFor: aScript
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:54'
}
PShard >> applyRejectedChanges: aCollection [

	self basicApplyChanges: aCollection editScript: nil
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:42'
}
PShard >> basicApplyChanges: aCollection editScript: aScript [

	(aCollection reject: [:change | change sourceShard = self]) do: [:change |
		view handleEdit: [
			view
				selectInvisiblyFrom: (self adjustGlobalIndex: change from) + 1
					to: (self adjustGlobalIndex: change to);
				replaceSelectionWith: (change insert ifNil: [''])]]
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
	#'squeak_changestamp' : 'tobe 4/13/2024 08:10'
}
PShard >> editor: anEditor [

	anEditor shards add: self.
	editor := anEditor
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 10:13'
}
PShard >> extensions: aBlock [

	extensions := aBlock
]

{
	#category : #utils,
	#'squeak_changestamp' : 'tobe 4/13/2024 08:29'
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
				#insert -> (anotherString copyFrom: (diff at: #from) to: (diff at: #toB) - 1).
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
	#'squeak_changestamp' : 'tobe 4/15/2024 14:01'
}
PShard >> initialize [

	super initialize.
	
	replacements := SortedCollection sortBlock: [:a :b | a range first < b range first].
	extensions := [{}].
	
	self
		addMorph: (view := PluggableTextMorphPlus new
			setSelection: (0 to: 0);
			model: self;
			editTextSelector: #onChange:;
			setText: '';
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			yourself);
		changeTableLayout;
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
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 08:10'
}
PShard >> nodes [

	^ nodes
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 14:00'
}
PShard >> nodes: aCollection [

	nodes := aCollection.
	
	lastActualSourceString ifNil: [
		self
			applyChanges: {
				PChange
					range: (nodes first range first to: nodes last range last)
					insert: (nodes inject: '' into: [:s :n | s, n sourceString])}
			editScript: (PEditScript new initPos: (nodes gather: #initOperations) neg: {})]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:16'
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
				(PChange range: (replacement range last - 1 to: replacement range last) insert: '') sourceShard: self}]
		ifFalse: [
			self editor applyChanges: {
				(PChange
					range: ((self adjustLocalIndex: (change at: #from) - 1) to: (self adjustLocalIndex: (change at: #to) - 1))
					insert: (change at: #insert ifAbsent: ['']) string) sourceShard: self}].
	
	
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:53'
}
PShard >> range [

	^ self nodes first range first to: self nodes last range last
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
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:26'
}
PShard >> uninstallReplacement: aReplacement [

	aReplacement beforeUninstall.
	
	replacements remove: aReplacement
]

{
	#category : #replacements,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:11'
}
PShard >> updateReplacementsFor: anEditScript [

	anEditScript removeDo: [:op |
		self replacements
			detect: [:r | op node = r node]
			ifFound: [:r | self uninstallReplacement: r]].
	
	extensions value do: [:ext |
		ext replacementDefinitions do: [:def |
			self allVisibleNodesDo: [:node | | matches |
				matches := (DCQuery script: def query with: node) notNil.
				self replacements
					detect: [:r | r definition name = def name and: [node = r node]]
					ifFound: [:r | matches ifFalse: [self uninstallReplacement: r]]
					ifNone: [matches ifTrue: [self installReplacement: def for: node]]]]].
	
	self updateText
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:05'
}
PShard >> updateText [

	| out |
	out := (self nodes inject: '' into: [:text :node | text, node sourceString]) asText.
	
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
	#'squeak_changestamp' : 'tobe 4/13/2024 10:03'
}
PShard >> view [

	^ view
]
