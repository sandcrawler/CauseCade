import 'Node.dart';
import 'Link.dart';
import 'dart:collection';

/*TODO
* implement a way to check whether the network has accidentally become cyclic
* find a way to refer to nodes by their name
*/

class BayesianDAG{

  List<node> NodeList = new List();
  List<link> LinkList = new List();

  BayesianDAG(){
    print("DAG Created!");

  }

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

  //this checks whether there is a connection between two nodes (this could be both ways)
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

  //checks and returns the edge of the node origin to target - note this is a directed check, unlike isConnected
  link getLink(node nodeOrigin,node nodeTarget){
    return nodeOrigin.getOutGoing()[nodeTarget];
  }

  //adding and removing nodes and links
  insertNode(newName){
    node NewNode = new node(newName);
    NodeList.add(NewNode);
  }

  insertLink(node nodeOrigin, node nodeTarget){
    if (!isConnected(nodeOrigin,nodeTarget)){ /*!isConnected(node1, node2)*/
      link newLink = new link(nodeOrigin,nodeTarget);

      nodeOrigin.addOutgoing(nodeTarget,newLink);
      nodeTarget.addIncoming(nodeOrigin,newLink);

      LinkList.add(newLink);
      print("created link");
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

        for(var j=0; j< removingHolder.length;j++){ //This is done because nodes cant be removed during forEach loop
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

  removeEdge(link linkIn){
    //this will remove the map value from the vertices' link map
    linkIn.getEndPoints()[0].getOutGoing().remove(linkIn.getEndPoints()[1]);
    linkIn.getEndPoints()[1].getInComing().remove(linkIn.getEndPoints()[0]);
    // this will remove the actual link instance
    LinkList.remove(linkIn);
    print('removed link');
  }

  //searching the network (to see what is reachable) (depth first search)

  DFS(node startNode,  Set<node> known,Map<node,link> forest ){
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

        print(holder[i].getEndPoints()[1].getName() + '<-  name of target');
        nodeHolder = holder[i].getEndPoints()[1];
        removeEdge(holder[i]);

        if(nodeHolder.getInComing().isEmpty){
          noIncomingEdges.add(nodeHolder);
          print('found new no incoming node');
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

  reintroduceEdges(List<link> edgesToReadd){
    edgesToReadd.forEach((link){
      insertLink(link.getEndPoints()[0],link.getEndPoints()[1]);
    });
  }

  //MAIN FUNCTIONALITY (inference) //VERY MUCH NOT FUNCTIONAL AT THE CURRENT TIME

  returnDistribution(String nodename){
    node selectedNode = findNode(nodename);
    if(selectedNode!=null){
      print('node selected for inference: ' + selectedNode.getName());
      /*selectedNode.updateDistribution()*/

      print('\t{Probability Distribution : ' + selectedNode.getProbability().toString());





    }
    else{
      print('you must have given an incorrect nodename, please try again');
    }

  }

  //String representation of the network (very basic, for debugging)

  String toString(){
    var Buffer = new StringBuffer();
    Buffer.write('Network Representation - Nodes: ' + NodeList.length.toString() + ' Links: ' + LinkList.length.toString() + '\n');
    for(var i =0; i<NodeList.length;i++){
      Buffer.write('Node: ' + NodeList[i].getName() + '\n');
      Buffer.write('\t [outdegree]: ' + outDegree(NodeList[i]).toString() + ' connections ->');
      NodeList[i].getOutGoing().keys.forEach((node){Buffer.write(node.getName() + ',');});
      Buffer.write('\n');
      Buffer.write('\t [indegree]: ' + inDegree(NodeList[i]).toString() + ' connections ->');
      NodeList[i].getInComing().keys.forEach((node){Buffer.write(node.getName() + ',');});
      Buffer.write('\n');
    }
/*
    print(Buffer.toString());
*/
    return Buffer.toString();
  }
}