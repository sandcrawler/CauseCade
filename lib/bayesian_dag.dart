import 'node.dart';
import 'link.dart';
import 'dart:collection';
import 'package:causecade/vector_math.dart';
import 'package:dartson/dartson.dart';

@Entity()
class BayesianDAG{

  String name = 'unnamed network';

  List<node> NodeList = new List();
  List<link> LinkList = new List();

  @Property(ignore:true)
  int observationCount = 0; //Number of nodes in network that are observed/measured
                        //non essential value, only for display

  BayesianDAG();

  //name setting and getting
  set hasName(String newName) => name = newName;

  String get hasName => name;

  //basic network query
  int numNodes(){
    return NodeList.length;
  }

  List<node> getNodes(){
    return NodeList;
  }

  int numLinks(){
    return LinkList.length;
  }

  List<link> getLinks(){
    return LinkList;
  }

  int getObservationCount(){
    return observationCount;
  }

  //detailed node query

  int nodeDegree(node nodeIn){
    return nodeIn.getOutGoing().length+nodeIn.getInComing().length;
  }

  int outDegree(node nodeIn){
    return nodeIn.getOutGoing().length;
  }

  int inDegree(node nodeIn){
    return nodeIn.getInComing().length;
  }

  node findNode(String nameIn){ //returns the node object associated with a name
    for(var i=0; i<NodeList.length;i++){
      if (NodeList[i].getName()==nameIn){
        return NodeList[i];
      }
    };
    print('no node was found, please re-enter your option');
  }

  // this checks whether there is a connection between two nodes
  // (this could be both ways)
  bool isConnected(node node1, node node2){
    if(node1.getOutGoing()[node2]!=null || node2.getOutGoing()[node1]!=null){
      print('they are connected');
      return true;
    }
    else{
      print('they are not connected');
      return false;
    }
  }

  //checks and returns the edge of the node origin to target
  // - note this is a directed check, unlike isConnected
  link getLink(node nodeOrigin,node nodeTarget){
    return nodeOrigin.getOutGoing()[nodeTarget];
  }

  //adding and removing nodes and links
  void insertNode(String newName, int stateCount){
    node NewNode = new node();
    NewNode.initialiseNode(newName, stateCount);
    NodeList.add(NewNode);
  }

  void insertLink(node nodeOrigin, node nodeTarget){
    if (!isConnected(nodeOrigin,nodeTarget)){ /*!isConnected(node1, node2)*/
      link newLink = new link();
      newLink.origin=nodeOrigin;
      newLink.target=nodeTarget;

      nodeOrigin.addOutgoing(nodeTarget,newLink);
      nodeTarget.addIncoming(nodeOrigin,newLink);

      LinkList.add(newLink);
      print("created link");
      nodeTarget.setRootStatus(false); //this can now no longer be a root node

    }
    else{
      print("these nodes are already connected");
    }
  }

  /*needs more verification to see whether this is functional - update links*/
  bool removeNode(String nameIn){
    var removingHolder = new List<link>();
    for(var i =0; i< NodeList.length;i++){

      if(NodeList[i].getName()==nameIn){
        NodeList[i].getOutGoing().values.forEach((link){
          print(link);
          removingHolder.add(link);
        });
        NodeList[i].getInComing().values.forEach((link){
          print(link);
          removingHolder.add(link);
        });

        //This is done because nodes cant be removed during forEach loop
        for(var j=0; j< removingHolder.length;j++){
          removeEdge(removingHolder[j]);
        }
        removingHolder.clear();

        NodeList.removeAt(i);
        print("node removed");
        return true;
      }
    }
    print("no such node found");
    return false;
  }

  void removeEdge(link linkIn){
    //this will remove the map value from the vertices' link map
    linkIn.getEndPoints()[0].getOutGoing().remove(linkIn.getEndPoints()[1]);
    linkIn.getEndPoints()[1].getInComing().remove(linkIn.getEndPoints()[0]);
    // this will remove the actual link instance
    LinkList.remove(linkIn);
    print('removed link');
    checkRootStatus(); //one node may now be a root
  }

  //searching the network (to see what is reachable) (depth first search)

  void DFS(node startNode,  Set<node> known,Map<node,link> forest ){
    known.add(startNode);

    startNode.getOutGoing().keys.forEach((connectedNode){
      if (!known.contains(connectedNode)){
        var map ={};
        map[connectedNode]=startNode.getOutGoing()[connectedNode];
        forest.addAll(map);

        DFS(connectedNode, known, forest);
      }
    });
  }

  void checkNodes(){
    StringBuffer Buffer = new StringBuffer();
    Buffer.write('> Requested Node Status of the Network\n');
    int errorCount=0;
    NodeList.forEach((node){
      if(!node.getLinkMatrixStatus()){
        errorCount++;
        Buffer.write('Node: ' + node.getName() +
            ' - has an inproperly configured Link Matrix\n');
      }
    });
    Buffer.write('\t['+ errorCount.toString() +
        '] nodes with inproper LinkMatrix values found,'
            ' please enter proper values.');
    print(Buffer.toString());
  }

  void checkFlags(){ //this could use some fancier print message
    print('flagged nodes are given below');
    NodeList.forEach((node){
      if(node.getFlaggedStatus()){
        print('The following Node is Currently Flagged: ' + node.getName());
      }
    });
  }

  bool checkFlagsStatus(){
    for(int i=0; i<NodeList.length;i++){
      if(NodeList[i].getFlaggedStatus()){
        //print('we found at least one flag');
        return true;

      }
    };

    return false;
  }

  void checkObservationCount(){
    observationCount=0;
    NodeList.forEach((node){
      if(node.isInstantiated){
        observationCount++;
      }
    });
  }

  //goes over each node and checks if they are a root node
  //updates the isRootNode property of node objects
  //must be called in a state where the incoming and outgoing nodes are up to date
  void checkRootStatus(){
    NodeList.forEach((node){
      if(node.getInComing().length==0){ //if node has no parents
        node.setRootStatus(true);
      }
      else{ //node has at least 1 parent
        node.setRootStatus(false);
      }
    });
  }

  bool checkCyclic(){
    List<node> copyNodes = new List<node>.from(NodeList);
    List<link> copyLinks = new List<link>.from(LinkList);

    List<link> holder = new List<link>();
    List<link> linkBackup = new List<link>();
    node nodeHolder;

    List<node> sorted = new List<node>();
    Queue<node> noIncomingEdges = new Queue<node>();

    copyNodes.forEach((node){
      if(node.getInComing().isEmpty){
        noIncomingEdges.add(node);
      }
    });

    while(noIncomingEdges.length != 0){
      sorted.add(noIncomingEdges.removeFirst());
      print(sorted);
      sorted.last.getOutGoing().keys.forEach((node){
        holder.add(node.getInComing()[sorted.last]);
        linkBackup.add(node.getInComing()[sorted.last]);
      });
      for(var i =0;i<holder.length;i++){

        //print(holder[i].getEndPoints()[1].getName() + '<-  name of target');
        nodeHolder = holder[i].getEndPoints()[1];
        removeEdge(holder[i]);

        if(nodeHolder.getInComing().isEmpty){
          noIncomingEdges.add(nodeHolder);
          //print('found new no incoming node');
        }

      }
      holder.clear();
    }

    if(LinkList.isEmpty){
      reintroduceEdges(linkBackup);
      return false;
    }
    else{
      reintroduceEdges(linkBackup);
      return true;
    }

  }

  void reintroduceEdges(List<link> edgesToReadd){
    edgesToReadd.forEach((link){
      insertLink(link.getEndPoints()[0],link.getEndPoints()[1]);
    });
  }

  //MAIN FUNCTIONALITY (

  //forceStart will start the network on the first node. this is used
  //when one wishes to have evidence propagated ina  newly loaded network
  void updateNetwork([bool forceStart]){
    //set the flag locks (they should all be false at the start)
    NodeList.forEach((node){node.setFlagLock(false);});
    if(forceStart==null) {
      //first find a node that is flagged (ideally this would be just 1)
      for (var i = 0; i < NodeList.length; i++) {
        if (NodeList[i].getFlaggedStatus()) {
          print('>>> Starting Update on: ' + NodeList[i].getName());
          recursiveUpdate(NodeList[i]);
          break;
        }
      }
    }
    else{
      print('>>> Starting Update on: ' + NodeList.first.getName());
      recursiveUpdate(NodeList.first);
    }

    //set all the flags to false. We take here that the network flagging
    //status is simple. i.e. only 1 flagged at a time at the start of the
    //updateNetworkNew() call.
    NodeList.forEach((node){node.clearFlags();});
  }

  void recursiveUpdate(node flaggedNode){
    //first we update this node
    print('> recursive call on: '+ flaggedNode.getName());
    updateNode(flaggedNode);
    //this node will now (possibly) have flagged other nodes
    NodeList.forEach((node){
      //if node is flagged by this node AND has not been updated this cycle
      if(node.getFlaggingNode()==flaggedNode&&node.getFlagLockStatus()==false){
        //print('[update] node flagged by: '+flaggedNode.getName() + " is: "+ node.getName());
        recursiveUpdate(node);
      }
    });
  }

  void updateNetworkOld(){ // This may be changed to a thing that loops over all nodes,
    // as this only updates max 1 nodes per call.
    // the only problem with that is that the order in which the
    // network is updated matters, as otherwise itll start finding
    // itself working with null values.
    // Will eventually implement method that avoids these problems
    // and allows updating the whole network with one call
    int iterationTracker=1;
    while(checkFlagsStatus()){ //TODO temporarily set to update once at a atime
      print('<<<<<<<<<<<<< We are on Iteration: '+ iterationTracker.toString() +' >>>>>>>>>>>>>>>>>>>>>>');
      for(var i=0; i<NodeList.length;i++) {
        if (NodeList[i].getFlaggedStatus()) {
          print('> Updating The Network - Propagating Evidence...');
          print('updating node: ' + NodeList[i].getName());
          print('flaggin node was: ' + NodeList[i].getFlaggingNode().toString());
          // print('fetching Pi Messages...');
          NodeList[i].ComputePiEvidence();

          //This is currently not yet implemented
          // - the network can only propagate downwards
          //  print('fetching lambda Messages...');
          NodeList[i].ComputeLambdaEvidence();

          NodeList[i].UpdatePosterior();
          print('Updating Probability...' +
              NodeList[i].getProbability().toString());
          print('Single Update Cycle Complete.\n');
          //break; //enable this if you only want one node updating at a time (useful for debugging)
        }
      }
      iterationTracker++;
      //To avoid infinite loops in case of a bug we explicity set the maximum
      //number of iterations here. I cannot easily see a scenario where
      //more than 100 iterations are needed.
      if(iterationTracker>=5){
        break;
      }
    };

  }

  void updateNode(node NodeIn){
    //print('updating node: ' + NodeIn.getName());
    NodeIn.ComputePiEvidence();
    //print('fetching lambda Messages...');
    NodeIn.ComputeLambdaEvidence();
    NodeIn.UpdatePosterior();
    NodeIn.setFlagLock(true); //lock this node (prevent updating again in cycle)
  }

  //should only be called for debugging
  //forces single node to be updated
  //difference with updateNode() : this does not flaglock node + more printing
  void forceUpdateNode(node NodeIn){
    print('<<<<<<<<<<<<< Forced Update >>>>>>>>>>>>>>>>>>>>>>');


        print('updating node: ' + NodeIn.getName());
        // print('fetching Pi Messages...');
      NodeIn.ComputePiEvidence();

        //This is currently not yet implemented
        // - the network can only propagate downwards
          //print('fetching lambda Messages...');
     NodeIn.ComputeLambdaEvidence();

      NodeIn.UpdatePosterior();
        print('Updating Probability...' +
            NodeIn.getProbability().toString());
        print('Single Update Cycle Complete.\n');
        //break; //enable this if you only want one node updating at a time (useful for debugging)

      NodeIn.clearFlags(); //this needs to be done to prevent trouble
                           //when the node is instantiated
                           //todo: make this a little more consistent
  }

  //Enter Hard evidence for a node
  //Hard Evidence(instantiated) means the probability of the node cannot change]
  //Node can be both root node and instantiated
  void setEvidence(String nodeName,Vector EvidenceToSet){
    NodeList.forEach((node){
      //we choose to let the user give a name,
      //may change to referencing a node object later on (better performance)
      if (node.getName()== nodeName){
        node.setProbability(EvidenceToSet);
        print('node: ' + node.getName() + ' has been updated (instantiated)'
            'to probability: ' + node.getProbability().toString());
      }
    });
  }

  //sets the prior probability for the node. This is the probability a root
  //node will have. This differs from instantiating a node, with the regard that
  //a root node can still change it's probability in the face of lambda evidence
  //This method should ONLY be called on root nodes (with no parent).
  void setPrior(String nodeName, Vector PiEvidenceToSet){
    NodeList.forEach((node){
      //we choose to let the user give a name,
      //may change to referencing a node object later on (better performance)
      if (node.getName()== nodeName){
        if(node.getEvidenceStatus()){ //informative message
          print('you are setting a prior for an instantiated node,'
              'the probability wont be affected until you remove instantiation.');
        }

        node.setRootStatus(true); //this to inform users this is a root node
        node.setPiEvidence(PiEvidenceToSet); //set the PiEvidence;
        node.UpdatePosterior(); //have new evidence come into effect

        print('node: ' + node.getName() + ' has a new Prior Probability: '
            + node.getProbability().toString());
      }
    });
  }


  //should be called after loading a new network from JSON
  void setupLoadedNetwork(){
    //print(NodeList.toString());
    //print(LinkList.toString());
    print('[DAG] setting up new network...');


  //fixing links (we only have strings, we want references to node objects)
    LinkList.forEach((link){
      //ensures link now also have proper object reference
      link.origin=findNode(link.stringEndpoints[0]);
      link.target=findNode(link.stringEndpoints[1]);
    });

  //setting up links
    LinkList.forEach((link){ //we assume we have a populated linklist (see JSON)
      //populate the outgoing and incoming lists of each node object
      //(this could be saved explicitly in json, but this would be duplicate information)
      link.origin.addOutgoing(link.target,link);
      link.target.addIncoming(link.origin,link);
    });
  //setting up nodes
    NodeList.forEach((node){
      //statement below has redundant arguments. Retain for now to maintain
      //backwards compatibility
      //TODO: remove arguments initialiseNode function
      node.initialiseNodeSecondary();
    });

    checkRootStatus(); //ensure the root status of the loaded nodes is correct

  //ensuring the implicit values are updated and network is fully operational
    //we first update the matrix labels. I do not know why this is required.
    //Will fix this once I do the big refactoring of the node class.
    //TODO: avoid having to explictly determine labels first
    NodeList.forEach((node){
      if(!node.isRootNode) {
        node.clearMatrixLabels();
        node.generateMatrixLabels(0, node
            .getInComing()
            .keys
            .length, '');
      }
    });
    //then we compute some of the probabilities and such for each node
    //as we may only have specified the CPTs but not the posteriors accurately
    /*forceUpdateNode(NodeList.first); //ensure we have some flagged nodes*/
    updateNetwork(true); //call special forced update procedure
                    //which will ensure all the posteriors and lambdas are correct
    checkObservationCount(); //ensure this number is correct.
  }

  void clear(){ //reset the DAG
    NodeList.clear();
    LinkList.clear();
    name=null;
  }

  // Overview of what the flags are in this network

  String flagsToString(){
    var buffer = new StringBuffer();
    buffer.write('> Flag Status for network: '+ name + '\n');
    NodeList.forEach((node){
      buffer.write('Node: '+ node.getName() + ' is flagged: '+node.getFlaggedStatus().toString());
      if(node.getFlaggedStatus()){
        buffer.write(' by node: ' + node.getFlaggingNode().getName());
      }
      buffer.write(' and is locked: ' +node.getFlagLockStatus().toString());
      buffer.write('\n');
    });
    return buffer.toString();
  }

  //String representation of the network (very basic, for debugging)

  String toString(){
    var Buffer = new StringBuffer();
    Buffer.write('> Bayesian Network - Name: '+ name + ' Nodes: ' +
        NodeList.length.toString() + ' Links: ' +
        LinkList.length.toString() + '\n');
    for(var i =0; i<NodeList.length;i++){
      Buffer.write('Node: ' + NodeList[i].getName() + ' - Probabilities: ' +
          NodeList[i].getProbability().toString() + NodeList[i].getStateLabels().toString());
      Buffer.write('\n \t [outdegree]: ' + outDegree(NodeList[i]).toString() +
          ' connections ->');
      NodeList[i].getOutGoing().keys.forEach(
          (node){Buffer.write(node.getName() + ',');});
      Buffer.write('\n \t [indegree]: ' + inDegree(NodeList[i]).toString() +
          ' connections ->');
      NodeList[i].getInComing().keys.forEach(
          (node){Buffer.write(node.getName() + ',');});
      Buffer.write('\n');
    }
/*
    print(Buffer.toString());
*/
    return Buffer.toString();
  }


}