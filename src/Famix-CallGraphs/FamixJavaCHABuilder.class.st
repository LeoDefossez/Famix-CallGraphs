"
I am a class used to build a CHA call graph for a Moose java model.

To be used you need to define entry points for your application lake this:

```st
	(FamixJavaCHABuilder entryPoints: (model allMethods select: [ :method | method name = 'main' ])) build
```

In case the program to analyze is using reflectivity, we might miss some edges. If the user knows some edges to add, it is possible to add them using the #reflectiveHook variable. 
For example:

```st
	(FamixJavaCHABuilder entryPoints: (model allMethods select: [ :method | method name = 'main' ]))
	reflectiveHook: [ :node :builder |
			(node kindName = 'Toto' and: [ node methodName = 'myMethod' ]) ifTrue: [
					node addCallee: (builder nodeForMethodSignature: 'myOtherMethod(String)' kind: (model allClasses detect: [ :class | class name = 'Titi' ]) stub: false) ] ];
	build
```

# Implementation detail

Originaly the implementation was using an `OrderedCollection` for the worklist and a `Set` for the visited list. But to check if we already have a node created for a method and kind it was taking a lot of time.
Now the implementation is using two `Dictionary` and is using a hash for key. This is here for performance reasons. 
This made a run go from 25min to 2min.

For performance I also cache the possible runtime types of the types since we access it a lot.
"
Class {
	#name : 'FamixJavaCHABuilder',
	#superclass : 'FamixAbstractCallGraphBuilder',
	#instVars : [
		'visited',
		'worklist',
		'reflectiveHook',
		'typesMap'
	],
	#category : 'Famix-CallGraphs',
	#package : 'Famix-CallGraphs'
}

{ #category : 'building' }
FamixJavaCHABuilder >> addEdgesTo: aNode for: invocation types: possibleRuntimeTypes [

	| nodes |
	nodes := possibleRuntimeTypes
		         select: [ :type |
				         [ type implementesMethodEquivalentTo: invocation invokedEntity ]
					         on: Error
					         do: [ :exception |
							         self addErrorTo: aNode invocation: invocation kind: type exception: exception  reason: 'An error occurend while trying to find the implementors of the invocked method. The model is not right.'.
							         false ] ]
		         thenCollect: [ :type | self nodeForMethodSignature: invocation invokedEntity signature kind: type stub: false ].
	nodes
		ifEmpty: [
				invocation invokedEntity isStub
					ifTrue: [ "In case we have an invocation to a stub method of an interface with no known implementation, we create a stub node"
						aNode addCallee: (self nodeForMethodSignature: invocation invokedEntity signature kind: invocation invokedEntity parentType stub: true) ]
					ifFalse: [ self addErrorTo: aNode invocation: invocation kind: invocation invokedEntity parentType exception: nil  reason: 'No matching node found. Either the model is wrong or the method has no implementor in the current model'. ] ]
		ifNotEmpty: [ nodes do: [ :node | aNode addCallee: node ] ]
]

{ #category : 'accessing' }
FamixJavaCHABuilder >> addErrorTo: aNode invocation: invocation kind: type exception: exception reason: reason [

	| errorNode |
	errorNode := (FamixCallGraphErrorNode methodSignature: invocation invokedEntity signature kind: type)
		             exception: exception;
		             reason: reason.
	^ aNode addCallee: errorNode
]

{ #category : 'building' }
FamixJavaCHABuilder >> build [

	self entryPoints do: [ :aNode | worklist at: aNode hash put: aNode ].

	[ worklist isEmpty ] whileFalse: [
			| node |
			node := worklist anyOne.
			worklist removeKey: node hash.
			visited at: node hash put: node.
			self computeCallGraphOf: node ].
		
	"If errors occured, inspect them."
	graph errorNodes ifNotEmpty: [ :collection | collection inspect ].

	^ graph
]

{ #category : 'building' }
FamixJavaCHABuilder >> computeCallGraphOf: aNode [

	aNode outgoingInvocations do: [ :invocation |
			(invocation isSuperInvocation or: [ invocation invokedEntity isConstructor ])
				ifTrue: [ self addEdgesTo: aNode for: invocation types: { invocation invokedEntity parentType } ]
				ifFalse: [ self addEdgesTo: aNode for: invocation types: (self possibleRuntimeTypesOf: invocation invokedEntity parentType) ] ].
			
	"We allow the user to define a block to add edges if reflection is involved and the user knows what to call"
	self reflectiveHook cull: aNode cull: self
]

{ #category : 'initialization' }
FamixJavaCHABuilder >> initialize [

	super initialize.
	worklist := IdentityDictionary new.
	visited := IdentityDictionary new.
	typesMap := IdentityDictionary new. "Used to cache the possible runtime types"

	self flag: #todo "Manage graph exploration:
	- Is there a path between two methods?
	- What are all the paths between two methods?
	- Is a not reacheable?"
]

{ #category : 'building' }
FamixJavaCHABuilder >> nodeForMethodSignature: signature kind: kind stub: aBoolean [

	| node id |
	id := kind idFor: signature. "This is the equivalent of the hash of the node to potentialy find."
	visited at: id ifPresent: [ :aNode | ^ aNode ].
	worklist at: id ifPresent: [ :aNode | ^ aNode ].

	node := (aBoolean
		         ifTrue: [ FamixCallGraphStubNode ]
		         ifFalse: [ FamixCallGraphNode ]) methodSignature: signature kind: kind.

	aBoolean ifFalse: [ worklist at: id put: node ].

	^ node
]

{ #category : 'building' }
FamixJavaCHABuilder >> possibleRuntimeTypesOf: aKind [

	^ typesMap at: aKind ifAbsentPut: [ aKind possibleRuntimeTypes ]
]

{ #category : 'accessing' }
FamixJavaCHABuilder >> reflectiveHook [

	^ reflectiveHook ifNil: [ reflectiveHook := [ :node :builder | "Do nothing" ] ]
]

{ #category : 'accessing' }
FamixJavaCHABuilder >> reflectiveHook: anObject [

	reflectiveHook := anObject
]
