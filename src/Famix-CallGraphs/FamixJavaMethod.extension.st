Extension { #name : 'FamixJavaMethod' }

{ #category : '*Famix-CallGraphs' }
FamixJavaMethod >> isImplementationOf: aMethod [ 
	"Return true if I am an implemented method equivalent to the method as parameter.
	
	A method is equivalent if their name are the same and parameters are the same. We already verified the name before getting here.
	
	There is a tricky case with parametrics because in case a type is a type parameter, we need to find its concretization to have the real type in the context."

	self isMethodDefinition ifFalse: [ ^ false ]. "We reject method declarations"

	self == aMethod ifTrue: [ ^ true ]. "fastest case"
	
	self parameters size = aMethod parameters size ifFalse: [ ^ false ].

	"We need to ensure the type of each parameter is the same after applying the concretizations to the type parameters"
	self orderedParameters with: aMethod orderedParameters do: [ :param1 :param2 |
			| realType1 realType2 |

			realType1 := param1 typing declaredType.
			realType1 isClass ifFalse: [ "We have a type parameter and we need to find its concretization."
					| aName |
					aName := realType1 name. "Saving the name to save time in the loop"
					aMethod parentType applicableConcretizations
						detect: [ :concretization | concretization typeArgument isClass and: [ concretization typeParameter name = aName ] ]
						ifFound: [ :concretization | realType1 := concretization typeArgument ] ].

			realType2 := param2 typing declaredType.
			realType2 isClass ifFalse: [ "We have a type parameter and we need to find its concretization."
					| aName |
					aName := realType2 name. "Saving the name to save time in the loop"
					self parentType applicableConcretizations
						detect: [ :concretization | concretization typeArgument isClass and: [ concretization typeParameter name = aName ] ]
						ifFound: [ :concretization | realType2 := concretization typeArgument ] ].

			"We compare the name and not the instances because they can be the same type coming from different classes that are equivalent."
			realType1 name = realType2 name ifFalse: [ ^ false ] ].

	^ true
]
