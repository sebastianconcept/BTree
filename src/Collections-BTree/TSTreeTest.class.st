Class {
	#name : #TSTreeTest,
	#superclass : #TestCase,
	#instVars : [
		'tree',
		'empty'
	],
	#category : #'Collections-BTree-Tests'
}

{ #category : #running }
TSTreeTest >> setUp [
	tree := TSTree new.
	self words shuffled do: [:ea | tree at: ea put: ea asUppercase].
	empty := TSTree new.
]

{ #category : #tests }
TSTreeTest >> testAt [
	self assert: (tree at: 'abear') = 'ABEAR'.
	self assert: (tree at: 'abelmosk') = 'ABELMOSK'.
	self assert: (tree at: 'abracadabra' ifAbsent: [42]) = 42.
	self assert: (tree at: '' ifAbsent: [42]) = 42.
	self assert: (empty at: 'foo' ifAbsent: [42]) = 42 
]

{ #category : #tests }
TSTreeTest >> testMatch [
	self assert: (tree matchesForString: 'abea' distance: 1) asSet = #(ABEAM ABEAR ABED ABEL ABET ABE) asSet.
	self assert: (tree matchesForString: 'abel' distance: 2) asSet = #(ABELIA ABEAM ABEAR) asSet.
	self assert: (tree matchesForString: 'abel' distance: 0) = #(ABEL).
	self assert: (tree matchesForString: '' distance: 1) = #().
	self assert: (empty matchesForString: 'foo' distance: 0) = #()
]

{ #category : #tests }
TSTreeTest >> testPrefix [
	self assert: (tree matchesForPrefix: 'abet') asSet = #(ABET ABETMENT) asSet.
	self assert: (tree matchesForPrefix: 'abelm') asSet = #(ABELMOSCHUS ABELMOSK) asSet.
	self assert: (tree matchesForPrefix: '') asSet = (self words asSet collect: [:ea | ea asUppercase]).
	self assert: (empty matchesForPrefix: 'foo') = #()
]

{ #category : #tests }
TSTreeTest >> testRemove [
	self assert: (tree at: 'abel') = 'ABEL'.
	self assert: (tree removeKey: 'abel') = 'ABEL'.
	self assert: (tree at: 'abel' ifAbsent: [42]) = 42.
	self assert: (tree at: 'abelmosk') = 'ABELMOSK'.
	self assert: (tree removeKey: 'foo' ifAbsent: [42]) = 42.
	self assert: (tree removeKey: 'abel' ifAbsent: [42]) = 42.
]

{ #category : #tests }
TSTreeTest >> testValues [
	self assert: tree values asSet = (self words asSet collect: [:ea | ea asUppercase]).
	self assert: empty values isEmpty
]

{ #category : #running }
TSTreeTest >> words [
	^ #(
abe
abeam
abear
abearance
abecedarian
abecedarium
abecedary
abed
abeigh
abel
abele
abelia
abelian
abelicea
abelite
abelite
abelmoschus
abelmosk
abelonian
abeltree
abencerrages
abenteric
abepithymia
aberdeen
aberdevine
aberdonian
aberia
aberrance
aberrancy
aberrant
aberrate
aberration
aberrational
aberrator
aberrometer
aberroscope
aberuncator
abet
abetment) 
]
