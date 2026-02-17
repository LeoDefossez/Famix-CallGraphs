Extension { #name : 'UndefinedObject' }

{ #category : '*Famix-CallGraphs' }
UndefinedObject >> addMethodForCallGraph: aMethod [
	"I am here for performance reasons in the call graphs. See comment in FamixTType>>methodsNamed:"

	^ aMethod
]
