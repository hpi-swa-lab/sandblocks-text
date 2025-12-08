"
I represent an expression of the form ^expr.
"
Class {
	#name : #BracketNode,
	#superclass : #ParseNode,
	#instVars : [
		'expr'
	],
	#category : #'Painting-Diff',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #visiting,
	#'squeak_changestamp' : 'ct 12/8/2025 21:15'
}
BracketNode >> accept: aVisitor [
	^aVisitor visitBracketNode: self
]

{
	#category : #'closure analysis',
	#'squeak_changestamp' : 'eem 7/24/2009 09:44'
}
BracketNode >> analyseTempsWithin: scopeBlock "<BlockNode>" rootNode: rootNode "<MethodNode>" assignmentPools: assignmentPools [ "<Dictionary>"
	"Note we could do this:
		scopeBlock ~~ rootNode block ifTrue:
			[scopeBlock noteNonLocalReturn].
	 and pass up the flag in <BlockNode>>>analyseTempsWithin:rootNode:
	 which may be fast but will also give less information the debugger.
	 For now we consider clean blocks a premature optimization."
	self flag: 'consider clean blocks'.
	expr analyseTempsWithin: scopeBlock rootNode: rootNode assignmentPools: assignmentPools
]

{ #category : #'code generation' }
BracketNode >> code [

	^expr code
]

{
	#category : #printing,
	#'squeak_changestamp' : 'yo 8/2/2004 17:21'
}
BracketNode >> expr [

	^ expr.

]

{ #category : #'initialize-release' }
BracketNode >> expr: e [

	expr := e
]

{ #category : #'initialize-release' }
BracketNode >> expr: e encoder: encoder sourceRange: range [

	expr := e.
	encoder noteSourceRange: range forNode: self
]

{ #category : #testing }
BracketNode >> isSpecialConstant [

	^expr isSpecialConstant
]

{ #category : #testing }
BracketNode >> isVariableReference [

	^expr isVariableReference
]

{
	#category : #printing,
	#'squeak_changestamp' : 'ct 12/8/2025 21:16'
}
BracketNode >> printOn: aStream indent: level [

	aStream nextPut: $(.
	expr printOn: aStream indent: level.
	expr printCommentOn: aStream indent: level.
	aStream nextPut: $).
]

{
	#category : #printing,
	#'squeak_changestamp' : 'ct 12/8/2025 21:17'
}
BracketNode >> printWithClosureAnalysisOn: aStream indent: level [

	aStream nextPut: $(.
	expr printWithClosureAnalysisOn: aStream indent: level.
	expr printCommentOn: aStream indent: level.
	aStream nextPut: $).
]
