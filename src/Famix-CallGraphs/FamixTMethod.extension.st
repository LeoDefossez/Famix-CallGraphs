Extension { #name : 'FamixTMethod' }

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> addMethodForCallGraph: aMethod [
	"I am here for performance reasons in the call graphs. See comment in FamixTType>>methodsNamed:"

	^ Array with: self with: aMethod
]

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> anySatisfy: aBlock [
	"For polymorphism with collection. Check the comment of FamixTType>>methodsNamed: for more info on this optimization."

	^ aBlock value: self
]

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> asCallGraphNode [

	^ FamixCallGraphNode methodSignature: self signature kind: self parentType
]

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> orderedParameters [

	^ self cacheAt: #orderedParameters ifAbsentPut: [ self parameters sorted: [ :method | method sourceAnchor startPos ] ascending ]
]
