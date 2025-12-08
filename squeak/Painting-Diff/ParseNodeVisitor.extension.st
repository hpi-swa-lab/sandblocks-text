Extension { #name : #ParseNodeVisitor }

{
	#category : #'*Painting-Diff-visiting',
	#'squeak_changestamp' : 'ct 12/8/2025 21:15'
}
ParseNodeVisitor >> visitBracketNode: aReturnNode [
	aReturnNode expr accept: self
]
