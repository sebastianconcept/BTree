Class {
	#name : #BTree,
	#superclass : #Collection,
	#instVars : [
		'root'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #'as yet unclassified' }
BTree class >> keys: aBTreeKeys [
	^ self basicNew initializeWithKeys: aBTreeKeys
]

{ #category : #'as yet unclassified' }
BTree class >> new [
	^ self order: 5
]

{ #category : #'as yet unclassified' }
BTree class >> order: aNumber [
	^ self keys: (BTreeKeysArray new: aNumber)
]

{ #category : #accessing }
BTree >> at: aMagnitude [
	^ self at: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found']
]

{ #category : #accessing }
BTree >> at: aMagnitude ifAbsent: errorBlock [
       | leaf |
       leaf := root existingLeafForKey: aMagnitude.
       leaf ifNil: [^ errorBlock value].
       ^ leaf valueForKey: aMagnitude ifAbsent: errorBlock
]

{ #category : #adding }
BTree >> at: aMagnitude ifAbsentPut: aBlock [
	^ self at: aMagnitude ifAbsent: [self at: aMagnitude put: aBlock value]
]

{ #category : #accessing }
BTree >> at: aMagnitude ifPresent: aBlock [
	| leaf |
	leaf := root existingLeafForKey: aMagnitude.
	leaf ifNil: [ ^ nil ].
	^ leaf valueForKey: aMagnitude ifPresent: aBlock
]

{ #category : #adding }
BTree >> at: aMagnitude put: anObject [
	| leaf |
	leaf := root leafForKey: aMagnitude.
	leaf insertKey: aMagnitude value: anObject.
	root := leaf root.
	^ anObject
]

{ #category : #enumerating }
BTree >> commonKeysWith: aTree keysAndValuesDo: aBlock [
	^ aTree depth < self depth
		ifTrue: [aTree root commonKeysWith: root keysAndValuesDo: aBlock flip: true]
		ifFalse: [root commonKeysWith: aTree root keysAndValuesDo: aBlock flip: false]
]

{ #category : #accessing }
BTree >> depth [
	^ root depth
]

{ #category : #enumerating }
BTree >> do: aBlock [
	root allLeavesDo: [:ea | ea valuesDo: aBlock]
]

{ #category : #copying }
BTree >> emptyCopy [
	^ BTree keys: root keyArray emptyCopy
]

{ #category : #accessing }
BTree >> first [
	^ root first
]

{ #category : #enumerating }
BTree >> from: start do: aBlock [
	self from: start to: nil keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : #enumerating }
BTree >> from: start keysAndValuesDo: aBlock [
	self from: start to: nil keysAndValuesDo: aBlock
]

{ #category : #enumerating }
BTree >> from: start to: end do: aBlock [
	self from: start to: end keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : #enumerating }
BTree >> from: start to: end keysAndValuesDo: aBlock [
	root leavesFrom: start to: end do:
		[:ea |
		ea keysAndValuesDo:
			[:k :v |
			((start isNil or: [k >= start]) and:
				[end isNil or: [k <= end]]) ifTrue:
					[aBlock value: k value: v]]]
]

{ #category : #'initialize-release' }
BTree >> initializeWithKeys: aBTreeKeys [
	aBTreeKeys size > 3 ifFalse: [self error: 'The BTree order must be at least 4'].
	root := BTreeLeafNode keys: aBTreeKeys
]

{ #category : #accessing }
BTree >> keys [
	^ Array streamContents:
		[:s |
		self keysDo: [:k | s nextPut: k]]
]

{ #category : #enumerating }
BTree >> keysAndValuesDo: aBlock [
	root allLeavesDo: [:ea | ea keysAndValuesDo: aBlock]
]

{ #category : #enumerating }
BTree >> keysDo: aBlock [
	root allLeavesDo: [:ea | ea keysDo: aBlock]
]

{ #category : #accessing }
BTree >> last [
	^ root last
]

{ #category : #accessing }
BTree >> order [
	^ root size
]

{ #category : #adding }
BTree >> removeKey: aMagnitude [
	^ self removeKey: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found.']
]

{ #category : #adding }
BTree >> removeKey: aMagnitude ifAbsent: aBlock [
	| leaf |
	leaf := root existingLeafForKey: aMagnitude.
	leaf ifNil: [^ aBlock value].
	leaf removeKey: aMagnitude ifAbsent: [^ aBlock value].
	root := leaf root
]

{ #category : #private }
BTree >> root [
	^ root
]

{ #category : #enumerating }
BTree >> upTo: end do: aBlock [
	self from: nil to: end keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : #enumerating }
BTree >> upTo: end keysAndValuesDo: aBlock [
	self from: nil to: end keysAndValuesDo: aBlock
]

{ #category : #accessing }
BTree >> values [
	^ Array streamContents:
		[:s |
		self valuesDo: [:k | s nextPut: k]]
]

{ #category : #enumerating }
BTree >> valuesDo: aBlock [
	root allLeavesDo: [:ea | ea valuesDo: aBlock]
]
