Extension { #name : 'FamixJavaMethod' }

{ #category : '*Famix-CallGraphs' }
FamixJavaMethod >> isEquivalentTo: aMethod [
	"A method is equivalent if their name are the same and parameters are the same.
	
	There is a tricky case with parametrics because in case a type is a type parameter, we need to find its concretization to have the real type in the context."
	
	self name size = aMethod name size ifFalse: [ ^ false ]. "This might seems useless since we compare the name right after, but we pass so much in this method that it has an impact on perfs. It is faster to compare integer than strings"
	self name = aMethod name ifFalse: [ ^ false ].
	
	self parameters size = aMethod parameters size ifFalse: [ ^ false ].

	"We need to ensure the type of each parameter is the same after applying the concretizations to the type parameters"
	self orederedParameters with: aMethod orederedParameters do: [ :param1 :param2 |
			| realType1 realType2 |

			realType1 := param1 typing declaredType.
			realType1 isClass ifFalse: [ "We have a type parameter and we need to find its concretization."
					aMethod parentType applicableConcretizations
						detect: [ :concretization | concretization typeArgument isClass and: [ concretization typeParameter name = realType1 name ] ]
						ifFound: [ :concretization | realType1 := concretization typeArgument ] ].

			realType2 := param2 typing declaredType.
			realType2 isClass ifFalse: [ "We have a type parameter and we need to find its concretization."
					self parentType applicableConcretizations
						detect: [ :concretization | concretization typeArgument isClass and: [ concretization typeParameter name = realType2 name ] ]
						ifFound: [ :concretization | realType2 := concretization typeArgument ] ].

			"We compare the name and not the instances because they can be the same type coming from different classes that are equivalent."
			realType1 name = realType2 name ifFalse: [ ^ false ] ].

	^ true
]

{ #category : '*Famix-CallGraphs' }
FamixJavaMethod >> isImplementationOf: aMethod [ 
	"Return true if I am an implemented method equivalent to the method as parameter."
	
	self isMethodDefinition ifFalse: [ ^false ]. "Return false if I am a declaration and not an implementation."
	
	self == aMethod ifTrue: [ ^ true ]. "fastest case"
	
	^ self isEquivalentTo: aMethod 
]
