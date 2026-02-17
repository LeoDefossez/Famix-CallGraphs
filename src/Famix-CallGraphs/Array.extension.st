Extension { #name : 'Array' }

{ #category : '*Famix-CallGraphs' }
Array >> addMethodForCallGraph: aMethod [
	"I am here for performance reasons in the call graphs. See comment in FamixTType>>methodsNamed:"

	^ self copyWith: aMethod
]
