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
"
Class {
	#name : 'FamixJavaCHABuilder',
	#superclass : 'FamixAbstractCallGraphBuilder',
	#instVars : [
		'visited',
		'worklist',
		'reflectiveHook'
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

	self entryPoints do: [ :aNode | worklist at: aNode id put: aNode ].

	[ worklist isEmpty ] whileFalse: [
			| node |
			node := worklist anyOne.
			worklist removeKey: node id.
			visited at: node id put: node.
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
				ifFalse: [ self addEdgesTo: aNode for: invocation types: invocation invokedEntity parentType possibleRuntimeTypes ] ].
			
	"We allow the user to define a block to add edges if reflection is involved and the user knows what to call"
	self reflectiveHook cull: aNode cull: self
]

{ #category : 'initialization' }
FamixJavaCHABuilder >> initialize [

	self flag: #todo. "Manage graph exploration:
	- Is there a path between two methods?
	- What are all the paths between two methods?
	- Is a not reacheable?"
	super initialize.
	worklist := Dictionary new.
	visited := Dictionary new
]

{ #category : 'building' }
FamixJavaCHABuilder >> nodeForMethodSignature: signature kind: kind stub: aBoolean [

	| node id |
	id := kind idFor: signature.
	visited at: id ifPresent: [ :aNode | ^ aNode ].
	worklist at: id ifPresent: [ :aNode | ^ aNode ].

	node := (aBoolean
		         ifTrue: [ FamixCallGraphStubNode ]
		         ifFalse: [ FamixCallGraphNode ]) methodSignature: signature kind: kind.

	aBoolean ifFalse: [ worklist at: id put: node ].

	^ node
]

{ #category : 'accessing' }
FamixJavaCHABuilder >> reflectiveHook [

	^ reflectiveHook ifNil: [ reflectiveHook := [ :node :builder | "Do nothing" ] ]
]

{ #category : 'accessing' }
FamixJavaCHABuilder >> reflectiveHook: anObject [

	reflectiveHook := anObject
]
