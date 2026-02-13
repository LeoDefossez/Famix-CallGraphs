Extension { #name : 'FamixTMethod' }

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> asCallGraphNode [

	^ FamixCallGraphNode methodSignature: self signature kind: self parentType
]

{ #category : '*Famix-CallGraphs' }
FamixTMethod >> orderedParameters [

	^ self cacheAt: #orderedParameters ifAbsentPut: [ self parameters sorted: [ :method | method sourceAnchor startPos ] ascending ]
]
