"
I provide a way to efficiently store and access date intervals. I am capable of answering the question, ""What events lie within a given date range."" 
"
Class {
	#name : #DateTree,
	#superclass : #Collection,
	#instVars : [
		'startTimes',
		'endTimes',
		'events'
	],
	#category : #'Collections-BTree-Core'
}

{ #category : #accessing }
DateTree >> at: aTimepan [
	^ self at: aTimepan ifAbsent: [ self error: aTimepan printString, ' not found' ]
]

{ #category : #accessing }
DateTree >> at: aTimespan ifAbsent: aBlock [
	^ events at: aTimespan ifAbsent: aBlock
]

{ #category : #accessing }
DateTree >> at: aTimespan ifAbsentPut: exceptionBlock [
	^ self at: aTimespan ifAbsent: [ self at: aTimespan put: exceptionBlock value ].
]

{ #category : #adding }
DateTree >> at: aTimespan put: anObject [
	| timespans |
	timespans := startTimes at: aTimespan start ifAbsentPut: [ Set new ].
	timespans add: aTimespan.
	timespans := endTimes at: aTimespan end ifAbsentPut: [ Set new ].
	timespans add: aTimespan.
	events at: aTimespan put: anObject.
	^ anObject
]

{ #category : #enumerating }
DateTree >> between: startDateAndTime and: endDateAndTime [
	"I return all events between a given start date and end date."
	
	| values |
	values := TreeSet new.
	self between: startDateAndTime and: endDateAndTime keysAndValuesDo: [ :key :val | values add: val ].
	^ values
]

{ #category : #enumerating }
DateTree >> between: startDateAndTime and: endDateAndTime keysAndValuesDo: aBlock [
	| startOrLater endOrEarlier |

	"This adds stuff really slowly; I'm not sure what to do about that yet"
	startOrLater := TreeSet new.
	endOrEarlier := TreeSet new.
	startTimes from: DateAndTime epoch to: endDateAndTime do: [ :ea | endOrEarlier addAll: ea ].
	"Kluge to make the ranges work."
	endTimes from: startDateAndTime to: (DateAndTime year: 2029 day: 1) do: [ :ea | startOrLater addAll: ea ].
	(startOrLater intersection: endOrEarlier) do: [ :ea | aBlock value: ea value: (self at: ea) ].
]

{ #category : #enumerating }
DateTree >> do: aBlock [
	events do: aBlock.
]

{ #category : #enumerating }
DateTree >> during: aTimespan [
	"Return all events occuring within a given timespan"
	
	^ self between: aTimespan start and: aTimespan end
]

{ #category : #accessing }
DateTree >> endTimes [
	^ endTimes
]

{ #category : #accessing }
DateTree >> first [
	| timespans |
	timespans := startTimes first 
		asSortedCollection: [ :a :b | a start <= b start ].
	^ events 
		at: timespans first
		ifAbsent: [ self errorEmptyCollection ]
]

{ #category : #'initialize-release' }
DateTree >> initialize [
	startTimes := BTree new.
	endTimes := BTree new.
	events := Dictionary new
]

{ #category : #accessing }
DateTree >> keys [
	| keys |
	keys := Set new.
	self keysAndValuesDo: [:k :v | keys add: k].
	^ keys
]

{ #category : #enumerating }
DateTree >> keysAndValuesDo: aBlock [
	events keysAndValuesDo: aBlock.
]

{ #category : #accessing }
DateTree >> last [
	| timespans |
	timespans := endTimes last 
		asSortedCollection: [ :a :b | a end <= b end ].
	^ events 
		at: timespans last
		ifAbsent: [ self errorEmptyCollection ]
]

{ #category : #adding }
DateTree >> removeKey: aTimespan [
	self removeKey: aTimespan ifAbsent: [ self error: aTimespan printString, ' not found' ].
]

{ #category : #adding }
DateTree >> removeKey: aTimespan ifAbsent: exceptionBlock [
	| set |
	events removeKey: aTimespan ifAbsent: [^ exceptionBlock].
	
	"If we got here, we should be able to remove the start and end caches too."
	set := (startTimes at: aTimespan start) remove: aTimespan; yourself.
	set isEmpty ifTrue: [ startTimes removeKey: aTimespan start ].
	set := (endTimes at: aTimespan end) remove: aTimespan; yourself.
	set isEmpty ifTrue: [ endTimes removeKey: aTimespan end ].
]

{ #category : #accessing }
DateTree >> startTimes [
	^ startTimes
]

{ #category : #enumerating }
DateTree >> within: aDuration of: aDateAndTime [
	"Returns all events within the given duration from the given date, in either direction."
	
	^ self between: (aDateAndTime - aDuration) and: (aDateAndTime + aDuration)
]
