Class {
	#name : #TreeSet,
	#superclass : #Collection,
	#instVars : [
		'tree',
		'sortKey',
		'equalsKey'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #'as yet unclassified' }
TreeSet class >> defaultEqualitySelector [
	^ #=
]

{ #category : #'as yet unclassified' }
TreeSet class >> defaultKeys [
	^ BTreeKeysArray new: 64
]

{ #category : #'as yet unclassified' }
TreeSet class >> defaultSortSelector [
	^ #hash
]

{ #category : #'as yet unclassified' }
TreeSet class >> keys: aBtreeKeys sortSelector: sortSymbol equalitySelector: equalsSymbol [
	^ self basicNew initializeWithKeys: aBtreeKeys sortSelector: sortSymbol equalitySelector: equalsSymbol
]

{ #category : #'as yet unclassified' }
TreeSet class >> new [
	^ self sortBy: self defaultSortSelector
]

{ #category : #'as yet unclassified' }
TreeSet class >> sortBy: aSymbol [
	^ self sortSelector: aSymbol equalitySelector: self defaultEqualitySelector
]

{ #category : #'as yet unclassified' }
TreeSet class >> sortSelector: sortSymbol equalitySelector: equalsSymbol [
	^ self keys: self defaultKeys sortSelector: sortSymbol equalitySelector: equalsSymbol
]

{ #category : #'as yet unclassified' }
TreeSet class >> withAll: aCollection [
	"Create a new collection containing all the elements from aCollection."

	^ self new
		addAll: aCollection;
		yourself
]

{ #category : #public }
TreeSet >> add: anObject [
	| key bucket |
	key := self keyForValue: anObject.
	bucket := tree at: key ifAbsent: [#()].
	(self bucket: bucket includes: anObject) ifFalse:
		[tree at: key put: (bucket copyWith: anObject)].
]

{ #category : #public }
TreeSet >> addAll: aCollection [
	| oldVals newVals combined |
	(self isCompatibleTreeSetWith: aCollection) ifFalse: [^ super addAll: aCollection].

	aCollection tree keysAndValuesDo:
		[:key :vals |
		oldVals := tree at: key ifAbsent: [#()].
		newVals := oldVals isEmpty
					ifTrue: [vals]
					ifFalse: [vals reject: [:ea | self bucket: oldVals includes: ea]].
		newVals isEmpty ifFalse:
			[combined := oldVals isEmpty ifTrue: [newVals] ifFalse: [oldVals, newVals].
			tree at: key put: combined]]
]

{ #category : #public }
TreeSet >> atIndex: index [
	| count |
	count := 0.
	self do: [:ea | (count := count + 1) = index ifTrue: [^ ea]].
	self error: 'No item at index: ', index asString.
]

{ #category : #private }
TreeSet >> bucket: anArray includes: anObject [
	^ anArray anySatisfy: [:ea | (self value: anObject matches: ea)]
]

{ #category : #public }
TreeSet >> do: aBlock [
	tree do: [:bucket | bucket do: aBlock]
]

{ #category : #public }
TreeSet >> equalitySelector [
	^ equalsKey ifNil: [equalsKey := self class defaultEqualitySelector]
]

{ #category : #public }
TreeSet >> first [
	^ self atIndex: 1
]

{ #category : #public }
TreeSet >> includes: anObject [
	| bucket |
	bucket :=  tree at: (self keyForValue: anObject) ifAbsent: [^ false].
	^ self bucket: bucket includes: anObject
]

{ #category : #'initialize-release' }
TreeSet >> initializeWithKeys: aBtreeKeys sortSelector: sortSymbol equalitySelector: equalsSymbol [
	self setTree: (BTree keys: aBtreeKeys) sortSelector: sortSymbol equalitySelector: equalsSymbol
]

{ #category : #public }
TreeSet >> intersection: aCollection [
	| newTree intersection |
	(self isCompatibleTreeSetWith: aCollection) ifFalse: [^ super intersection: aCollection].

	newTree := tree emptyCopy.
	
	tree commonKeysWith: aCollection tree keysAndValuesDo:
		[:key :left :right |
		intersection := left select: [:ea | self bucket: right includes: ea].
		intersection isEmpty ifFalse: [newTree at: key put: intersection]].
	
	^ TreeSet basicNew setTree: newTree sortSelector: self sortSelector equalitySelector: self equalitySelector
]

{ #category : #private }
TreeSet >> isCompatibleTreeSetWith: aCollection [
	aCollection isTreeSet ifFalse: [^ false].
	aCollection equalitySelector = self equalitySelector ifFalse: [^ false].
	aCollection sortSelector = self sortSelector ifFalse: [^ false].
	^ true
]

{ #category : #public }
TreeSet >> isTreeSet [
	^ true
]

{ #category : #plugs }
TreeSet >> keyForValue: anObject [
	^ anObject perform: sortKey
]

{ #category : #public }
TreeSet >> remove: anObject [
	| key bucket |
	key := self keyForValue: anObject.
	bucket := tree at: key ifAbsent: [^ self].
	(self bucket: bucket includes: anObject) ifTrue:
		[bucket := bucket reject: [:ea | self value: anObject matches: ea].
		bucket isEmpty
			ifTrue: [tree removeKey: key]
			ifFalse: [tree at: key put: bucket]]
]

{ #category : #public }
TreeSet >> remove: anObject ifAbsent: aBlock [
	self remove: anObject.
]

{ #category : #public }
TreeSet >> removeAllSuchThat: aBlock [
	| changes remove |
	changes := Dictionary new.
	tree keysAndValuesDo:
		[:key :bucket |
		remove := bucket select: aBlock.
		remove isEmpty ifFalse:
			[changes at: key put: (bucket copyWithoutAll: remove)]].
	changes keysAndValuesDo:
		[:key :bucket |
		tree at: key put: bucket]
]

{ #category : #public }
TreeSet >> second [
	^ self atIndex: 2
]

{ #category : #'initialize-release' }
TreeSet >> setTree: aBTree sortSelector: sortSymbol equalitySelector: equalsSymbol [
	tree := aBTree.
	sortKey := sortSymbol.
	equalsKey := equalsSymbol
]

{ #category : #public }
TreeSet >> sortSelector [
	^ sortKey
]

{ #category : #private }
TreeSet >> tree [
	^ tree
]

{ #category : #private }
TreeSet >> tree: aBTree [
	tree := aBTree
]

{ #category : #plugs }
TreeSet >> value: anObject matches: otherObject [
	^ anObject perform: self equalitySelector with: otherObject
]
