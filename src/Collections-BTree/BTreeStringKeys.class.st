Class {
	#name : #BTreeStringKeys,
	#superclass : #BTreeKeys,
	#instVars : [
		'keys',
		'prefix',
		'abbreviations'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #'as yet unclassified' }
BTreeStringKeys class >> new [
	^ self new: 8
]

{ #category : #'as yet unclassified' }
BTreeStringKeys class >> new: aNumber [
	^ self basicNew initializeWithSize: aNumber
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> abbreviationSize [
	^ 3
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> abbreviationsAndIndicesDo: aBlock [
	| stream |
	stream := abbreviations readStream.
	1 to: self size do:
		[:i |
		stream atEnd
			ifFalse: [aBlock value: prefix, (stream next: self abbreviationSize) value: i]
			ifTrue: [aBlock value: nil value: i]]
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> at: aNumber [
	^ keys at: aNumber
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> at: aNumber put: aString [
	keys at: aNumber put: aString.
	prefix := self nilPrefix.
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> buildAbbreviationsFrom: readStreams [
	| nextChars |
	1 to: self abbreviationSize do:
		[:i |
		nextChars := readStreams collect: [:ea | ea next ifNil: [Character value: 0]].
		nextChars withIndexDo:
			[:c :j |
			abbreviations at: (j-1 * self abbreviationSize) + i put: c]].
	^ abbreviations
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> extractPrefixFrom: readStreams [
	| prefixStream nextChars |
	prefixStream := String new writeStream.
	
	[readStreams anySatisfy: [:ea | ea atEnd]] whileFalse:
		[nextChars := readStreams collect: [:ea | ea next].
		(nextChars allSatisfy: [:ea | ea = nextChars first])
				ifTrue: [prefixStream nextPut: nextChars first]
				ifFalse: [readStreams do: [:ea | ea skip: -1]. ^ prefixStream contents]].
	^ prefixStream contents

]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> findIndexForKey: aString [
	| stream str diff |
	prefix = self nilPrefix ifTrue: [self rebuildAbbreviations].
	stream := aString readStream.
	str := stream next: prefix size + self abbreviationSize.
	diff := prefix size + self abbreviationSize - str size.
	str := str, (String new: diff).
	self abbreviationsAndIndicesDo:
		[:abbr :i |
		abbr ifNil: [^ i - 1].
		str < abbr ifTrue: [^ i - 1].
		str = abbr ifTrue: [^ super findIndexForKey: aString]].
	^ self size
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> initializeWithSize: aNumber [
	keys := Array new: aNumber.
	prefix := self nilPrefix.
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> nilPrefix [
	^ '^^^'
]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> rebuildAbbreviations [
	| keyStreams filled |
	filled := keys count: [:ea | ea notNil].
	abbreviations := String new: (filled * self abbreviationSize).
	filled = 0 ifTrue: [prefix := ''. ^ self ].
	keyStreams := (1 to: filled) collect: [:i | (keys at: i) readStream].
	
	prefix := self extractPrefixFrom: keyStreams.
	abbreviations := self buildAbbreviationsFrom: keyStreams.

]

{ #category : #'as yet unclassified' }
BTreeStringKeys >> size [
	^ keys size
]
