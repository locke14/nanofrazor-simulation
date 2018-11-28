Scene scene;

//----------------------------------------------------------------
void setup()
{
  size(1920, 1080, P2D);
  smooth(8);
  pixelDensity(displayDensity());
  
  f1 = createFont("JohnstonITCStd-Light", 30);
  f2 = createFont("JohnstonITCStd-Light", 25);
  f3 = createFont("JohnstonITCStd-Light", 32);
  f4 = createFont("Century Schoolbook L Bold", 13);
  textAlign(CENTER);
  
  slLogo = loadImage("sl.png");
  nfeLogo = loadImage("NFELogo.png");
  bkg = loadImage("bkg.jpg");
  scene = new Scene();
}

//----------------------------------------------------------------
void draw()
{
  scene.display();
}