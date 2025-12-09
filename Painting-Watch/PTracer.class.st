Class {
	#name : #PTracer,
	#superclass : #Object,
	#instVars : [
		'methods',
		'values'
	],
	#classVars : [
		'Current'
	],
	#category : #'Painting-Watch'
}

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 7/7/2025 17:21'
}
PTracer class >> current [

	^ Current
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 7/7/2025 18:36'
}
PTracer class >> current: aTracerOrNil [

	Current := aTracerOrNil.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 7/7/2025 17:23'
}
PTracer class >> current: aTracer during: aBlock [

	| previous |
	previous := self current.
	Current := aTracer.
	^ aBlock ensure:
		[Current := previous]
]

{
	#category : #tracing,
	#'squeak_changestamp' : 'ct 7/7/2025 20:23'
}
PTracer class >> disableTracingDuring: aBlock [

	^ self current: nil during: aBlock
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/9/2025 01:25'
}
PTracer class >> test [

	| x y |
	x := 1 sbWatchWithId: 1.
	y := 2 sbWatchWithId: 2.
	^ (x + y) sbWatchWithId: 3
]

{
	#category : #tracing,
	#'squeak_changestamp' : 'ct 7/7/2025 17:22'
}
PTracer class >> trace: aBlock [

	| tracer |
	tracer := self new.
	self current: tracer during: aBlock.
	^ tracer
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'ct 7/7/2025 17:29'
}
PTracer >> initialize [

	super initialize.
	methods := Dictionary new.
	values := Dictionary new.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 12/9/2025 01:41'
}
PTracer >> reset [

	methods removeAll.
	values removeAll.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 12/9/2025 01:50'
}
PTracer >> trace: value from: aContext [

	self halt
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 12/9/2025 01:48'
}
PTracer >> trace: value withId: id from: aContext [

	| method |
	method := aContext homeMethod.
	methods at: id ifPresent: [:existingMethod | existingMethod = method ifFalse: [self error: 'This trace id is already used for another method: ' , existingMethod]] ifAbsentPut: [method].
	(values at: id ifAbsentPut: OrderedCollection new)
		addLast: value.
	
	self triggerEvent: #traced.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 12/9/2025 01:39'
}
PTracer >> valueForId: id ifPresent: presentBlock ifAbsent: absentBlock [

	^ self values
		at: id
		ifPresent: presentBlock
		ifAbsent: absentBlock
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 12/9/2025 01:39'
}
PTracer >> values [

	^ values
]
