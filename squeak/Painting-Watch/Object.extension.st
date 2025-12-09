Extension { #name : #Object }

{
	#category : #'*Painting-Watch',
	#'squeak_changestamp' : 'ct 12/9/2025 01:26'
}
Object >> sbWatch [

	PTracer current ifNotNil: [:tracer |
		tracer trace: self from: thisContext home sender].
	^ self
]

{
	#category : #'*Painting-Watch',
	#'squeak_changestamp' : 'ct 12/9/2025 01:25'
}
Object >> sbWatchWithId: id [

	PTracer current ifNotNil: [:tracer |
		tracer trace: self withId: id from: thisContext sender].
	^ self
]
