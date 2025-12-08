Extension { #name : #ParseNodeEnumerator }

{
	#category : #'*Painting-Diff-visiting',
	#'squeak_changestamp' : 'ct 12/8/2025 21:16'
}
ParseNodeEnumerator >> visitBracketNode: aBracketNode [
	(theSelectBlock isNil or: [theSelectBlock value: aBracketNode]) ifFalse:
		[^nil].
	theBlock value: aBracketNode.
	^super visitReturnNode: aBracketNode
]
