public class InfoGraphic{
  
  int u0, v0, w, h;
  
  public InfoGraphic(int u0, int v0, int w, int h){  
    this.u0 = u0;
    this.v0 = v0;
    this.w = w;
    this.h = h;
  }
  
  void draw(){
    noFill();
    strokeWeight(1.5);
    stroke(0,0,0,125);
    
    if( mouseX >= u0 && mouseX <= u0+w && mouseY >= v0 && mouseY <= v0+h ){
        
    }
    
    rect( u0, v0, w, h );
    stroke(0);
    
    fill(0);
    textSize(14);
    textAlign(LEFT,CENTER);
    text("Failed", u0-50, v0+100);
    //text("Success", u0-50, v0+250);
    
    textAlign(CENTER,CENTER);
    textSize(20);
    text("LOLP change over time", u0+w/2, v0-25);
    text("Timestamps", u0+w/2, v0+h+15);
    
    int numPoints = simRuns.length;
    for( int i = 1; i < numPoints; i++ ){
      
      if( i < numPoints-1 ){
        float x1 = map(i, 1, simRuns.length, u0, u0+w);
        float x2 = map(i+1, 1, simRuns.length, u0, u0+w);
        
        float y1 = map(simRuns[i].failureRate, minSR, maxSR, v0+h, v0);
        float y2 = 0;
        
        if( simRuns[i].failed ){
          y1 = v0+100;
        }
        else{
          y1 = v0+250;
        }
        if( simRuns[i+1].failed ){
          y2 = v0+100;
        }
        else{
          y2 = v0+250;
        }
        
        line(x1, y1, x2, y2);
        
      }
    }
  }
}