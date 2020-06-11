/* Data reader --> this class should not be changed unless you know what you're doing! */

class GraphData {
  
  HashMap<Integer, String> nodeIDs = new HashMap<Integer, String>();
  HashMap<Integer, String[]> edgeIDs = new HashMap<Integer, String[]>();
  HashMap<String, float[]> coordIDs = new HashMap<String, float[]>();
  
  Table pcaTable;
  
  public GraphData( JSONObject metadata, JSONObject simdata ){
    
    pcaTable = loadTable("pca_centroids_updated.csv", "header");
    
    // map pca centroid id's to their coordinates
    for( int i = 0; i < pcaTable.getRowCount(); i++ ){
      String nodeID = pcaTable.getRow(i).getString(0).trim();
      float y = pcaTable.getRow(i).getFloat(1);
      float x = pcaTable.getRow(i).getFloat(2);
      
      float [] coord = new float[2];
      coord[0] = x;
      coord[1] = y;
      // nodeID (like "pca1") now is mapped to its corresponding coordinate value
      coordIDs.put(nodeID, coord);
    }
    
    // read through metadata nodes to get id values
    JSONArray metaNodes = metadata.getJSONArray("nodes");
    for( int i = 0; i < metaNodes.size(); i++ ){
      JSONObject n = metaNodes.getJSONObject(i);
      String id = n.getString("id");
      
      nodeIDs.put(i, id);
    }
    
    // read through metadata edges to get source/target node id's
    JSONArray metaEdges = metadata.getJSONArray("edges");
    for( int i = 0; i < metaEdges.size(); i++ ){
      JSONObject e = metaEdges.getJSONObject(i);
      String source = e.getString("node_from");
      String target = e.getString("node_to");
      String [] ids = new String[2];
      ids[0] = source;
      ids[1] = target;
      
      edgeIDs.put(i, ids);
    }
    
    // read through real simulation run data, here we go bois good luck 
    JSONArray sims = simdata.getJSONArray("simulation");
    // letting simRuns hold an additional simRun, where simRun[0] will be the average case for everything
    simRuns = new SimulationRun[sims.size()+1];
   
    /* THE FOLLOWING VARIABLES ARE USED FOR THE AVERAGE SIMULATION RUN DATA */
    HashMap<String, Node> idsAVG = new HashMap<String, Node>();
    Node [] nodesAVG = new Node[nodeIDs.size()];
    Edge [] edgesAVG = new Edge[edgeIDs.size()];
    int totalSims = 0;
   
    for( int i = 0; i < nodeIDs.size(); i++ ){
      Node node = new Node( nodeIDs.get(i), 0, 0, 0, coordIDs.get(nodeIDs.get(i)) );
      idsAVG.put( nodeIDs.get(i), node);
      nodesAVG[i] = node;
    }
    
    for( int i = 0; i < edgeIDs.size(); i++ ){
      String [] nodeInfo = edgeIDs.get(i);
      Node source = idsAVG.get(nodeInfo[0]);
      Node target = idsAVG.get(nodeInfo[1]);
      Edge edge = new Edge( source, target, 0, 0, 0 );
      edgesAVG[i] = edge;
    }
    /* END AVERAGE CODE */

    for( int i = 0; i < sims.size(); i++ ){

      // 's' is the current simulation run
      JSONObject currSim = sims.getJSONObject(i);
      
      // make a hashmap for the nodes for this current simrun
      HashMap<String, Node> nodeFromID = new HashMap<String, Node>();
      
      Node [] nodes = new Node[nodeIDs.size()];
      
      // iterate over the nodes for this simulation run
      JSONArray n = currSim.getJSONArray("nodes");
      for( int j = 0; j < n.size(); j++ ){
        JSONObject currNode = n.getJSONObject(j);
        
        // grab info for this current node
        float dr = currNode.getFloat("dem_req");
        float ds = currNode.getFloat("dem_serv_avg");
        float fr = currNode.getFloat("failure_ratio");
        
        Node node = new Node( nodeIDs.get(j), dr, ds, fr, coordIDs.get(nodeIDs.get(j)) );
          
        nodeFromID.put( nodeIDs.get(j), node );
        nodes[j] = node;
        
        /* for averages purpose */
        Node AVGnode = nodesAVG[j];
        AVGnode.demReq += dr;
        AVGnode.demServ += ds;
        AVGnode.failRate += fr;
      }
      
      Edge [] edges = new Edge[edgeIDs.size()];
      
      // iterate over the edges for this simulation run
      JSONArray e = currSim.getJSONArray("edges");
      for( int j = 0; j < e.size(); j++ ){
        JSONObject currEdge = e.getJSONObject(j);
        
        // grab info for this current edge
        float mt = currEdge.getFloat("max_transfer");
        float at = currEdge.getFloat("actual_transfer_avg");
        float sr = currEdge.getFloat("success_ratio");
        
        // grab the actual nodes from this current edge
        String [] nodeInfo = edgeIDs.get(j);
        Node source = nodeFromID.get(nodeInfo[0]);
        Node target = nodeFromID.get(nodeInfo[1]);

        Edge edge = new Edge( source, target, mt, at, sr );
        edges[j] = edge;
        
        /* for averages purpose */
        Edge AVGedge = edgesAVG[j];
        AVGedge.maxTran += mt;
        AVGedge.actTran += at;
        AVGedge.successRate += sr;
      }
      
      // grab the timestamp and failed runs
      JSONArray m = currSim.getJSONArray("meta");
      String ts = " ";
      int runs = 0;
      
      for( int j = 0; j < m.size(); j++ ){
        JSONObject currTime = m.getJSONObject(j);
        
        // grab info for this current simulation run
        ts = currTime.getString("timestamp");
        runs = currTime.getInt("num_failed_runs");
      }
      
      /* for average */
      totalSims += runs;
      
      // create the simulation run object with all of this info
      SimulationRun sr = new SimulationRun( ts, nodes, edges, runs );
      simRuns[i+1] = sr;
    }
    
    // now divide all of the info by total simulation runs for average
    for( Node n: nodesAVG ){
      n.demReq /= sims.size();
      n.demServ /= sims.size();
      n.failRate /= sims.size();
    }
    
    for( Edge e: edgesAVG ){
      e.maxTran /= sims.size();
      e.actTran /= sims.size();
      e.successRate /= sims.size();
    }
    
    SimulationRun sr = new SimulationRun( "All Runs", nodesAVG, edgesAVG, totalSims );
    simRuns[0] = sr;  
  }
}
