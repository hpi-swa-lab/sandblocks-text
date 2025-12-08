Class {
	#name : #PPosition,
	#superclass : #Magnitude,
	#instVars : [
		'line',
		'character',
		'index'
	],
	#category : #'Painting-Diff'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:21'
}
PPosition class >> fromIndex: aNumber [

	^ self line: -1 character: -1 index: aNumber
]

{ #category : #'instance creation' }
PPosition class >> fromIndex: aNumber in: aString [

	| lines |
	"aNumber = 1 is before the first character"
	lines := (aString take: aNumber - 1) lines.
	lines ifEmpty: [lines := {''}].
	^ self line: lines size - 1 character: lines last size index: aNumber
]

{ #category : #'instance creation' }
PPosition class >> fromLSP: aJsonObject [

	^ self line: (aJsonObject at: 'line') character: (aJsonObject at: 'character')
]

{ #category : #'instance creation' }
PPosition class >> line: aNumber character: anotherNumber [

	^ self new line: aNumber character: anotherNumber
]

{ #category : #'instance creation' }
PPosition class >> line: aNumber character: anotherNumber index: aThirdNumber [

	^ self new line: aNumber character: anotherNumber index: aThirdNumber
]

{ #category : #'instance creation' }
PPosition class >> null [

	^ self line: 0 character: 0 index: 0
]

{ #category : #mutating }
PPosition >> + aNumber [
	"advance the character index, does not consider line breaks"

	^ self copy
		line: line
		character: (character ifNotNil: [character + aNumber])
		index: index + aNumber
]

{ #category : #converting }
PPosition >> - aPosition [

	self assert: aPosition line = self line.
	^ self character - aPosition character
]

{ #category : #comparing }
PPosition >> < aTSPosition [

	(self index notNil and: [aTSPosition index notNil]) ifTrue: [^ self index < aTSPosition index].
	
	^ self line < aTSPosition line or: [self line = aTSPosition line and: [self character < aTSPosition character]]
]

{ #category : #comparing }
PPosition >> = anObject [

	self species == anObject species ifFalse: [^ false].
	(self index notNil and: [anObject index notNil]) ifTrue: [^ self index = anObject index].
	^ self line = anObject line and: [self character = anObject character]
]

{ #category : #converting }
PPosition >> asIndexIn: aString [

	| index lineIndex |
	index := 0.
	lineIndex := 0.
	aString lineIndicesDo: [:start :endWithoutDelimiters :end |
		lineIndex < self line ifTrue: [index := end].
		lineIndex := lineIndex + 1].
	^ index + (self character + 1)
]

{ #category : #accessing }
PPosition >> character [

	^ character
]

{ #category : #accessing }
PPosition >> column [

	^ self character
]

{ #category : #'as yet unclassified' }
PPosition >> distance: aPoint [

	(aPoint line isNil or: [self line isNil]) ifTrue: ["FIXME: not the right solution, but we usually dont want to compare these"
	^ Float infinity].
	
	^ self line = aPoint line
		ifTrue: [(aPoint character - self character) abs]
		ifFalse: [ | a b width |
			width := 60.
			a := self min: aPoint.
			b := self max: aPoint.
			width - a character + b character + (b line - a line - 1 * width)]
]

{ #category : #converting }
PPosition >> end [

	^ self
]

{ #category : #converting }
PPosition >> forLSP [

	^ Dictionary newFrom: {'line' -> self line. 'character' -> self character}
]

{ #category : #comparing }
PPosition >> hash [

	^ self line hash bitXor: self character hash
]

{ #category : #accessing }
PPosition >> index [

	^ index
]

{ #category : #accessing }
PPosition >> line [

	^ line
]

{ #category : #accessing }
PPosition >> line: aNumber character: anotherNumber [

	line := aNumber.
	character := anotherNumber
]

{ #category : #accessing }
PPosition >> line: aNumber character: anotherNumber index: aThirdNumber [

	line := aNumber.
	character := anotherNumber.
	index := aThirdNumber
]

{ #category : #offsetting }
PPosition >> offsetBy: aTSPosition [

	^ self class line: self line + aTSPosition line character: (aTSPosition line > 0
		ifTrue: [aTSPosition character]
		ifFalse: [self character + aTSPosition character])
]

{ #category : #printing }
PPosition >> printOn: aStream [

	aStream nextPutAll: '(line='.
	aStream print: self line.
	aStream nextPutAll: ',char='.
	aStream print: self character.
	index ifNotNil: [
		aStream nextPutAll: ',index='.
		aStream print: self index].
	aStream nextPut: $)
]

{ #category : #offsetting }
PPosition >> relativeTo: aTSPosition [

	^ self class line: self line - aTSPosition line character: (self line = aTSPosition line
		ifTrue: [self character - aTSPosition character]
		ifFalse: [self character])
]

{ #category : #converting }
PPosition >> start [

	^ self
]
