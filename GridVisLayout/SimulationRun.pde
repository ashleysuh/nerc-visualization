
// hold all of the simulation runs 
public class SimulationRun {
  
  // find the "average" lolp for each simulation run
  // example: 50 failures out of 10,000 cases
  // eoe: average distance between the demand served vs demand requested
  // sum( all demand requested - all demand served ) / total simulations per timeperiod
  // 2d grid: hour of day and day of the year, 24x365 -- each cell is colored according by the LOLP
  // to see trends using a heat map ( selecting a cell will change the timestamp )
  
  /* Gord will show the system at a conference on friday */
  
  String timestamp;
  Node [] nodes;
  Edge [] edges;
  int numRuns;
  boolean failed;
  
  float minSR, maxSR, minFR, maxFR;
  float minDR, maxDR, minMT, maxMT;
  
  public SimulationRun( String timestamp, Node [] nodes, Edge [] edges, int numRuns ){
    this.timestamp = timestamp;
    this.nodes = nodes;
    this.edges = edges;
    this.numRuns = numRuns;
    
    minFR = minMT = minSR = minFR = Float.POSITIVE_INFINITY;
    maxFR = maxMT = maxSR = maxFR = Float.NEGATIVE_INFINITY;
    
    for( Node n: nodes ){
      minFR = min(minFR, n.getFR());
      maxFR = max(maxFR, n.getFR());
      minDR = min(minDR, n.getDR());
      maxDR = max(maxDR, n.getDR());
      
      if( n.failed ){
        failed = true;  
      }
    }
    
    for( Edge e: edges ){
      minMT = min(minMT, e.getMT());
      maxMT = max(maxMT, e.getMT());
      minSR = min(minSR, e.getSR());
      maxSR = max(maxSR, e.getSR());
    }
  }
  
  public Node [] getAllNodes() { return nodes; } 
  public Edge [] getAllEdges() { return edges; }
  public Node getNode( int i ) { return nodes[i]; }
  public Edge getEdge( int i ) { return edges[i]; }  
  public String getTimestamp() { return timestamp; }
}

// hold all of the nodes
public class Node { 
  String id;
  float demReq, demServ, failRate;
  float [] coords;
  boolean failed;
  
  public Node( String id, float demReq, float demServ, float failRate, float [] coords ){
    this.id = id;
    this.demReq = demReq;
    this.demServ = demServ;
    this.failRate = failRate;
    this.coords = coords;
    
    if( demReq != demServ )  failed = true;
  }
  
  public void draw( int u0, int v0, int w, int h ){
    float x = map( coords[0], xMin, xMax, u0, w );
    float y = map( coords[1], yMin, yMax, h, v0 );
  
    // map values 1-3 for color map
    float r = map( failRate, simRuns[simIter].minFR, simRuns[simIter].maxFR, 158, 8 );
    float g = map( failRate, simRuns[simIter].minFR, simRuns[simIter].maxFR, 202, 81 );
    float b = map( failRate, simRuns[simIter].minFR, simRuns[simIter].maxFR, 225, 156 );    
    
    // map size of node by demand requested: if DR is high, node is larger
    float size = map( getDR(), simRuns[simIter].minDR, simRuns[simIter].maxDR, 9, 16 );
    
    stroke(0, 0, 0, 100);
    fill(r, g, b);
    strokeWeight(1.5);
    ellipse( x, y, size, size );
    
    fill(255,0,0);
    nodeHover = mouseX >= x-size/2 && mouseX <= x+size/2 && mouseY >= y-size/2 && mouseY <= y+size/2;
    
    if( nodeHover ){
      fill(0);
      textSize(16);
      textAlign(LEFT, CENTER);
      text(demReq, width-120, 180);
      text(demServ, width-120, 205);
      text(String.format("%.3f", failRate * 100) + "%", width-200, 230);
      text(id, width-200, 255);
    }
  }
  
  public String getID() { return id; }
  public float getX()   { return coords[0]; }
  public float getY()   { return coords[1]; }
  public float getFR()  { return failRate; }
  public float getDR()  { return demReq; }
}

// hold all of the edges
public class Edge {
  Node source, target;
  float maxTran, actTran, successRate;
 
  public Edge( Node source, Node target, float maxTran, float actTran, float successRate ){
    this.source = source;
    this.target = target;
    this.maxTran = maxTran;
    this.actTran = actTran;
    this.successRate = successRate;
   }
 
  public void draw( int u0, int v0, int w, int h ){
    float x1 = map( source.getX(), xMin, xMax, u0, w );
    float y1 = map( source.getY(), yMin, yMax, h, v0 );
    
    float x2 = map( target.getX(), xMin, xMax, u0, w );
    float y2 = map( target.getY(), yMin, yMax, h, v0 );
    
    float xmin, xmax, ymin, ymax;
    if( min(x1,x2) == x1 ){
      xmin = x1; xmax = x2;
      ymin = y1; ymax = y2;
    }
    else{
      xmin = x2; xmax = x1;
      ymin = y2; ymax = y1;
    }
    float currMouse = map(mouseX, xmin, xmax, ymin, ymax );
    edgeHover =  mouseX >= xmin-0.5 && mouseX <= xmax+0.5 && mouseY >= currMouse-3 && mouseY <= currMouse+3;
    
    if( edgeHover ){
      fill(0);
      textAlign(LEFT, CENTER);
      textSize(14);

      text(maxTran, width-140, 325);
      text(actTran, width-140, 350);
      text(String.format("%.3f",successRate * 100) + "%", width-140, 375);
    }
    
    // map values 1-3 for color map
    float r = map( successRate, simRuns[simIter].minSR, simRuns[simIter].maxSR, 150, 0 );
    float g = map( successRate, simRuns[simIter].minSR, simRuns[simIter].maxSR, 150, 0 );
    float b = map( successRate, simRuns[simIter].minSR, simRuns[simIter].maxSR, 150, 0 );
    
    // map the line weight based on max transfer magnitude
    float weight = map( maxTran, simRuns[simIter].minMT, simRuns[simIter].maxMT, 2, 9 );
    // map the opacity based on capacity factor
    float sweight = map( successRate, simRuns[simIter].minSR, simRuns[simIter].maxSR, 140, 200 );
    
    stroke(r, g, b, sweight);
    strokeWeight(weight);
    line( x1, y1, x2, y2 );
 }
 
  public float getMT()    { return maxTran; }
  public float getSR()    { return successRate; }
  public Node getSource() { return source; }
  public Node getTarget() { return target; }
}