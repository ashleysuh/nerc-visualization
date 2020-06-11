/*
  GridVisLayout: 
  - This project visualizes a simulation of the NA power grid system during the year 2050
  - There are N sample runs per period, where a period is a unique hour throughout the year
  - The data file was converted to JSON using the h5statReader.py script
  - For instructions on use, refer to the readme
  
  Last modified by:
  - Ashley Suh on 7/25/18 
*/

import java.util.*;
import controlP5.*;

GraphData data;
ControlP5 cp5;
InfoGraphic chart;
SimulationRun [] simRuns;

PFont f;
int simIter;
PImage img;
ControlFont cf1;
boolean nodeHover, edgeHover, imgHover;
float xMin, xMax, yMin, yMax;

// change these before distribution
String loadMeta = "constrained_metadata.json";
String loadData = "constrained_data.json";

void setup(){
  size(1600, 980);
  smooth(10);
  
  //hint(DISABLE_OPTIMIZED_STROKE);
  
  if( loadMeta != null && loadData != null ){
    data = new GraphData( loadJSONObject(loadMeta), loadJSONObject(loadData) );
  }
  else  println("Failed to load data.");
  
  cp5 = new ControlP5(this);
  f = createFont("Myriad", 12);
  img = loadImage("na_map.png");
  textFont(createFont("Arial",24,true));
    
  setVariables();
  chart = new InfoGraphic( width/2+200, height/2+200, 575, 250);
}

void draw(){
  background(255);
  
  tint(255, 100);
  if( imgHover )  image(img, 100, 0, img.width/2+400, img.height/2+320);

  drawLegend();
  chart.draw();
  
  // draw() takes in u0,v0,w,h -> the new mapped dimensions
  for( Edge e: simRuns[simIter].getAllEdges() ){
    try{
      e.draw( 145, 125, 1090, 935 );
    } catch( NullPointerException np ){ }
  }
  
  for( Node n: simRuns[simIter].getAllNodes() ){
    try{
      n.draw( 145, 125, 1090, 935 );
    } catch ( NullPointerException np ){ }
  }
}

void setVariables(){
  
  nodeHover = false;
  edgeHover = false;
  imgHover = true;
  
  simIter = 0;
  
  // get the min and max for the coordinate system
  xMin = yMin = Float.POSITIVE_INFINITY;
  xMax = yMax = Float.NEGATIVE_INFINITY;
  
  for( Node n: simRuns[1].getAllNodes() ){    
    try{
      xMin = min( xMin, n.getX() );
      yMin = min( yMin, n.getY() );
      xMax = max( xMax, n.getX() );
      yMax = max( yMax, n.getY() );
    } catch ( NullPointerException np ){}
  }
  
  String [] periods = new String[simRuns.length];
  for( int i = 0; i < simRuns.length; i++ ){
    periods[i] = simRuns[i].timestamp;  
  }
  
  textAlign(CENTER, CENTER);
  List cpList = Arrays.asList(periods);
  cf1 = new ControlFont(createFont("Myriad", 18));
  cp5.addScrollableList("dropdown")
     .setPosition(width-275, 10)
     .setSize(250, 125)
     .setBarHeight(40)
     .setItemHeight(35)
     .setColorBackground(color(169,169,169))
     .addItems(cpList)
     .setFont(cf1);
     ; 
}

void drawLegend(){
  fill(0);
  textSize(22);
  textAlign(CENTER, CENTER);
  text(simRuns[simIter].getTimestamp(), width/2-325, 20);
  
  strokeWeight(1.5);
  // show legend for node colors
  fill(189, 215, 231);
  stroke(189, 215, 231);
  ellipse(40, height-188, 18, 18);
  
  fill(107, 174, 214);
  stroke(107, 174, 214);
  ellipse(95, height-188, 18, 18);
  
  fill(33, 113, 181);
  stroke(33, 113, 181);
  ellipse(148, height-188, 18, 18);
  
  // show legend for node size
  fill(189, 215, 231);
  stroke(189, 215, 231);
  ellipse(40, height-130, 10, 10);
  ellipse(95, height-130, 15, 15);
  ellipse(148, height-130, 20, 20);
  
  strokeWeight(2);
  
  // show legend for edge color
  fill(150, 150, 150);
  stroke(150, 150, 150);
  rect(37, height-85, 5, 18);
  
  fill(99, 99, 99);
  stroke(99, 99, 99);
  rect(93, height-85, 5, 18);
  
  fill(37, 37, 37);
  stroke(37, 37, 37);
  rect(147, height-85, 5, 18);
  
  // show legend for edge width
  fill(150, 150, 150);
  stroke(150, 150, 150);
  rect(38, height-35, 3, 18);
  rect(92, height-35, 7, 18);
  rect(146, height-35, 10, 18);
  
  // write text to legend
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Color ~ Failure Rate", 95, height-215);
  text("Size ~ Demand Request", 100, height-163);
  text("Color ~ Capacity Factor", 100, height-105);
  text("Size ~ Max Transfer", 100, height-52);
  
  noFill();
  stroke(0,0,0,100);
  rect(10, height-230, 180, 220);
  /*
  stroke(0);
  strokeWeight(1.5);
  if( imgHover ){
    fill(204,204,204);
  }
  else{
    fill(255);
  }
  rect(10, height-260, 15, 15);
  
  if( mouseX >=10 && mouseX <= 35 && mouseY >= height-260 && mouseY <= height-245){
   if( mousePressed ){
     imgHover = !imgHover;
   }
  }
  
  fill(0);
  textAlign(LEFT,CENTER);
  text("Toggle Map On/Off", 35, height-255);
  */
  noFill();
  
  // legend for node hover info
  rect(width-275, 140, 250, 130);
  fill(0);
  textSize(20);
  textAlign(CENTER,CENTER);
  text("Node Information", width-150, 150);
  
  textAlign(LEFT,CENTER);
  textSize(16);
  text("Demand Requested:", width-270, 180);
  text("Demand Served:", width-270, 205);
  text("LOLP:", width-270, 230);
  text("PCA:", width-270, 255);
  
  // legend for edge hover
  noFill();
  rect(width-275, 285, 250, 105);
  fill(0);
  textAlign(CENTER,CENTER);
  textSize(20);
  text("Edge Information", width-150, 295);
  
  textAlign(LEFT,CENTER);
  textSize(16);
  text("Max Transfer:", width-270, 325);
  text("Actual Transfer:", width-270, 350);
  text("Capacity Factor:", width-270, 375);
}

void dropdown(int n) {
  // request the selected item based on index n
  simIter = n;

  CColor c = new CColor();
  c.setBackground(color(105,105,105));
  cp5.get(ScrollableList.class, "dropdown").getItem(n).put("color", c); 
}