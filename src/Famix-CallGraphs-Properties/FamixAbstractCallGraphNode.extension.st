Extension { #name : 'FamixAbstractCallGraphNode' }

{ #category : '*Famix-CallGraphs-Properties' }
FamixAbstractCallGraphNode >> additionalProperties [

	^ FamixCallGraphAdditionalProperties current at: self ifAbsent: [ nil ]
]
