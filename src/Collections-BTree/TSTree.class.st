Class {
	#name : #TSTree,
	#superclass : #Collection,
	#instVars : [
		'root',
		'emptyValue'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #accessing }
TSTree >> at: aString [
	^ self at: aString ifAbsent: [self error: aString printString, ' not found']
]

{ #category : #accessing }
TSTree >> at: aString ifAbsent: exceptionBlock [
	aString isEmpty ifTrue: [^ emptyValue ifNil: [exceptionBlock value]].
	root ifNil: [^ exceptionBlock value].
	
	^ (root lookupString: aString startingAt: 1) ifNil: exceptionBlock
]

{ #category : #accessing }
TSTree >> at: aString ifAbsentPut: exceptionBlock [
	^ self at: aString ifAbsent: [self at: aString put: exceptionBlock value]
]

{ #category : #accessing }
TSTree >> at: aString put: anObject [
	aString isEmpty ifTrue: [^ emptyValue := anObject].
	root ifNil: [root := TSTreeNode key: aString first].
	root lookupString: aString startingAt: 1 insert: anObject.
	^ anObject
]

{ #category : #enumerating }
TSTree >> do: aBlock [
	emptyValue ifNotNil: aBlock.
	root ifNotNil: [ root do: aBlock ]
]

{ #category : #accessing }
TSTree >> keys [
	^ Array streamContents: [:s | self keysAndValuesDo: [:k :v | s nextPut: k]]
]

{ #category : #enumerating }
TSTree >> keysAndValuesDo: aBlock [
	emptyValue ifNotNil:
		[aBlock value: '' value: emptyValue].
	root ifNotNil: [root keysAndValuesDo: aBlock prefix: '']
]

{ #category : #matching }
TSTree >> matchesForPrefix: aString [
	^ Array streamContents:
		[:s |
		self matchesForPrefix: aString do:
			[:match |
			s nextPut: match]]
]

{ #category : #matching }
TSTree >> matchesForPrefix: aString do: aBlock [
	aString isEmpty
		ifTrue: [self do: aBlock]
		ifFalse: [root ifNotNil: [root matchesForPrefix: aString startingAt: 1 do: aBlock]]
]

{ #category : #matching }
TSTree >> matchesForString: aString distance: aNumber [
	^ Array streamContents:
		[:s |
		self matchesForString: aString distance: aNumber do:
			[:match |
			s nextPut: match]]
]

{ #category : #matching }
TSTree >> matchesForString: aString distance: aNumber do: aBlock [
	self matchesForString: aString distance: aNumber limitNodes: nil do: aBlock
]

{ #category : #matching }
TSTree >> matchesForString: aString distance: aNumber limitNodes: maxNodes do: aBlock [
	| nodeCount |
	nodeCount := 0.
	aString isEmpty ifTrue: [^ self].
	root isNil ifTrue: [^ self].
	root matchesForString: aString startingAt: 1 distance: aNumber do: aBlock nodesDo:
		[:ea |
		nodeCount := nodeCount + 1.
		nodeCount = maxNodes ifTrue: [^ self]]
]

{ #category : #accessing }
TSTree >> removeKey: aString [
	^ self removeKey: aString ifAbsent: [self error: 'Could not find key ', aString printString]
]

{ #category : #accessing }
TSTree >> removeKey: aString ifAbsent: errorBlock [
	| val |
	^ root ifNil: errorBlock
		ifNotNil:
			[val := root removeString: aString startingAt: 1.
			root canBeCulled ifTrue: [root := nil].
			val ifNil: errorBlock]
]

{ #category : #accessing }
TSTree >> values [
	^ Array streamContents: [:s | self do: [:ea | s nextPut: ea]]
]
