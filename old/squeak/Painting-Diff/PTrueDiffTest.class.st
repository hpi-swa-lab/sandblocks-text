Class {
	#name : #PTrueDiffTest,
	#superclass : #SBTest,
	#category : #'Painting-Diff'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:39'
}
PTrueDiffTest >> testAddStatement [

	| a b new program first last |
	a := PNode parse: '1;2' language: SBJavascript.
	program := a.
	first := a children first.
	last := a children last.
	b := PNode parse: '1;a;2' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: first identical: new children first.
	self assert: last identical: new children last
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:40'
}
PTrueDiffTest >> testDiffNestedNodes [

	| old new pair |
	old := PNode parse: 'a+b' language: SBJavascript.
	new := PNode parse: 'ab+b' language: SBJavascript.
	
	pair := PTrueDiff new compare: old to: new.
	self assert: 1 equals: pair second posBuf size
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:40'
}
PTrueDiffTest >> testDiffToplevelNodes [

	| old new pair |
	old := PNode parse: 'a' language: SBJavascript.
	new := PNode parse: 'ab' language: SBJavascript.
	
	pair := PTrueDiff new compare: old to: new.
	self assert: 1 equals: pair second posBuf size
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:39'
}
PTrueDiffTest >> testKeepIdentityLeafAdd [

	| a b new program array one |
	a := PNode parse: '[1,]' language: SBJavascript.
	program := a.
	array := program children first children first.
	one := array children second.
	b := PNode parse: '[1,2]' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: one identical: new children first children first children second.
	self assert: array identical: new children first children first
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:39'
}
PTrueDiffTest >> testKeepIdentityLeafRemove [

	| a b new program array one |
	a := PNode parse: '[1,2]' language: SBJavascript.
	program := a.
	array := program children first children first.
	one := array children second.
	b := PNode parse: '[1,]' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: one identical: new children first children first children second
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:39'
}
PTrueDiffTest >> testKeepIdentityLeafUpdate [

	| a b new program add |
	a := PNode parse: '2+3' language: SBJavascript.
	program := a.
	add := program children first children first.
	b := PNode parse: '2+4' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: add identical: new children first children first.
	self assert: new children first children first children last children first contents equals: '4'
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:38'
}
PTrueDiffTest >> testKeepIdentityMove [

	| a b new program add |
	a := PNode parse: '2+2' language: SBJavascript.
	program := a.
	add := program children first children first.
	b := PNode parse: '(2+2)' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: add identical: new children first children first children second
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 14:37'
}
PTrueDiffTest >> testUpdateBoolean [

	| a b new program id stmt |
	a := PNode parse: 'a' language: SBJavascript.
	program := a.
	stmt := a baseChildren first.
	id := a baseChildren first baseChildren first.
	b := PNode parse: 'a;' language: SBJavascript.
	
	new := (PTrueDiff new compare: a to: b) first.
	
	self assert: program identical: new.
	self assert: id identical: new baseChildren first baseChildren first
]
