Class {
	#name : #BTreeTest,
	#superclass : #TestCase,
	#category : #'Collections-BTree-Tests'
}

{ #category : #converting }
BTreeTest >> assertConsistent: aBTree [
	| depths root |
	root := aBTree root.
	
 " http://www.cs.umbc.edu/~woodcock/cmsc341/btree/defn.html

A B-Tree of order m is a search tree, where the data 
  (or pointers to it) is stored at the leaves, such that:

1) the root is either a leaf (as well--i.e. the tree is 
     a single node) or has between 2 and m children"
	
	self assert: (root isLeaf or: [root values size between: 2 and: aBTree order]).
	
"  2) all other (non-root) nodes have at least m/2 children,
     but no more than m children"

	root allChildrenDo: [:ea | self assert: (ea values size between: (aBTree order // 2) and: aBTree order)]. 

"  3) all leaves are at the same depth"

	depths := Set new.
	root withAllChildrenDo: [:ea | ea isLeaf ifTrue: [depths add: ea depth]].
	self assert: depths size = 1.
]

{ #category : #converting }
BTreeTest >> assertSorted: aTree [
	| last |
	last := nil.
	aTree keysAndValuesDo:
		[:k :v |
		last ifNotNil: [self assert: last < k].
		last := k]
]

{ #category : #'as yet unclassified' }
BTreeTest >> checkTree: tree array: pairArray [
	pairArray withIndexDo:
		[:pair :i |
		tree at: pair first put: pair second.
		self assert: tree size = i.
		"self assertConsistent: tree.
		self assertSorted: tree"].
	pairArray shuffled do:
		[:pair |
		self assert: (tree at: pair first) = pair second].
	self assert: tree size = pairArray size.
	self assertConsistent: tree.
	self assertSorted: tree.
	^ tree
	
	 
]

{ #category : #'as yet unclassified' }
BTreeTest >> checkTree: tree items: count [
	| pairArray  |
	pairArray := ((1 to: count) collect: [:i | Array with: i asString with: i]) shuffled.
	self checkTree: tree array: pairArray
]

{ #category : #'as yet unclassified' }
BTreeTest >> checkTreeWithOrder: order items: count [
	self checkTree: (BTree order: order) items: count
]

{ #category : #tests }
BTreeTest >> testAddAndRetrieveWithSplit [
	self checkTreeWithOrder: 4 items: 5
]

{ #category : #tests }
BTreeTest >> testAddAndRetrieveWithTwoSplits [
	self checkTreeWithOrder: 4 items: 17
]

{ #category : #tests }
BTreeTest >> testCommonKeysDifferentValues [
	| large small expectedResults results |
	large := BTree new.
	1 to: 1000 by: 2 do: [:i | large at: i put: i].
	small := BTree new.
	2 to: 2000 by: 11 do: [:i | small at: i put: i*2].
	
	expectedResults := ((-9 to: 1000 by: 22) allButFirst collect: [:i | Array with: i with: i with: i*2]) asOrderedCollection.
	
	results := OrderedCollection new.
	large commonKeysWith: small keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v1 with: v2)].
	self assert: results = expectedResults.
	
	results := OrderedCollection new.
	small commonKeysWith: large keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v2 with: v1)].
	self assert: results = expectedResults
]

{ #category : #tests }
BTreeTest >> testCommonKeysSameValues [
	| large small expectedResults results |
	large := BTree new.
	1 to: 1000 by: 2 do: [:i | large at: i put: i].
	small := BTree new.
	2 to: 2000 by: 11 do: [:i | small at: i put: i].
	
	expectedResults := ((-9 to: 1000 by: 22) allButFirst collect: [:i | Array with: i with: i with: i]) asOrderedCollection.
	
	results := OrderedCollection new.
	large commonKeysWith: small keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v1 with: v2)].
	self assert: results = expectedResults.
	
	results := OrderedCollection new.
	small commonKeysWith: large keysAndValuesDo:
		[:k :v1 :v2 |
		results add: (Array with: k with: v2 with: v1)].
	self assert: results = expectedResults
]

{ #category : #tests }
BTreeTest >> testEmptyTree [
	self checkTreeWithOrder: 5 items: 0
]

{ #category : #tests }
BTreeTest >> testFirstLast [
	| tree |
	tree := BTree new.
	self should: [ tree first ] raise: Error.
	self should: [ tree last ] raise: Error.
	tree at: SmallInteger minVal put: SmallInteger minVal.
	tree at: SmallInteger maxVal put: SmallInteger maxVal.
	10000 timesRepeat: [ 
		tree at: 536870911 atRandom put: nil.
		self assert: tree first = SmallInteger minVal.
		self assert: tree last = SmallInteger maxVal ]
]

{ #category : #tests }
BTreeTest >> testFound [
	| tree found |
	found := false.
	tree := BTree new.
	tree at: 1 put: 'foo'.
	tree
		at: 1
		ifPresent: [ :val | 
			self assert: 'foo' equals: val.
			found := true ].
	self assert: found
]

{ #category : #tests }
BTreeTest >> testLargeTree [
	self checkTreeWithOrder: 8 items: 5000
	

]

{ #category : #tests }
BTreeTest >> testMissing [
	| tree |
	tree := BTree new.
	tree at: 1 put: 'foo'.
	tree at: 2 put: 'bar'.
	self assert: (tree at: 1 ifAbsent: [42]) = 'foo'.
	self assert: (tree at: 2 ifAbsent: [42]) = 'bar'.
	self assert: (tree at: 3 ifAbsent: [42]) = 42.
]

{ #category : #tests }
BTreeTest >> testMultipleAddAndRetrieve [
	self checkTreeWithOrder: 5 items: 3
]

{ #category : #tests }
BTreeTest >> testRange [
	| tree keys |
	tree := BTree new.
	1 to: 100 by: 2 do: [:ea | tree at: ea put: ea * 2].
	self assert: tree size = 50.
	keys := OrderedCollection new.
	tree from: 12 to: 19 keysAndValuesDo:
		[:k :v |
		self assert: k * 2 = v.
		keys add: k].
	self assert: keys asArray = #(13 15 17 19).
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : #tests }
BTreeTest >> testRemoval [
	| tree |
	tree := BTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	tree removeKey: #d.
	self assert: tree size = 11.
	self assert: (tree at: #d ifAbsent: [32]) = 32.
	tree removeKey: #k.
	self assert: tree size = 10.
	self assert: (tree at: #k ifAbsent: [32]) = 32.
	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : #tests }
BTreeTest >> testRemoval2 [
	| tree |
	tree := BTree new.
	1 to: 15 do: [:i | tree at: i put: i].
	1 to: 15 do: [:i | tree removeKey: i].
	self assert: tree isEmpty
]

{ #category : #tests }
BTreeTest >> testRemoveAll [
	| tree |
	tree := BTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(a b c d e f g h i j k l)  shuffled do: [:ea | tree removeKey: ea].
	self assert: tree size = 0.

	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : #tests }
BTreeTest >> testRemoveAllFailing [
	| tree |
	tree := BTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(#c #j #g #i #k #l #f #e #d #h #a #b) do: [:ea | tree removeKey: ea].
	self assert: tree size = 0.

	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : #tests }
BTreeTest >> testRemoveLots [
	| tree |
	tree := BTree new.
	#(a b c d e f g h i j k l) do: [:ea | tree at: ea put: ea, '!'].
	self assert: tree size = 12.
	#(a c e g i k) shuffled do: [:ea | tree removeKey: ea].
	self assert: tree size = 6.

	self assertSorted: tree.
	self assertConsistent: tree.
]

{ #category : #tests }
BTreeTest >> testSimpleAddAndRetrieve [
	self checkTreeWithOrder: 5 items: 1
]

{ #category : #tests }
BTreeTest >> testStoreNil [
	self checkTree: BTree new array: {{'x'. 1}. {'y'. nil}}
]

{ #category : #tests }
BTreeTest >> testStringKeys [
	self checkTree: (BTree keys: BTreeStringKeys new) items: 100
]
