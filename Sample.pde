PShape createTexturedRect(String imgName, PVector pos, PVector dim)
{
  PImage tex = loadImage(imgName);
  PShape s = createShape();
  
  float x = random(0, tex.width - dim.x);
  float y = random(0, tex.height - dim.y);
  
  s.beginShape();
  s.texture(tex);
  s.noStroke();
  s.vertex(pos.x, pos.y, x, y);
  s.vertex(pos.x + dim.x, pos.y, x + dim.x, y);
  s.vertex(pos.x + dim.x, pos.y + dim.y, x + dim.x, y + dim.y);
  s.vertex(pos.x, pos.y + dim.y, x, y + dim.y);
  s.endShape();
  
  return s;
}

//----------------------------------------------------------------
class Sample
{
  PShape sub, ppa;
  PVector subDim, subPos, ppaDim, ppaPos;
  
//----------------------------------------------------------------
  Sample()
  {
    subDim = new PVector(0.7 * canvasWidth, subHeight);
    subPos = new PVector(0.15 * canvasWidth, 0.4 * canvasHeight);
    sub = createTexturedRect("sub.jpg", subPos, subDim);
    
    ppaDim = new PVector(0.7 * canvasWidth, ppaHeight);
    ppaPos = new PVector(0.15 * canvasWidth, subPos.y - ppaHeight);
    ppa = createTexturedRect("ppa.jpg", ppaPos, ppaDim);
  }

//----------------------------------------------------------------  
  void display()
  {
    textFont(f2);
    fill(0,0,0);
    shape(sub);
    textAlign(LEFT);
    text("Substrate", subPos.x + subDim.x + 15, subPos.y + 25);
    
    shape(ppa);
    text("Resist", ppaPos.x + ppaDim.x + 15, ppaPos.y + 25);
    textAlign(CENTER);
  }
}