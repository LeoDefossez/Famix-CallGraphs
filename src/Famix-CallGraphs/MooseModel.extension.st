Extension { #name : 'MooseModel' }

{ #category : '*Famix-CallGraphs' }
MooseModel >> resetCallGraphCaches [
	"Flushes the caches used by callgraph builders."

	(self allUsing: FamixTType) do: [ :type |
			type
				removeCache: #methodsMap;
				removeCache: #methodNames ].
	(self allUsing: FamixTMethod) do: [ :type | type removeCache: #orderedParameters ].
	(self allUsing: FamixTWithInheritances) do: [ :type | type removeCache: #applicableConcretizations ]
]
