Extension { #name : 'MooseEntity' }

{ #category : '*Famix-CallGraphs' }
MooseEntity >> idFor: aMethodSignature [

	^ self mooseName , aMethodSignature
]
