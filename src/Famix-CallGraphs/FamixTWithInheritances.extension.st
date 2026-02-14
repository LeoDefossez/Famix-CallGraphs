Extension { #name : 'FamixTWithInheritances' }

{ #category : '*Famix-CallGraphs' }
FamixTWithInheritances >> applicableConcretizations [

	^ self cacheAt: #applicableConcretizations ifAbsentPut: [
			  | concretizations |
			  concretizations := Set new.
			  self withSuperclassesDo: [ :class |
					  class superInheritances
						  select: [ :inheritance | inheritance isParametricAssociation ]
						  thenDo: [ :inheritance | concretizations addAll: inheritance concretizations ] ].
			  concretizations ]
]
