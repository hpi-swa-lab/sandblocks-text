Class {
	#name : #PChange,
	#superclass : #Object,
	#instVars : [
		'from',
		'to',
		'insert',
		'sourceShard'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:53'
}
PChange class >> range: aRange insert: aString [

	^ self new
		from: aRange first;
		to: aRange last;
		insert: aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 09:40'
}
PChange >> applyTo: aString [

	^ (aString copyFrom: 1 to: self from), (self insert ifNil: ['']), (aString copyFrom: self to + 1 to: aString size)
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> from [

	^ from
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> from: aNumber [

	from := aNumber
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> insert [

	^ insert
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> insert: aString [

	insert := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 09:55'
}
PChange >> sourceShard [

	^ sourceShard
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 09:55'
}
PChange >> sourceShard: aShard [

	sourceShard := aShard
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> to [

	^ to
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/12/2024 10:46'
}
PChange >> to: aNumber [

	to := aNumber
]
