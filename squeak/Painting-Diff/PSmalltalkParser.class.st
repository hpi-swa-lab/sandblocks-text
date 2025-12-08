Class {
	#name : #PSmalltalkParser,
	#superclass : #ParseNodeVisitor,
	#instVars : [
		'currentNode',
		'stack',
		'encoder',
		'source'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 19:32'
}
PSmalltalkParser class >> parse: aString old: aNode [

	^ PNode parseSt: aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 12/8/2025 19:59'
}
PSmalltalkParser class >> rootRuleName [

	^ #method
]

{
	#category : #structure,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:27'
}
PSmalltalkParser >> addChild: aPNode [

	currentNode ifNotNil: [currentNode baseAndMorphAdd: aPNode]
]

{
	#category : #structure,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:59'
}
PSmalltalkParser >> createPNode: aParseNode type: aSymbol [

	^ PNode new
		range: (encoder rawSourceRanges
			at: aParseNode
			ifPresent: [:range | PRange interval: range]
			ifAbsent: [PRange null]);
		language: self class;
		type: aSymbol;
		yourself
]

{
	#category : #structure,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:33'
}
PSmalltalkParser >> createPText: aString [

	^ PText new
		language: self;
		contents: aString;
		yourself
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'tobe 12/8/2025 19:40'
}
PSmalltalkParser >> encoder: anEncoder [

	encoder := anEncoder
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'tobe 12/8/2025 19:22'
}
PSmalltalkParser >> initialize [
	super initialize
]

{
	#category : #structure,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> popNode [

	| popped |
	popped := stack removeLast.
	currentNode := stack ifEmpty: [nil] ifNotEmpty: [stack last].
	^ popped
]

{
	#category : #structure,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> pushNode: aPNode [

	stack addLast: aPNode.
	currentNode := aPNode
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'tobe 12/8/2025 20:00'
}
PSmalltalkParser >> source: aString [

	source := aString
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitAssignmentNode: anAssignmentNode [

	| node |
	node := self createPNode: anAssignmentNode type: #assignment.
	node baseAndMorphAdd: (anAssignmentNode variable accept: self).
	node baseAndMorphAdd: (anAssignmentNode value accept: self).
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitBlockNode: aBlockNode [

	| node |
	node := self createPNode: aBlockNode type: #block.
	
	aBlockNode statements do: [:statement | node baseAndMorphAdd: (statement accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitBraceNode: aBraceNode [

	| node |
	node := self createPNode: aBraceNode type: #brace.
	
	aBraceNode elements do: [:element | node baseAndMorphAdd: (element accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitCascadeNode: aCascadeNode [

	| node |
	node := self createPNode: aCascadeNode type: #cascade.
	
	aCascadeNode receiver ifNotNil: [:receiver | node baseAndMorphAdd: (receiver accept: self)].
	aCascadeNode messages do: [:message | node baseAndMorphAdd: (message accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitCommentNode: aCommentNode [

	| text |
	text := self createPText: aCommentNode comment.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitFieldNode: aFieldNode [

	| text |
	text := self createPText: aFieldNode key asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:28'
}
PSmalltalkParser >> visitFutureNode: aFutureNode [

	| node |
	node := self createPNode: aFutureNode type: #future.
	aFutureNode receiver ifNotNil: [:receiver | node baseAndMorphAdd: (receiver accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitInstanceVariableNode: anInstanceVariableNode [

	| text |
	text := self createPText: anInstanceVariableNode name asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitLiteralNode: aLiteralNode [

	| text |
	text := self createPText: aLiteralNode key asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitLiteralVariableNode: aLiteralVariableNode [

	| text |
	text := self createPText: aLiteralVariableNode name asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitMessageNode: aMessageNode [

	| node |
	node := self createPNode: aMessageNode type: #message.
	
	aMessageNode receiver ifNotNil: [:receiver | node baseAndMorphAdd: (receiver accept: self)].
	aMessageNode selector ifNotNil: [:selector | node baseAndMorphAdd: (self createPText: selector asString)].
	aMessageNode arguments do: [:argument | node baseAndMorphAdd: (argument accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitMessageNodeInCascade: aMessageNode [

	| node |
	node := self createPNode: aMessageNode type: #messageInCascade.
	
	aMessageNode selector ifNotNil: [:selector | node baseAndMorphAdd: (self createPText: selector asString)].
	aMessageNode arguments do: [:argument | node baseAndMorphAdd: (argument accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 20:00'
}
PSmalltalkParser >> visitMethodNode: aMethodNode [

	| node |
	node := self createPNode: aMethodNode type: #method.
	node privateSource: source.
	
	node baseAndMorphAdd: (self createPText: aMethodNode selector asString).
	node baseAndMorphAdd: (aMethodNode block accept: self).
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitNewArrayNode: aNewArrayNode [

	| node |
	node := self createPNode: aNewArrayNode type: #newArray.
	
	aNewArrayNode elements do: [:element | node baseAndMorphAdd: (element accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitRemoteTempVectorNode: aRemoteTempVectorNode [

	| node |
	node := self createPNode: aRemoteTempVectorNode type: #remoteTempVector.
	
	aRemoteTempVectorNode remoteTemps do: [:temp | node baseAndMorphAdd: (temp accept: self)].
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitReturnNode: aReturnNode [

	| node |
	node := self createPNode: aReturnNode type: #return.
	
	node baseAndMorphAdd: (aReturnNode expr accept: self).
	
	^ node
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitSelectorNode: aSelectorNode [

	| text |
	text := self createPText: aSelectorNode key asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitTempVariableNode: aTempVariableNode [

	| text |
	text := self createPText: aTempVariableNode name asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitUndeclaredVariableNode: anUndeclaredVariableNode [

	| text |
	text := self createPText: anUndeclaredVariableNode name asString.
	self addChild: text.
	^ text
]

{
	#category : #visiting,
	#'squeak_changestamp' : 'tobe 12/8/2025 19:29'
}
PSmalltalkParser >> visitVariableNode: aVariableNode [

	| text |
	text := self createPText: aVariableNode name asString.
	self addChild: text.
	^ text
]
