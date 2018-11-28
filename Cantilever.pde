//----------------------------------------------------------------
ArrayList<PVector> getTipPoints(PVector dim, PVector pos)
{  
  float x = dim.x;
  float y = dim.y;
  
  ArrayList<PVector> tipPoints = new ArrayList<PVector>();
 
  tipPoints.add(PVector.add(new PVector(-0.5 * x, -y), pos));
  tipPoints.add(PVector.add(new PVector(-0.5 * x, -y), pos));
  tipPoints.add(PVector.add(new PVector(-0.25 * x, -0.75 * y), pos));
  tipPoints.add(PVector.add(new PVector(-0.125 * x, -0.5 * y), pos));
  tipPoints.add(PVector.add(new PVector(0, 0), pos));
  tipPoints.add(PVector.add(new PVector(0.125 * x, -0.5 * y), pos));
  tipPoints.add(PVector.add(new PVector(0.25 * x, -0.75 * y), pos));
  tipPoints.add(PVector.add(new PVector(0.5 * x, -y), pos));
  tipPoints.add(PVector.add(new PVector(0.5 * x, -y), pos));
  
  return tipPoints;
}

//----------------------------------------------------------------
void removeLeftPoints(ArrayList<PVector> tipPoints)
{
  tipPoints.subList(0, 4).clear();
}

//----------------------------------------------------------------
void removeRightPoints(ArrayList<PVector> tipPoints)
{
  tipPoints.subList(5, 9).clear();
}

//----------------------------------------------------------------
class Cantilever
{
  PShape chip, lever, tip, readTip, writeTip;
  PVector chipPos, chipDim, leverPos, leverDim, tipPos, tipDim;
  float angle;

//----------------------------------------------------------------  
  PShape createTip(int c1, int c2)
  {
    ArrayList<PVector> tipPoints = getTipPoints(tipDim, new PVector(0,0));
    
    PVector points[] = new PVector[tipNumPts];
    int n = tipNumPts / 6;
    
    for (int j = 0; j < 6; ++j)
      for (int i = 0; i < n; ++i)
      {
        points[i+j*n] = new PVector();
        points[i+j*n].x = curvePoint(tipPoints.get(j).x, tipPoints.get(j+1).x, tipPoints.get(j+2).x, tipPoints.get(j+3).x, (float)i/(n-1));
        points[i+j*n].y = curvePoint(tipPoints.get(j).y, tipPoints.get(j+1).y, tipPoints.get(j+2).y, tipPoints.get(j+3).y, (float)i/(n-1));
      }
      
    PShape tip = createShape(GROUP);
    
    int startId = 0, endId = tipNumPts;
    float f = 1.0/(tipNumColors - 1);
     
    for (int i = 0; i < tipNumColors; ++i)
    {
      PShape t = createShape();
      t.beginShape();
      t.fill(lerpColor(c1, c2, i*f));
      t.noStroke();
      for (int j = startId; j < endId; ++j)
        t.curveVertex(points[j].x, points[j].y);
      t.endShape();
      
      tip.addChild(t);
      
      startId += round(0.5 * tipNumPts * f);
      endId = 2 * round(0.5 * tipNumPts) - startId;
    }
    
    return tip;
  }
  
//----------------------------------------------------------------  
  void createLever()
  {
    float lx = 2, ly = 0, lw = leverDim.x, lh = leverDim.y;
    float tx = tipPos.x - leverPos.x, ty = tipPos.y - leverPos.y, tw = tipDim.x, th = tipDim.y;
    
    ArrayList<PVector> pts = new ArrayList<PVector>();
    pts.add(new PVector(lx, ly));
    pts.add(new PVector(lx, ly));
    pts.add(new PVector(lx + 1.5 * tw, ly));
    pts.add(new PVector(tx - 0.75 * tw, ty - th - lh));
    pts.add(new PVector(tx + 0.5 * tw, ty - th - lh));
    pts.add(new PVector(tx + 0.5 * tw, ty - th));
    pts.add(new PVector(tx - 0.75 * tw, ty - th));
    pts.add(new PVector(lx + 1.5 * tw, ly + lh));
    pts.add(new PVector(lx, ly + lh));
    pts.add(new PVector(lx, ly + lh));
    
    lever = createShape();
    lever.beginShape();
    lever.fill(leverColor);
    lever.stroke(leverColor);
    
    for (PVector p : pts)
    {
      lever.curveVertex(p.x, p.y);
    }
      
    lever.endShape();
  }

//----------------------------------------------------------------  
  void createChip()
  {
    chip = createShape();
    
    chip.beginShape();
    chip.fill(chipColor);
    chip.strokeWeight(2);
    chip.stroke(chipColor);
    chip.vertex(chipPos.x, chipPos.y);
    chip.vertex(chipPos.x + chipDim.x, chipPos.y);
    chip.vertex(chipPos.x + chipDim.x, chipPos.y + chipDim.y);
    chip.vertex(chipPos.x, chipPos.y + chipDim.y);
    chip.vertex(chipPos.x, chipPos.y);
    chip.endShape();
  }
  
//----------------------------------------------------------------
  Cantilever() 
  {
    tipDim = new PVector(tipWidth, tipHeight);
    leverDim = new PVector(leverWidth, leverHeight);
    chipDim = new PVector(chipWidth, chipHeight);
    
    tipPos = new PVector(0,0);
    leverPos = new PVector(0, 0);
    chipPos = new PVector(0, 0);
    
    createLever();
    createChip();

    readTip = createTip(readTipColor1, readTipColor2);
    writeTip = createTip(writeTipColor1, writeTipColor2);
    tip = writeTip;
  }

//----------------------------------------------------------------
  void setTipPos(PVector pos)
  {
    tipPos.x = pos.x;
    tipPos.y = pos.y;
    
    leverPos.x = tipPos.x - leverDim.x + 0.5 * tipDim.x;
    chipPos.x = leverPos.x - chipDim.x;
  }
  
//----------------------------------------------------------------
  void display()
  {        
    pushMatrix();
    translate(chipPos.x, chipPos.y);
    shape(chip);
    popMatrix();
    
    pushMatrix();
    translate(leverPos.x, leverPos.y);
    shape(lever);
    popMatrix();
    
    pushMatrix();
    translate(tipPos.x, tipPos.y);
    shape(tip);
    popMatrix();
  }
}