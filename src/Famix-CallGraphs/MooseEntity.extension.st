Extension { #name : 'MooseEntity' }

{ #category : '*Famix-CallGraphs' }
MooseEntity >> idFor: aMethodSignature [

	^ self hash bitXor: aMethodSignature hash
]
