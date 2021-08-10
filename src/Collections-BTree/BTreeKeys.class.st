Class {
	#name : #BTreeKeys,
	#superclass : #Object,
	#category : #'Collections-BTree-Core'
}

{ #category : #'as yet unclassified' }
BTreeKeys >> canGrow [
	^ (self at: self size) isNil
]

{ #category : #'as yet unclassified' }
BTreeKeys >> canShrink [
	^  (self at: self size // 2 + 1) notNil
]

{ #category : #'as yet unclassified' }
BTreeKeys >> emptyCopy [
	^ self class new: self size
]

{ #category : #'as yet unclassified' }
BTreeKeys >> findIndexForKey: aMagnitude [
	self withIndexDo:
		[:key :i |
		(key isNil or: [key > aMagnitude]) ifTrue:
			[^ i - 1]].
	^ self size

]

{ #category : #'as yet unclassified' }
BTreeKeys >> first [
	^ self at: 1
]

{ #category : #'as yet unclassified' }
BTreeKeys >> lastIndex [
	self withIndexDo:
		[:key :i |
		key isNil ifTrue:
			[^ i - 1]].
	^ self size

]

{ #category : #'as yet unclassified' }
BTreeKeys >> shiftLeftTo: index [
	index to: self size - 1 by: 1 do:
		[:i |
		self at: i put: (self at: i+1)].
	self at: self size put: nil.
]

{ #category : #'as yet unclassified' }
BTreeKeys >> shiftRightFrom: index [
	self size to: index+1 by: -1 do:
		[:i |
		self at: i put: (self at: i - 1)]
	
]

{ #category : #'as yet unclassified' }
BTreeKeys >> withIndexDo: aBlock [
	1 to: self size do: [:i | aBlock value: (self at: i) value: i]
]
