Class {
	#name : #PWhitespaceParser,
	#superclass : #Object,
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:23'
}
PWhitespaceParser class >> parse: aString old: aNode [

	| doc stream |
	doc := PNode new
		type: 'document';
		language: self;
		range: (PRange indexStart: 0 end: aString size);
		privateSource: aString.
	
	stream := aString readStream.
	[stream atEnd] whileFalse: [ | c node type |
		c := stream next.
		node := PText new contents: ''.
		type := #text.
		c
			caseOf: {
				[Character tab] -> [
					node contents: c asString.
					type := #tab].
				[Character cr] -> [
					node contents: c asString.
					type := #newline]}
			otherwise: [[({Character tab. Character cr} includes: stream peek) or: [stream atEnd]] whileFalse: [node contents: node contents, stream next]].
		node range: (PRange indexStart: stream position - node contents size end: stream position).
		doc appendBaseChild: (PNode new
			type: type;
			language: self;
			range: node range;
			appendBaseChild: node)].
	
	^ doc
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:11'
}
PWhitespaceParser class >> rootRuleName [

	^ 'document'
]
