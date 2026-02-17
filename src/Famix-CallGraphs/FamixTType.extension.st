Extension { #name : 'FamixTType' }

{ #category : '*Famix-CallGraphs' }
FamixTType >> implementesMethodEquivalentTo: aMethod [

	^ (self methodsNamed: aMethod name)
		  ifNil: [ false ]
		  ifNotNil: [ :methods | methods anySatisfy: [ :method | method isImplementationOf: aMethod ] ]
]

{ #category : '*Famix-CallGraphs' }
FamixTType >> methodsNamed: aName [
	"This method is more complex than necessary for speed reasons. This is where most of the time of the call graph building is spent so we did few optimizations:
	- Compare the lenght of names before the names 
	- Use the hash of the method name as key because the name cannot work with an IdentityDictionary and a simple Dictionary is slower
	- Do not create a collection if we have 0 or 1 method of the right name because the vast majority of collections will have less than 2 elements but their number will stress the GC (20% of the call graph building was spend in GC of those collections)
	
	Because of the last point we made FamixTMethod and UndefinedObject polymorphic with collections on the API used on my result."

	| nameSize |
	nameSize := aName size.
	^ (self cacheAt: #methodsMap ifAbsentPut: [ IdentityDictionary new: self methods size ]) at: aName hash ifAbsentPut: [
			  | result |
			  self methods do: [ :method | (method name size = nameSize and: [ method name = aName ]) ifTrue: [ result := result addMethodForCallGraph: method ] ].
			  result ]
]

{ #category : '*Famix-CallGraphs' }
FamixTType >> possibleRuntimeTypes [

	^ self subclassResponsibility
]
