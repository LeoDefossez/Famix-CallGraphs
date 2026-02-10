Extension { #name : 'FamixTType' }

{ #category : '*Famix-CallGraphs' }
FamixTType >> implementesMethodEquivalentTo: aMethod [

	^ self methods
		  detect: [ :method | method isImplementationOf: aMethod ]
		  ifFound: [ :method | true ]
		  ifNone: [ false ]
]

{ #category : '*Famix-CallGraphs' }
FamixTType >> possibleRuntimeTypes [

	^ self subclassResponsibility
]
