Class {
	#name : #BTreeNode,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'parent',
		'keys'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #'as yet unclassified' }
BTreeNode class >> keys: anArray [
	^ (self new: (anArray size)) keys: anArray
]

{ #category : #enumerating }
BTreeNode >> allChildrenDo: aBlock [
	self childrenDo:
		[:ea |
		aBlock value: ea.
		ea allChildrenDo: aBlock]
]

{ #category : #enumerating }
BTreeNode >> allLeavesDo: aBlock [
	self withAllChildrenDo: [:ea | ea isLeaf ifTrue: [aBlock value: ea]]
]

{ #category : #testing }
BTreeNode >> canGrow [
	^ keys canGrow
]

{ #category : #testing }
BTreeNode >> canShrink [
	^ keys canShrink
]

{ #category : #accessing }
BTreeNode >> children [
	^ Array streamContents: [:s | self childrenDo: [:ea | s nextPut: ea]]
]

{ #category : #enumerating }
BTreeNode >> childrenDo: aBlock [
	self subclassResponsibility
]

{ #category : #accessing }
BTreeNode >> depth [
	^ parent ifNil: [1] ifNotNil: [1 + parent depth]
]

{ #category : #private }
BTreeNode >> ensureParent [
	parent ifNil:
		 [self parent: (self interiorNodeClass keys: keys emptyCopy).
		parent insertKey: self firstKey value: self].
	^ parent
]

{ #category : #accessing }
BTreeNode >> first [
	self subclassResponsibility
]

{ #category : #accessing }
BTreeNode >> firstKey [
	^ keys first
]

{ #category : #private }
BTreeNode >> grow [
	| sibling |
	parent ifNotNil:
		[sibling := parent nextSiblingForChild: self.
		sibling ifNil: [self parent: nil. ^ self].
		sibling canShrink
			ifTrue: [self stealFrom: sibling]
			ifFalse: [self mergeWith: sibling]]
				
]

{ #category : #inserting }
BTreeNode >> insertKey: aMagnitude value: anObject [
	| index key |
	index := keys findIndexForKey: aMagnitude.
	index = 0 ifTrue:
		[self canGrow
			ifTrue:
				[self shiftRightFrom: 1.
				^ self insertKey: aMagnitude value: anObject at: 1]
			ifFalse:
				[self split.
				^ (parent childForKey: aMagnitude) insertKey: aMagnitude value: anObject]].
	
	key := keys at: index.
	key = aMagnitude ifTrue:
		[^ self insertKey: aMagnitude value: anObject at: index].
	index < self size ifTrue:
		[key := keys at: index + 1.
		key
			ifNil: [^ self insertKey: aMagnitude value: anObject at: index+1]
			ifNotNil:
				[self canGrow ifTrue:
					[self shiftRightFrom: index+1.
					^ self insertKey: aMagnitude value: anObject at: index+1]]].

	"otherwise"
	self split.
	^ (parent childForKey: aMagnitude) insertKey: aMagnitude value: anObject
]

{ #category : #private }
BTreeNode >> insertKey: aMagnitude value: anObject at: index [
	keys at: index put: aMagnitude.
	self at: index put: anObject
]

{ #category : #private }
BTreeNode >> interiorNodeClass [
	^ BTreeInteriorNode
]

{ #category : #testing }
BTreeNode >> isLeaf [
	self subclassResponsibility
]

{ #category : #private }
BTreeNode >> keyArray [
	^ keys
]

{ #category : #private }
BTreeNode >> keys: anArray [
	keys := anArray
]

{ #category : #enumerating }
BTreeNode >> keysAndValuesDo: aBlock [
	keys withIndexDo:
		[:key :i |
		key ifNotNil: [aBlock value: key value: (self at: i)]]
]

{ #category : #enumerating }
BTreeNode >> keysDo: aBlock [
	keys withIndexDo:
		[:key :i |
		key ifNotNil: [aBlock value: key] ifNil: [^ self]]
]

{ #category : #accessing }
BTreeNode >> last [
	self subclassResponsibility
]

{ #category : #enumerating }
BTreeNode >> leavesFrom: start to: end do: aBlock [
	self subclassResponsibility
]

{ #category : #private }
BTreeNode >> mergeWith: aNode [		
	| oldKey |
	oldKey := self firstKey.
	aNode keysAndValuesDo:
		[:k :v |
		self insertKey: k value: v].
	parent removeKey: aNode firstKey.
	parent updateKey: oldKey to: self firstKey.
]

{ #category : #accessing }
BTreeNode >> parent [
	^ parent
]

{ #category : #accessing }
BTreeNode >> parent: aBTreeNode [
	parent := aBTreeNode
]

{ #category : #removing }
BTreeNode >> removeKey: aMagnitude [
	self removeKey: aMagnitude ifAbsent: [self error: aMagnitude printString, ' not found.'].
]

{ #category : #removing }
BTreeNode >> removeKey: aMagnitude ifAbsent: aBlock [
	| index key |
	self canShrink ifFalse: [self grow].
	
	index := keys findIndexForKey: aMagnitude.
	index = 0 ifTrue: [^ aBlock value].
	key := keys at: index.
	key = aMagnitude ifFalse: [^ aBlock value].
	
	self shiftLeftTo: index.
	
	index = 1 ifTrue: [parent ifNotNil: [parent updateKey: key to: self firstKey]]
]

{ #category : #accessing }
BTreeNode >> root [
	^ parent
		ifNil: [self]
		ifNotNil: [parent root]
]

{ #category : #private }
BTreeNode >> shiftLeftTo: index [
	keys shiftLeftTo: index.
	index to: self size - 1 by: 1 do:
		[:i |
		self at: i put: (self at: i+1)].
	self at: self size put: nil.
]

{ #category : #private }
BTreeNode >> shiftRightFrom: index [
	keys shiftRightFrom: index.
	self size to: index+1 by: -1 do:
		[:i |
		self at: i put: (self at: i-1)]
]

{ #category : #private }
BTreeNode >> split [
	| other midpoint |
	other := self class keys: keys emptyCopy.
	midpoint := self size // 2 + 1.
	midpoint to: self size do:
		[:i |
		other insertKey: (keys at: i) value: (self at: i) at: (i - midpoint + 1).
		keys at: i put: nil.
		self at: i put: nil].
	
	self ensureParent insertKey: other firstKey value: other
]

{ #category : #private }
BTreeNode >> stealFrom: aNode [
	| key value |
	aNode firstKey > self firstKey
		ifTrue: [value := aNode at: 1. key := aNode firstKey]
		ifFalse:
			[aNode keysAndValuesDo: [:k :v | key := k. value := v].
			parent ifNotNil: [parent updateKey: self firstKey to: key]].
	self insertKey: key value: value.
	aNode removeKey: key
]

{ #category : #accessing }
BTreeNode >> values [
	^ Array streamContents: [:s | self valuesDo: [:ea | s nextPut: ea]]
]

{ #category : #enumerating }
BTreeNode >> valuesDo: aBlock [
	self keysAndValuesDo: [:k :v | aBlock value: v]
]

{ #category : #enumerating }
BTreeNode >> withAllChildrenDo: aBlock [
	aBlock value: self.
	self allChildrenDo: aBlock.
]
