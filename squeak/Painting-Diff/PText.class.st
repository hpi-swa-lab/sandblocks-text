Class {
	#name : #PText,
	#superclass : #PNode,
	#instVars : [
		'contents'
	],
	#category : #'Painting-Diff'
}

{ #category : #'as yet unclassified' }
PText >> alias [

	^ nil
]

{ #category : #'base accessing' }
PText >> allBaseChildrenDo: aBlock [

	aBlock value: self
]

{ #category : #'base accessing' }
PText >> allBaseChildrenExceptSelfDo: aBlock [

	
]

{ #category : #hierarchy }
PText >> allParentsUpTo: aBlock [

	^ {self parent}, (self parent allParentsUpTo: aBlock)
]

{ #category : #'base accessing' }
PText >> baseChildren [

	^ #()
]

{ #category : #'base accessing' }
PText >> baseMorph [

	^ self replacedParent ifNotNil: [:p | p baseMorph] ifNil: [self]
]

{ #category : #'base accessing' }
PText >> baseParent [

	^ baseParent
]

{ #category : #'base accessing' }
PText >> baseParent: aNode [

	baseParent := aNode
]

{ #category : #'base accessing' }
PText >> baseRemoveFromParent [

	self parent baseChildren remove: self.
	self baseParent: nil
]

{ #category : #'base accessing' }
PText >> baseSiblingIndex [

	| i |
	i := 1.
	self baseParent baseChildren do: [:c |
		c = self ifTrue: [^ i].
		i := i + 1].
	^ 0
]

{ #category : #'as yet unclassified' }
PText >> baseTreeHeight [

	^ 0
]

{ #category : #'as yet unclassified' }
PText >> childrenDo: aBlock [
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:32'
}
PText >> clearDiffCache [

	literalMatch := nil
]

{ #category : #'as yet unclassified' }
PText >> compatibleWithType: aSymbol [

	^ false
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:50'
}
PText >> contents [

	^ contents
]

{
	#category : #'base accessing',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:50'
}
PText >> contents: aString [

	contents := aString
]

{ #category : #'as yet unclassified' }
PText >> doubleClick: anEvent [

	self parent doubleClick: anEvent
]

{ #category : #'as yet unclassified' }
PText >> effectiveContents [

	^ self contents
]

{ #category : #'as yet unclassified' }
PText >> emphasis [

	^ #derive
]

{ #category : #'as yet unclassified' }
PText >> ensureLayouted [

	self owner ensureLayouted
]

{ #category : #'as yet unclassified' }
PText >> ensureReplacement: aClass initDo: aBlock [

	self queryState ensureReplacement: aClass for: self embed: [:m | {}] initDo: aBlock
]

{ #category : #'as yet unclassified' }
PText >> field [

	^ field
]

{ #category : #'as yet unclassified' }
PText >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
PText >> firstSourceCharacter [

	^ self contents size > 0 ifTrue: [self contents first] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
PText >> foregroundColor [

	^ self containingSandblock colorPolicy foregroundColorForBlock: self
]

{ #category : #hierarchy }
PText >> hasAnyParent: aBlock [

	self parent = aBlock ifTrue: [^ true].
	^ self parent hasAnyParent: aBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 13:56'
}
PText >> initOperations [

	^ {PLoadOp new node: self. PAttachOp new node: self parent: self baseParent index: self baseSiblingIndex}
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 13:51'
}
PText >> initialize [

	super initialize.
	
	contents := ''.
	range := PRange null
]

{ #category : #'as yet unclassified' }
PText >> is: aCollectionOrSymbol [

	^ false
]

{ #category : #'as yet unclassified' }
PText >> isExpression [

	^ false
]

{ #category : #'as yet unclassified' }
PText >> isExtra [
	"TODO: use language isExtra: instead"

	^ self treeLabel notEmpty and: [self treeLabel allSatisfy: [:x | x isSeparator]]
]

{ #category : #'as yet unclassified' }
PText >> isFirstChild [

	^ self siblingIndex = 1
]

{ #category : #'as yet unclassified' }
PText >> isReplacement [

	^ false
]

{ #category : #'as yet unclassified' }
PText >> isRootBlock [

	^ false
]

{ #category : #'as yet unclassified' }
PText >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
PText >> isTSSymbol [
	^false
]

{ #category : #'as yet unclassified' }
PText >> isTextMorph [

	^ (self contents allSatisfy: [:t | t = Character tab]) not or: [self contents isEmpty]
]

{ #category : #'as yet unclassified' }
PText >> language [

	^ self parent language
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'tobe 4/13/2024 14:38'
}
PText >> lastDeepChild [

	^ self
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 21:52'
}
PText >> literalHash [

	^ self contents hash
]

{ #category : #'as yet unclassified' }
PText >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:30'
}
PText >> parent [

	^ self baseParent
]

{ #category : #'as yet unclassified' }
PText >> parentNode [

	^ self owner
]

{ #category : #'as yet unclassified' }
PText >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
PText >> printOn: aStream [

	aStream nextPutAll: ('"{1}"' format: {self contents})
]

{ #category : #'as yet unclassified' }
PText >> printTreeOn: aStream indent: aNumber [

	aNumber timesRepeat: [aStream tab].
	aStream nextPutAll: '"'.
	aStream nextPutAll: self contents.
	aStream nextPutAll: '"'
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:30'
}
PText >> queryState [

	^ nil
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 11:07'
}
PText >> range [

	^ range isNull ifTrue: [self parent range] ifFalse: [range]
]

{ #category : #'as yet unclassified' }
PText >> range: aRange [

	range := aRange
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:28'
}
PText >> shallowCopyBlock [

	^ self class new
		range: range;
		contents: contents;
		field: field
]

{ #category : #'as yet unclassified' }
PText >> showInQuery [

	^ true
]

{ #category : #'as yet unclassified' }
PText >> shownColor [

	^ self containingSandblock shownColor
]

{ #category : #hierarchy }
PText >> siblingIndex [

	| i |
	i := 1.
	self parent childrenDo: [:c |
		c = self ifTrue: [^ i].
		i := i + 1].
	^ 0
]

{ #category : #'as yet unclassified' }
PText >> statementWithTerminatorRange [

	^ self range
]

{
	#category : #diffing,
	#'squeak_changestamp' : 'tobe 12/8/2025 21:52'
}
PText >> structureHash [
	" arbitrary non-null number to identity the existence of this node "

	^ 7
]

{ #category : #'as yet unclassified' }
PText >> treeHash [

	^ self treeHashCount: {0}
]

{ #category : #'as yet unclassified' }
PText >> treeHashCount: aPtr [

	^ ((self contents hash bitXor: 'LABEL_ENTER' hash) bitXor: aPtr first * 2 + 1) bitXor: 'LABEL_LEAVE' hash
]

{ #category : #'as yet unclassified' }
PText >> treeLabel [

	^ self contents
]

{ #category : #'as yet unclassified' }
PText >> type [

	^ ''
]

{ #category : #'as yet unclassified' }
PText >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream hasLineInfo ifTrue: [
		range start
			line: aStream currentLine
			character: aStream currentIndexInLine
			index: aStream position].
	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents]).
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine index: aStream position]
]
