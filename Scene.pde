void arrow(int x1, int y1, int x2, int y2) {
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
}

class Scene
{
  Cantilever c;
  Sample s;
  Field f;
  boolean writeMode;
  int trajId;
  PVector traj[], targetLPPos;
  PShape targetLP, LP[];

//----------------------------------------------------------------  
  Scene()
  {
    c = new Cantilever();
    s = new Sample();
    f = new Field("img4.png");
    
    targetLPPos = new PVector();
    targetLPPos.x = s.ppaPos.x + 0.5 * (s.ppaDim.x - (pixelSize * numPixels));
    targetLPPos.y = s.ppaPos.y;
     
    endRead();
    c.createLever();
  }

//----------------------------------------------------------------
  void computeTargetLP()
  {
    targetLP = createShape();
    targetLP.beginShape();
    targetLP.noFill();
    targetLP.stroke(0);
    
    LP = new PShape[numPixels];
    
    float tx = c.tipDim.x;
    float ty = c.tipDim.y;
  
    for (int i = 0, x = 0; i < numPixels; ++i, x += pixelSize)
    {
      float depth = f.depths[f.writeLine * numPixels + i];
      targetLP.vertex(x, 0);
      targetLP.vertex(x, depth);
      targetLP.vertex(x + pixelSize, depth);
      targetLP.vertex(x + pixelSize, 0);
      
      PShape h = createShape();
      h.beginShape();
      h.fill(bkgColor);
      h.stroke(bkgColor);
    
      h.vertex(x, 0);
      h.vertex(x, depth);
      h.vertex(x + pixelSize, depth);
      h.vertex(x + pixelSize, 0);
      
      /*h.curveVertex(-0.5 * tx + x + 0.5 * pixelSize, -ty + depth);
      h.curveVertex(-0.5 * tx + x + 0.5 * pixelSize, -ty + depth);
      h.curveVertex(-0.25 * tx + x + 0.5 * pixelSize, -0.75 * ty + depth);
      h.curveVertex(-0.125 * tx + x + 0.5 * pixelSize, -0.5 * ty + depth);
      h.curveVertex(0 + x + 0.5 * pixelSize, 0 + depth);
      h.curveVertex(0.125 * tx + x + 0.5 * pixelSize, -0.5 * ty + depth);
      h.curveVertex(0.25 * tx + x + 0.5 * pixelSize, -0.75 * ty + depth);
      h.curveVertex(0.5 * tx + x + 0.5 * pixelSize, -ty + depth);
      h.curveVertex(0.5 * tx + x + 0.5 * pixelSize, -ty + depth);*/
      
      h.endShape();
      
      LP[i] = h;
    }
    targetLP.endShape();
  }
  
//----------------------------------------------------------------
  void computeReadTraj()
  {    
    traj = new PVector[numPixels * 2 * speed];
    float x = s.ppaPos.x + 0.5 * (s.ppaDim.x - (pixelSize * numPixels));
    float y = s.ppaPos.y - readHeight;
    int maxId = f.depths.length - 1;
    
    for (int i = 0; i < numPixels; ++i)
    {
      int id = f.readLine * numPixels + i;
      int prevId = (id - 1 < 0) ? 0 : id - 1;
      int nextId = (id + 1 > maxId) ? maxId : id + 1;
      
      float depthPrev = f.depths[prevId];
      float depth = f.depths[id];
      float depthAfter = f.depths[nextId];
      
      int k = i * speed * 2;
      PVector ref1 = new PVector(x, y + readHeight + depthPrev);
      PVector ref2 = new PVector(x + pixelSize/2, y + readHeight + depth);
      PVector ref3 = new PVector(x + pixelSize, y + readHeight + depthAfter);
      
      for (int j = 0; j < speed; ++j)
        traj[k + j] = PVector.lerp(ref1, ref2, (float)j/(speed - 1));
      
      for (int j = 0; j < speed; ++j)
        traj[k + j + speed] = PVector.lerp(ref2, ref3, (float)j/(speed - 1));

      x += pixelSize;
    }   
  }
  
//----------------------------------------------------------------
  void computeWriteTraj()
  {    
    traj = new PVector[numPixels * 2 * speed];
    float x = s.ppaPos.x + 0.5 * (s.ppaDim.x - (pixelSize * numPixels));
    float y = s.ppaPos.y - writeHeight;
    
    for (int i = 0; i < numPixels; ++i)
    {
      float depth = f.depths[f.writeLine * numPixels + i];
      
      int k = i * speed * 2;
      PVector ref1 = new PVector(x, y);
      
      PVector ref2;
      if (depth > 0)
        ref2 = new PVector(x + pixelSize/2, y + writeHeight + depth);
      else
        ref2 = new PVector(x + pixelSize/2, y);
        
      PVector ref3 = new PVector(x + pixelSize, y);
      
      for (int j = 0; j < speed; ++j)
        traj[k + j] = PVector.lerp(ref1, ref2, (float)j/(speed - 1));
      
      for (int j = 0; j < speed; ++j)
        traj[k + j + speed] = PVector.lerp(ref2, ref3, (float)j/(speed - 1));
      
      x += pixelSize;
    }   
  }
  
 //----------------------------------------------------------------
 void endRead()
 {
    writeMode = true;
    c.tip = c.writeTip;
    
    c.leverPos.y = s.ppaPos.y - c.leverDim.y - c.tipDim.y - writeHeight;
    c.chipPos.y = c.leverPos.y - 0.8 * c.chipDim.y;
    
    computeWriteTraj();
    computeTargetLP();
    f.readPixel = numPixels - 1;
    f.readLine--;
    
    if (f.readLine < 0)
    {
      f.readLine = f.image.height - 1;
      f.mask = new int[f.image.width * f.image.height]; 
    }
    
    trajId = 0;
  }
 
//----------------------------------------------------------------
 void endWrite()
 {
    writeMode = false;
    c.tip = c.readTip;
    
    c.leverPos.y = s.ppaPos.y - c.leverDim.y - c.tipDim.y - readHeight;
    c.chipPos.y = c.leverPos.y - 0.8 * c.chipDim.y;

    computeReadTraj();
    f.writePixel = 0;
    f.writeLine--;
   
    if (f.writeLine < 0)
      f.writeLine = f.image.height - 1; 
      
    trajId = traj.length - 1;
 }
 
//----------------------------------------------------------------
 void updateTipPos()
 {   
   c.setTipPos(traj[trajId]);
   
   if (writeMode)
    {      
      trajId++;
      
      if (trajId % (2 * speed) != 0)
        return;
      
      f.writePixel++;
      if (f.writePixel >= numPixels)
        endWrite(); 
    }
    else
    {      
      trajId--;
      
      if (trajId % (2 * speed) != 0)
        return;
        
      f.showCurrentPixel();
      f.readPixel--;
      if (f.readPixel < 0)
        endRead();
    }
 }
 
//---------------------------------------------------------------- 
  void display()
  {
    background(bkgColor);
    //image(bkg,0,0,width,height);
    
    //fill(245, 243, 222, 50);
    //noStroke();
    //rect(200, 25, 1100, 150, 7);
    
    //fill(245, 243, 222, 50);
    //rect(200, 625, 1100, 320, 7);
    
    //image(slLogo, 0, 0, 0.5 * slLogo.width, 0.5 * slLogo.height);
    image(nfeLogo, 0.5*width - 0.25 * nfeLogo.width, 20, 0.5 * nfeLogo.width, 0.5 * nfeLogo.height);
    fill(0, 0, 0, 255);
    textFont(f3);
    text("Working Principle", 0.5*width, 150);
    
    s.display();
    
    pushMatrix();
    translate(targetLPPos.x, targetLPPos.y);
    //shape(targetLP);
    
    for (int i = 0; i < numPixels; ++i)
    {
      if (!writeMode || (writeMode && i < f.writePixel))
        shape(LP[i]);
    }
    popMatrix();
    
    f.display(writeMode);    
    c.display();
    
    updateTipPos();
    c.createLever();
    
    /*fill(0, 0, 0, 255);
    textFont(f2);
    textAlign(RIGHT);
    text("100x slower", width - 10, height - 10);
    textAlign(CENTER);*/
    
    //saveFrame("frames/line-#######.png");
  }
}
