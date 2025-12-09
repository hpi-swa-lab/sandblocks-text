Class {
	#name : #PEditorState,
	#superclass : #Morph,
	#instVars : [
		'sourceString',
		'rootShard',
		'shards',
		'validationBlocks',
		'pendingChanges',
		'pendingChangesRevert',
		'models'
	],
	#category : #'Painting-Editor'
}

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/9/2025 02:00'
}
PEditorState class >> example [

	| e testExt container |
	testExt := PExtension new registerReplacement: (PReplacementDefinition new
		name: 'test';
		model: PSmalltalkParser;
		query: {[:x | x type = #message and: [x baseChildren second contents = '{sbWatchWithId:}']]};
		init: [:node :replacement |
			replacement color: Color veryDarkGray.
			replacement layoutInset: 1 px.
			replacement
				addMorphBack: replacement createShard;
				addMorphBack: (TextMorph new color: Color white; lock; hResizing: #shrinkWrap)]
			update: [:node :replacement | | watchId updateWatch |
				replacement firstSubmorph nodes: {node baseChildren first}.
				watchId := node baseChildren third contents asInteger.
				updateWatch := [
					replacement submorphs second contents:
						(PTracer current ifNil: ['(not watching)'] ifNotNil: [:tracer |
							tracer
								valueForId: watchId
								ifPresent: [:value | value asArray printString]
								ifAbsent: ['(not yet watched)']])].
				updateWatch value.
				PTracer current ifNotNil: [:tracer |
					tracer when: #traced send: #value to: updateWatch.
					(replacement valueOfProperty: #watchTracerReceivers ifAbsentPut: [Dictionary new])
						at: watchId put: updateWatch]]
			delete: [:node :replacement | | watchId |
				watchId := node baseChildren third contents asInteger.
				(replacement valueOfProperty: #watchTracerReceivers)
					removeKey: watchId]).
	
	e := PEditorState new.
	e rootShard extensions: [{testExt}].
	e sourceString: 'test

	3 + ((2 +
	8) sbWatchWithId: 1).
	1 to: 3 do: [:i | ((((5
	+ i) sbWatchWithId: 2)
	) sbWatchWithId: 3)
	+ 1]'.
	
	container := Morph new
		addMorphBack: e rootShard;
		layoutPolicy: TableLayout new;
		color: (Color r: 1 g: 1 b: 1);
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		openInWindow
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:30'
}
PEditorState >> adjustIndex: aNumber forChangeList: aCollection sideAffinity: anotherNumber [

	^ self
		adjustIndex: aNumber
		forChangeList: aCollection
		upTo: aCollection size
		sideAffinity: anotherNumber
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:32'
}
PEditorState >> adjustIndex: aNumber forChangeList: aCollection upTo: anotherNumber sideAffinity: aThirdNumber [

	| index |
	index := aNumber.
	aCollection
		from: 1
		to: anotherNumber
		do: [:change | (((change sideAffinity = aThirdNumber or: [aThirdNumber = 0]) and: [index >= change from]) or: [change sideAffinity ~= aThirdNumber and: [index > change from]]) ifTrue: [index := index + ((change insert ifNil: ['']) size - ((index clampLow: change from high: change to) - change from))]].
	^ index
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 08:31'
}
PEditorState >> adjustRange: aRange [

	^ PRange
		indexStart: (self adjustIndex: aRange first forChangeList: self pendingChanges sideAffinity: 1)
		end: (self adjustIndex: aRange last forChangeList: self pendingChanges sideAffinity: -1)
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:35'
}
PEditorState >> applyChanges: aCollection [

	self applyChanges: aCollection force: false
]

{
	#category : #changes,
	#'squeak_changestamp' : 'ct 12/9/2025 01:19'
}
PEditorState >> applyChanges: aCollection force: aBoolean [

	| newSourceString pair oldSourceString editScripts oldModels |
	newSourceString := aCollection, pendingChanges
		inject: self sourceString
		into: [:new :change | change applyTo: new].
	oldSourceString := sourceString.
	oldModels := models copy.
	
	editScripts := oldModels collect: [:oldRoot | | newRoot |
		newRoot := oldRoot language parse: newSourceString old: oldRoot.
		
		pair := PTrueDiff new compare: oldRoot to: newRoot.
		pair first privateSource: newSourceString.
		models at: oldRoot language put: pair first.
		pair second].
	
	aBoolean ifFalse: [
		validationBlocks do: [:b |
			(b value value: (models at: b key) value: aCollection value: (editScripts at: b key)) ifFalse: [
				models := oldModels.
				editScripts do: [:script | script undo].
				models do: [:root | root privateSource: oldSourceString].
				pendingChanges addAll: aCollection.
				pendingChangesRevert addAll: (aCollection collect: [:change |
					PChange
						range: (change from to: change from + change insert size)
						insert: (self sourceString copyFrom: change from + 1 to: change to)]).
				self shards do: [:shard | shard applyRejectedChanges: aCollection].
				^ false]]].
	
	pendingChanges := OrderedCollection new.
	self basicSourceString: newSourceString.
	
	self shards do: [:shard |
		editScripts keysAndValuesDo: [:model :editScript | shard updateReplacementsFor: editScript root: (models at: model)].
		shard updateText].
	
	self evaluateCode.
	
	^ true
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 14:45'
}
PEditorState >> applyPendingChanges [

	self applyChanges: {} force: true
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/12/2024 10:51'
}
PEditorState >> basicSourceString: aString [

	sourceString := aString
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:08'
}
PEditorState >> ensureModels: aCollection [

	aCollection do: [:model | models at: model ifAbsentPut: [sourceString ifNotNil: [model parse: sourceString old: nil]]]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'ct 12/9/2025 01:41'
}
PEditorState >> evaluateCode [

	| method |
	PTracer current ifNotNil: #reset.
	method := ([Compiler new compile: self sourceString in: nil class environment: self environment notifying: nil ifFail: [^ self]]
		on: SyntaxErrorNotification do: [^ self])
			generate.
	method numArgs = 0 ifFalse: [^ self].
	
	method valueWithReceiver: nil arguments: #().
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/19/2024 21:11'
}
PEditorState >> initialize [

	super initialize.
	
	shards := Set new.
	rootShard := PShard new editor: self.
	validationBlocks := OrderedCollection new.
	pendingChanges := OrderedCollection new.
	pendingChangesRevert := OrderedCollection new.
	models := Dictionary new
		at: PBaseParser put: nil;
		yourself
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/20/2024 06:56'
}
PEditorState >> models [

	^ models
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/15/2024 15:48'
}
PEditorState >> pendingChanges [

	^ pendingChanges
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/16/2024 07:22'
}
PEditorState >> range [

	^ PRange indexStart: 0 end: self sourceString size
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/19/2024 18:45'
}
PEditorState >> registerValidation: aBlock for: aModel [

	| pair |
	pair := aModel -> aBlock.
	validationBlocks add: pair.
	^ [validationBlocks remove: pair]
]

{
	#category : #changes,
	#'squeak_changestamp' : 'tobe 4/19/2024 20:45'
}
PEditorState >> revertPendingChanges [

	pendingChanges := OrderedCollection new.
	self shards do: [:shard | shard updateText]
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 07:56'
}
PEditorState >> rootShard [

	
	^ rootShard
]

{
	#category : #'as yet unclassified',
	#'squeak_changestamp' : 'tobe 4/13/2024 08:12'
}
PEditorState >> selectionRange [

	^ 0 to: 0
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/13/2024 07:52'
}
PEditorState >> shards [

	^ shards
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 4/12/2024 10:47'
}
PEditorState >> sourceString [

	^ sourceString
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'tobe 9/26/2024 13:24'
}
PEditorState >> sourceString: aString [

	self basicSourceString: aString.
	
	models := models keys
		collect: [:model | model -> (model parse: aString old: nil)]
		as: Dictionary.
	rootShard nodes: {models at: PBaseParser}.
	
	
]
