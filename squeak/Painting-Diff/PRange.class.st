Class {
	#name : #PRange,
	#superclass : #Object,
	#instVars : [
		'start',
		'end'
	],
	#category : #'Painting-Diff'
}

{ #category : #'instance creation' }
PRange class >> fromLSP: aJsonObject [

	^ self
		start: (SBTSPosition fromLSP: (aJsonObject at: 'start'))
		end: ((SBTSPosition fromLSP: (aJsonObject at: 'end')))
]

{ #category : #'instance creation' }
PRange class >> fromLSPWithRange: aJsonObject [

	^ self fromLSP: (aJsonObject at: 'range')
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:21'
}
PRange class >> indexStart: aNumber end: anotherNumber [

	^ self start: (SBTSPosition fromIndex: aNumber) end: (SBTSPosition fromIndex: anotherNumber)
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'tobe 12/8/2025 19:46'
}
PRange class >> interval: anInterval [

	^ self indexStart: anInterval first end: anInterval last
]

{ #category : #'instance creation' }
PRange class >> merging: aCollection [

	| min max |
	min := (aCollection detectMin: [:range | range start index]) start index.
	max := (aCollection detectMax: [:range | range end index]) end index.
	^ SBTSRange start: min size: max - min
]

{ #category : #'instance creation' }
PRange class >> null [

	^ SBTSRange start: SBTSPosition null end: SBTSPosition null
]

{ #category : #'instance creation' }
PRange class >> point: aPoint [

	^ self start: aPoint end: aPoint
]

{ #category : #'instance creation' }
PRange class >> start: aTSPosition end: anotherTSPosition [

	^ self new
		start: aTSPosition;
		end: anotherTSPosition
]

{ #category : #'instance creation' }
PRange class >> start: aNumber size: anotherNumber [

	^ self new
		start: (SBTSPosition line: nil character: nil index: aNumber);
		end: (SBTSPosition line: nil character: nil index: aNumber + anotherNumber)
]

{ #category : #converting }
PRange >> + aDelta [

	^ self class start: self start + aDelta end: self end + aDelta
]

{ #category : #comparing }
PRange >> = anObject [

	self species == anObject species ifFalse: [^ false].
	^ self start = anObject start and: [self end = anObject end]
]

{ #category : #testing }
PRange >> contains: aTSPosition [

	^ self start <= aTSPosition and: [self end >= aTSPosition]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/15/2024 16:48'
}
PRange >> containsIndex: aNumber [

	^ self start index <= aNumber and: [self end index >= aNumber]
]

{
	#category : #testing,
	#'squeak_changestamp' : 'tobe 4/19/2024 18:55'
}
PRange >> containsRange: aRange [

	^ (self contains: aRange start) and: [self contains: aRange end]
]

{ #category : #'as yet unclassified' }
PRange >> distance: aRange [

	^ (self start distance: aRange start) + (self end distance: aRange end)
]

{ #category : #testing }
PRange >> encompasses: aTSRange [

	^ self start <= aTSRange start and: [self end >= aTSRange end]
]

{ #category : #accessing }
PRange >> end [

	^ end
]

{ #category : #accessing }
PRange >> end: aTSPosition [

	end := aTSPosition
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'tobe 4/13/2024 09:36'
}
PRange >> first [

	^ self start index
]

{ #category : #converting }
PRange >> forLSP [

	^ Dictionary newFrom: {'start' -> self start forLSP. 'end' -> self end forLSP}
]

{ #category : #comparing }
PRange >> hash [

	^ self start hash bitXor: self end hash
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:27'
}
PRange >> includes: aNumber [

	^ self containsIndex: aNumber
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/17/2024 08:38'
}
PRange >> includesChange: aChange [

	| endOp |
	endOp := aChange sideAffinity = -1 ifTrue: [#>=] ifFalse: [#>].
	^ (self start index <= aChange from and: [self end index perform: endOp with: aChange from]) and: [self start index <= aChange to and: [self end index perform: endOp with: aChange to]]
]

{ #category : #testing }
PRange >> isEmpty [

	^ self start = self end
]

{ #category : #'as yet unclassified' }
PRange >> isNull [

	^ self start index = 0 and: [self end index = 0]
]

{ #category : #testing }
PRange >> isSingleLine [

	^ start line = end line
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'tobe 4/13/2024 09:37'
}
PRange >> last [

	^ self end index
]

{ #category : #converting }
PRange >> map: aBlock [

	^ self class start: (aBlock value: self start) end: (aBlock value: self end)
]

{ #category : #copying }
PRange >> postCopy [

	super postCopy.
	self
		start: self start copy;
		end: self end copy
]

{ #category : #printing }
PRange >> printOn: aStream [

	aStream
		print: self start;
		nextPutAll: '->';
		print: self end
]

{ #category : #accessing }
PRange >> size [

	^ self end index - self start index
]

{ #category : #accessing }
PRange >> start [

	^ start
]

{ #category : #accessing }
PRange >> start: aTSPosition [

	start := aTSPosition
]

{ #category : #'as yet unclassified' }
PRange >> withSize: aNumber [

	^ self copy end: self start + aNumber
]
