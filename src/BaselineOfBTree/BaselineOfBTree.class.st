Class {
	#name : #BaselineOfBTree,
	#superclass : #BaselineOf,
	#instVars : [
		'root'
	],
	#category : #BaselineOfBTree
}

{ #category : #baselines }
BaselineOfBTree >> baseline: spec [
	<baseline>
	spec for: #common do: [ spec package: 'BTree' ]
]
