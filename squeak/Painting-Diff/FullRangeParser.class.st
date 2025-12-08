Class {
	#name : #FullRangeParser,
	#superclass : #Parser,
	#category : #'Painting-Diff'
}

{
	#category : #'expression types',
	#'squeak_changestamp' : 'ct 12/8/2025 21:03'
}
FullRangeParser >> assignment: varNode [

	^ (super assignment: varNode)
		ifTrue:
			[encoder noteSourceRange: ((encoder sourceRangeFor: varNode) start to: self endOfLastToken) forNode: parseNode];
		yourself
]

{
	#category : #'expression types',
	#'squeak_changestamp' : 'ct 12/8/2025 21:01'
}
FullRangeParser >> braceExpression [

	| start |
	start := self startOfNextToken.
	super braceExpression.
	encoder noteSourceRange: (start to: self endOfLastToken) forNode: parseNode.
]

{
	#category : #'expression types',
	#'squeak_changestamp' : 'ct 12/8/2025 21:00'
}
FullRangeParser >> cascade [

	| start |
	start := self startOfNextToken.
	super cascade.
	encoder noteSourceRange: (start to: self endOfLastToken) forNode: parseNode.
]

{
	#category : #'expression types',
	#'squeak_changestamp' : 'ct 12/8/2025 20:44'
}
FullRangeParser >> messagePart: level repeat: repeat [

	| start receiver selector args precedence words keywordStart |
	[receiver := parseNode.
	(hereType == #keyword and: [level >= 3])
		ifTrue: 
			[start := self startOfNextToken.
			selector := WriteStream on: (String new: 32).
			args := OrderedCollection new.
			words := OrderedCollection new.
			[hereType == #keyword]
				whileTrue: 
					[keywordStart := self startOfNextToken + requestorOffset.
					selector nextPutAll: self advance.
					words addLast: (keywordStart to: self endOfLastToken + requestorOffset).
					self primaryExpression ifFalse: [^self expected: 'Argument'].
					self messagePart: 2 repeat: true.
					args addLast: parseNode].
			selector := (Symbol lookup: selector contents)
				ifNil: [ self correctSelector: selector contents
							wordIntervals: words
							exprInterval: (start to: self endOfLastToken)
							ifAbort: [ ^ self fail ] ].
			precedence := 3]
		ifFalse: [
			(level >= 2 and: [hereType == #verticalBar]) ifTrue: [self transformAVerticalBarIntoABinarySelector].
			(hereType == #binary and: [level >= 2])
				ifTrue: 
					[start := self startOfNextToken.
					selector := self advance asOctetString asSymbol.
					self primaryExpression ifFalse: [^self expected: 'Argument'].
					self messagePart: 1 repeat: true.
					args := Array with: parseNode.
					precedence := 2]
				ifFalse: [hereType == #word
						ifTrue: 
							[start := self startOfNextToken.
							selector := self advance.
							args := #().
							words := OrderedCollection with: (start  + requestorOffset to: self endOfLastToken + requestorOffset).
							selector := (Symbol lookup: selector)
								ifNil: [ self correctSelector: selector
											wordIntervals: words
											exprInterval: (start to: self endOfLastToken)
											ifAbort: [ ^ self fail ] ].
							precedence := 1]
						ifFalse: [^args notNil]]].
	parseNode := MessageNode new
				receiver: receiver
				selector: selector
				arguments: args
				precedence: precedence
				from: encoder
				sourceRange: ((encoder sourceRangeFor: receiver) start to: self endOfLastToken).
	encoder noteSourceRange: (encoder sourceRangeFor: parseNode) forNode: parseNode selector.
	repeat]
		whileTrue: [].
	^true
]

{
	#category : #'expression types',
	#'squeak_changestamp' : 'ct 12/8/2025 20:49'
}
FullRangeParser >> method: doit context: ctxt [ 

	| method |
	method := super method: doit context: ctxt.
	encoder noteSourceRange: (1 to: hereMark - 1) forNode: method.
	encoder noteSourceRange: (1 to: hereMark - 1) forNode: method block. "hm"
	^ method
]

{
	#category : #'expression types',
	#'squeak_changestamp' : 'tobe 12/8/2025 21:21'
}
FullRangeParser >> primaryExpression [ 
	| start |
	hereType == #word 
		ifTrue: 
			[parseNode := self variable.
			(parseNode isUndefTemp
			 and: [(#(ifNil: ifNotNil: isNil notNil) includes: here) not
			 and: [self interactive]])
				ifTrue:
					[self queryUndefined].
			parseNode nowHasRef.
			^ true].
	hereType == #leftBracket
		ifTrue: 
			[self advance.
			self blockExpression.
			^true].
	hereType == #leftBrace
		ifTrue: 
			[self braceExpression.
			^true].
	hereType == #leftParenthesis
		ifTrue: 
			[start := self startOfNextToken.
			self advance.
			self expression ifFalse: [^self expected: 'expression'].
			(self match: #rightParenthesis)
				ifFalse: [^self expected: 'right parenthesis'].
			parseNode := BracketNode new
				expr: parseNode
				encoder: encoder
				sourceRange: (start to: self endOfLastToken).
			^true].
	(hereType == #string or: [hereType == #number or: [hereType == #literal or: [hereType == #character]]])
		ifTrue: 
			[start := self startOfNextToken.
			parseNode := encoder encodeLiteral: self advance.
			encoder noteSourceRange: (start to: self endOfLastToken) forNode: parseNode.
			^true].
	(here == #- and: [tokenType == #number and: [1 + hereEnd = mark]])
		ifTrue: 
			[self advance.
			parseNode := encoder encodeLiteral: self advance negated.
			^true].
	^false
]
