Extension { #name : 'FamixCallGraph' }

{ #category : '*Famix-CallGraphs-Properties' }
FamixCallGraph >> allNodesWithAdditionalProperties [
	"Return every nodes with additionnal properties"

	^ self allNodes select: [ :each | each additionalProperties isNotNil ]
]
