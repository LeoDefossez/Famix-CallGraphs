"
I am a call graph node created when an error occured during the callgraph construction.
"
Class {
	#name : 'FamixCallGraphErrorNode',
	#superclass : 'FamixAbstractCallGraphNode',
	#instVars : [
		'reason',
		'exception'
	],
	#category : 'Famix-CallGraphs',
	#package : 'Famix-CallGraphs'
}

{ #category : 'accessing' }
FamixCallGraphErrorNode >> callees [

	^ #()
]

{ #category : 'testing' }
FamixCallGraphErrorNode >> isErrorNode [

	^ true
]

{ #category : 'testing' }
FamixCallGraphErrorNode >> isStub [

	^ self realMethod isStub
]
