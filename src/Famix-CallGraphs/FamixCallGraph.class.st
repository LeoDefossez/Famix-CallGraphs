Class {
	#name : 'FamixCallGraph',
	#superclass : 'Object',
	#instVars : [
		'entryPoints',
		'errors'
	],
	#category : 'Famix-CallGraphs',
	#package : 'Famix-CallGraphs'
}

{ #category : 'adding' }
FamixCallGraph >> addError: aNode [

	errors add: aNode
]

{ #category : 'helpers' }
FamixCallGraph >> allNodes [

	^ self entryPoints flatCollectAsSet: #withAllCallees
]

{ #category : 'accessing' }
FamixCallGraph >> entryPoint [

	self entryPoints size = 1 ifFalse: [ self error: 'This method should be called only if the graph has 1 entry point.' ].
	^ self entryPoints anyOne
]

{ #category : 'accessing' }
FamixCallGraph >> entryPoints [

	^ entryPoints
]

{ #category : 'accessing' }
FamixCallGraph >> entryPoints: aCollection [

	entryPoints := aCollection collect: [ :method |
			               method isMooseObject
				               ifTrue: [ method asCallGraphNode ]
				               ifFalse: [ method ] ]
]

{ #category : 'accessing' }
FamixCallGraph >> errorNodes [

	^ errors
]

{ #category : 'initialization' }
FamixCallGraph >> initialize [

	super initialize.
	errors := IdentitySet new
]

{ #category : 'helpers' }
FamixCallGraph >> numberOfNodes [

	^ self allNodes size
]
