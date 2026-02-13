Extension { #name : 'FamixTType' }

{ #category : '*Famix-CallGraphs' }
FamixTType >> implementesMethodEquivalentTo: aMethod [

	^ (self methodsNamed: aMethod name) anySatisfy: [ :method | method isImplementationOf: aMethod ]
]

{ #category : '*Famix-CallGraphs' }
FamixTType >> methodsNamed: aName [
	"We use a cache for speed reasons. We will probably get multiple time through here and we need to have a fast way to get the methods of the right name.
	
	Checking the size before the name for speed reasons."

	| nameSize |
	nameSize := aName size.
	^ (self cacheAt: #methodsMap ifAbsentPut: [ IdentityDictionary new ])
		  at: aName
		  ifAbsentPut: [ self methods select: [ :method | method name size = nameSize and: [ method name = aName ] ] ]
]

{ #category : '*Famix-CallGraphs' }
FamixTType >> possibleRuntimeTypes [

	^ self subclassResponsibility
]
