int skyRef[] = {#262965, #4B6477, #CA7A3F, #FCD355};
int skyColorMap[];
int skyNum = 25;
int tx = 650;

//----------------------------------------------------------------
void computeSkyColorMap()
{ 
  int nRef = skyRef.length, k = 0;
  skyColorMap = new int[skyNum * (nRef - 1)];
  
  for (int i = 0; i < nRef - 1; ++i)
      for (int j = 0; j < skyNum; ++j)
        skyColorMap[k++] = lerpColor(skyRef[i], skyRef[i+1], (float)j / (skyNum - 1));
}

//----------------------------------------------------------------
class Field
{
  PImage image;
  float depths[];
  PShape readPixels[], writePixels[], readLineDisplay, writeLineDisplay, readPixelDisplay, writePixelDisplay;
  PVector posRF, posWF, dimRF, dimWF;
  int mask[], readLine, writeLine, readPixel, writePixel;
  
  boolean writeField;
  
//----------------------------------------------------------------
  Field(String fName)
  {
    image = loadImage(fName);
    int w = image.width, h = image.height;
    depths = new float[w*h];
    mask = new int[w*h];
    
    if (w != numPixels)
    {
      println("***************ABORTING*********************");
      println("Image width should be : " + numPixels);
      exit();
    }
    
    computeSkyColorMap();
    
    dimRF = new PVector(displayPixelSize * w, displayPixelSize * h);
    posRF = new PVector(0.55 * width, 0.7 * height);
    readLineDisplay = createShape(RECT, 0, 0, displayPixelSize * numPixels, displayPixelSize);
    readPixelDisplay = createShape(RECT, 0, 0, displayPixelSize, displayPixelSize);
    readLineDisplay.setFill(color(255, 0, 0, 75));
    readLineDisplay.setStroke(displayStrokeColor);
    readPixelDisplay.setFill(readTipColor1);
    readPixelDisplay.setStroke(displayStrokeColor);
    readPixel = numPixels - 1;
    readLine = h;
    
    dimWF = new PVector(displayPixelSize * w, displayPixelSize * h);
    posWF = new PVector(0.45 * width - dimWF.x, 0.7 * height);
    writeLineDisplay = createShape(RECT, 0, 0, displayPixelSize * numPixels, displayPixelSize);
    writePixelDisplay = createShape(RECT, 0, 0, displayPixelSize, displayPixelSize);
    writeLineDisplay.setFill(color(255, 0, 0, 75));
    writeLineDisplay.setStroke(displayStrokeColor);
    writePixelDisplay.setFill(writeTipColor1);
    writePixelDisplay.setStroke(displayStrokeColor);
    writePixel = 0;
    writeLine = h - 1;
        
    readPixels = new PShape[w*h];
    writePixels = new PShape[w*h];  
    image.loadPixels();
    float px = 0, py = 0;
    
    for (int i = 0; i < h; ++i, py += displayPixelSize)
    {
      for (int j = 0; j < w; ++j, px += displayPixelSize)
      {
        int id = i * w + j;
        float pixelVal = image.pixels[id] & 0xFF;
        depths[id] = map(pixelVal, 255, 0, 0, pixelMaxDepth);
        int pixelColor;
        
        PShape pR = createShape(RECT, px, py, displayPixelSize, displayPixelSize);
        int skyIndex = floor(map(pixelVal, 0, 255, 0, (skyRef.length - 1) * skyNum - 1));
        skyIndex += round((noise(i,j) - 0.5) * skyColorMap.length * 0.25);
        skyIndex = max(0, skyIndex);
        skyIndex = min((skyRef.length - 1) * skyNum - 1, skyIndex);
        pixelColor = skyColorMap[skyIndex];
        pR.setStrokeWeight(0.25);
        pR.setStroke(pixelColor);
        pR.setFill(pixelColor);
        readPixels[id] = pR;
        
        PShape pW = createShape(RECT, px, py, displayPixelSize, displayPixelSize);
        pixelColor = color(pixelVal);
        pW.setStrokeWeight(0.25);
        pW.setStroke(pixelColor);
        pW.setFill(pixelColor);
        writePixels[id] = pW;
      }
      px = 0; 
    }
  }

//----------------------------------------------------------------
  void showCurrentPixel()
  { 
    mask[readLine * numPixels + readPixel] = 1;
  }   

//----------------------------------------------------------------
  void display(boolean writeMode)
  {
    int w = image.width;
    int h = image.height;
    
    textFont(f1);
     if (writeMode)
     {
        fill(writeTipColor2);
        text("3D PATTERNING - line # " + (h - writeLine) + "\nResist removed by HOT tip ...", tx, height/2);
        tx += 2;
     }
    else
    {
      fill(readTipColor2);
      text("IMAGING - line # " + (h - readLine) + "\nTopography measured by COLD tip ...", tx, height/2);
      tx -= 2;
    }
  
    pushMatrix();
    
    translate(posRF.x, posRF.y);
    
    textFont(f3);
    fill(0,0,0);
    text("Output AFM image", dimRF.x/2, -40);
    
    textFont(f4);
    textLeading(20);
    fill(0,0,0);
    text("line\n10\n9\n8\n7\n6\n5\n4\n3\n2\n1", -20, -5);
    //text("pixel      1   2   3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20", dimRF.x/2 - 20, dimRF.y + 25);
    
    for (int i = 0; i < h * w; ++i)
      if (mask[i] == 1)
        shape(readPixels[i]);
    
    if (!writeMode)
    {
      translate(0, readLine * displayPixelSize);
      shape(readLineDisplay);
      
      translate(readPixel * displayPixelSize, 0);
      shape(readPixelDisplay);
    }
    
    popMatrix();
    
    pushMatrix();
    
    translate(posWF.x, posWF.y);
  
    textFont(f3);
    fill(0,0,0);
    text("Input Layout", dimWF.x/2, -40);
    
    textFont(f4);
    textLeading(20);
    fill(0,0,0);
    text("line\n10\n9\n8\n7\n6\n5\n4\n3\n2\n1", -20, -5);
    //text("pixel      1   2   3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20", dimWF.x/2 - 20, dimWF.y + 25);
    
    for (int i = 0; i < h * w; ++i)
        shape(writePixels[i]);
    
    if (writeMode)
    {
      translate(0, writeLine * displayPixelSize);
      shape(writeLineDisplay);
      
      translate(writePixel * displayPixelSize, 0);
      shape(writePixelDisplay);
    }
    
    popMatrix();
  }
}