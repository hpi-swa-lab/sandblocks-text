Class {
	#name : #PBaseParser,
	#superclass : #Object,
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 08:21'
}
PBaseParser class >> parse: aString old: aNode [

	| doc |
	doc := PNode new
		type: 'document';
		language: self;
		range: (SBTSRange indexStart: 0 end: aString size);
		privateSource: aString.
	^ doc
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 18:11'
}
PBaseParser class >> rootRuleName [

	^ 'document'
]
