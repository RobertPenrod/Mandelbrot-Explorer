final int infinity = 16;

double zoom = 0.005;
double cameraPositionX = 0;
double cameraPositionY = 0;

int maximumIterations = 200;// 50
int deltaIterations = 10;

// Selection Variables
boolean zoomIn;
boolean makingSelection;
boolean startZoom;
boolean rendering;
boolean initialSelection;
PVector initialSelectionPos;

// Rendering
PImage renderedFractalImage;
int linesRendered;

// Coloring
float paletteLength;
float paletteOffset;

boolean showTut = true;

boolean smoothing = false;

boolean colorRendering = false;

void setView(float x, float y, float z, int it){
  cameraPositionX = x;
  cameraPositionY = y;
  zoom = z;
  maximumIterations = it;
}

void setup() {
  //size(1280, 720); // 800, 800
  fullScreen();
  // 900, 900
  //noLoop();

  paletteLength = 100;
  paletteOffset = 0;

  makingSelection = false;
  startZoom = false; 
  rendering = false;
  initialSelection = false;
  initialSelectionPos = new PVector(0, 0);

  //setView(0.2620750693001772, 0.0021660422384484545, 7.25090903732356*pow(10,-11), 1000);

  renderWholeFractal();
  //blendMode(BLEND);
}

// Cool Positions
//pos: (0.2782970913931039, -0.0102903901819040631
// zoom: 1/961658805447452E-9

//Pos: (0.27829701631388213, -0.010290326850839093)
// zoom: -5.276716617473814E-10

void draw() {
  colorMode(RGB);


  // Display Fractal
  image(renderedFractalImage, 0, 0);

  if (!initialSelection && makingSelection) {
    drawSelectionRectangle();
    //println("drawing rect: " + millis());
  } else if (startZoom) {
    zoomSelection();
    startZoom = false;
    rendering = true;
    makingSelection = false;
    initialSelection = false;
    linesRendered = 0;
    //println("start zoom: " + millis());
  }

  if (rendering) {
    renderWholeFractal(); rendering = false;
    //renderFractalLines();
    //println("lines rendered: " + linesRendered);
  }

  showDebugText();
  if(showTut)
  showInfoText();
}

void zoomSelection() {
  PVector finalSelectionPos = new PVector(mouseX, mouseY);
  PVector selectionSize = PVector.sub(finalSelectionPos, initialSelectionPos);
  PVector selectionCenter = PVector.add(initialSelectionPos, PVector.mult(selectionSize, 0.5));

  // reposition camera
  cameraPositionX += (selectionCenter.x - width/2.0) * zoom;
  cameraPositionY += (selectionCenter.y - height/2.0) * zoom;

  // zoom
  if(zoomIn){
    zoom *= selectionSize.x / (float)width;
  }else{
    zoom *= (float)width / selectionSize.x;
  }
}

void drawSelectionRectangle() {
  noFill();
  stroke(0);
  strokeWeight(5);
  rectMode(CORNERS);

  PVector deltaSelection = PVector.sub(initialSelectionPos, new PVector(mouseX, mouseY));

  PVector rectEnd = new PVector(0, 0);
  boolean xSelection = max(deltaSelection.x, deltaSelection.y) == deltaSelection.x? false : true;

  if (xSelection) {
    rectEnd.x = mouseX;
    rectEnd.y = initialSelectionPos.y - deltaSelection.x * ((float)height/width);
  } else {
    rectEnd.y = mouseY;
    rectEnd.x = initialSelectionPos.x - deltaSelection.y * ((float)width/height);
  }

  rect(initialSelectionPos.x, initialSelectionPos.y, rectEnd.x, rectEnd.y);
}

void renderWholeFractal(){
  drawMandelbrot(maximumIterations, infinity);
  renderedFractalImage = get();
  if(smoothing)
    amatuerSmoothing();
}

void amatuerSmoothing(){
  PImage smoothImage = get();
  
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      int red = 0;
      int blue = 0;
      int green = 0;
      int total = 0;
      
      // upper pixel
      if(y > 0){
        total++;
        color c = renderedFractalImage.get(x,y-1);
        red += red(c);
        blue += blue(c);
        green += green(c);
      }
      // lower pixel
      if(y < height-1){
        total++;
        color c = renderedFractalImage.get(x,y+1);
        red += red(c);
        blue += blue(c);
        green += green(c);
      }
      // left pixel
      if(x > 1){
        total++;
        color c = renderedFractalImage.get(x-1,y);
        red += red(c);
        blue += blue(c);
        green += green(c);
      }
      // right pixel
      if(x < width-1){
        total++;
        color c = renderedFractalImage.get(x+1,y);
        red += red(c);
        blue += blue(c);
        green += green(c);
      }
      
      red /= total;
      while(red > 255){
        red-=255;
      }
      
      blue /= total;
      while(blue > 255){
        blue-=255;
      }
      
      green /= total;
      while(green > 255){
        green-=255;
      }
      //println("(" + x + ", " + y + "): [" + red + ", " + green + ", " + blue + "]");
      
      smoothImage.set(x, y, color(red, green, blue, 255));
    }
  }
  
  renderedFractalImage = smoothImage;
}

void renderFractalLines() {
  drawMandelbrotLine(maximumIterations, infinity, linesRendered);
  linesRendered++;
  if (linesRendered >= height) {
    rendering = false;
  }
}

void showDebugText() {
  int textSize = 24;
  textSize(textSize);
  color textColor = color(255, 250);
  shadowText("Position: " + cameraPositionX + ", " + cameraPositionY, 10, 1*(textSize*1.25), textColor, textSize);
  shadowText("Zoom: " + zoom, 10, 2*(textSize*1.25), textColor, textSize);
  shadowText("Iterations: " + maximumIterations, 10, 3*(textSize*1.25), textColor, textSize);
  //shadowText("V0.4", 10, height - 1*(textSize*1.25), textColor, textSize);
}

void showInfoText(){
  int textSize = 24;
  textSize(textSize);
  color textColor = color(255,250);
  
  String text = "Left click and drag to zoom in";
  shadowText(text, width - textWidth(text)-10, 1*(textSize*1.25), textColor, textSize);
  text = "Right click and drag to zoom out";
  shadowText(text, width - textWidth(text)-10, 2*(textSize*1.25), textColor, textSize);
  text = "Q = decrease iterations";
  shadowText(text, width - textWidth(text)-10, 3*(textSize*1.25), textColor, textSize);
  text = "E = increase iterations";
  shadowText(text, width - textWidth(text)-10, 4*(textSize*1.25), textColor, textSize);
  text = "Increased iterations increases fractal";
  shadowText(text, width - textWidth(text)-10, 6*(textSize*1.25), textColor, textSize);
  text = "detail but requires more time to process";
  shadowText(text, width - textWidth(text)-10, 7*(textSize*1.25), textColor, textSize);
  
  text = "I = initialize to beginning state";
  shadowText(text, width - textWidth(text)-10, 9*(textSize*1.25), textColor, textSize);
  
  text = "R = rerender fractal";
  shadowText(text, width - textWidth(text)-10, 10*(textSize*1.25), textColor, textSize);
  
  text = "L = toggle color";
  shadowText(text, width - textWidth(text)-10, 11*(textSize*1.25), textColor, textSize);
  
  text = "C = capture screenshot";
  shadowText(text, width - textWidth(text)-10, 12*(textSize*1.25), textColor, textSize);
  
  text = "Esc = quit";
  shadowText(text, width - textWidth(text)-10, 13*(textSize*1.25), textColor, textSize);
  
  text = "H to hide";
  shadowText(text, width - textWidth(text)-10, 15*(textSize*1.25), textColor, textSize);
}

void shadowText(String text, float x, float y, color c, int textSize) {
  // Shadow Text
  //textSize(textSize+1);
  fill(0);
  text(text, x+3, y+3);

  // Regular Text
  fill(c);
  textSize(textSize);
  text(text, x, y);
}

// Iterate the mandelbrot function at complex point c
int IterateMandelbrotFunction(Complex c, int maxIterations, int infinity) {
  Complex z = new Complex(c);

  int iterationsUntilInfinity = 0;

  // Iterate
  for (int i = maxIterations; i > 0; i--) {
    iterationsUntilInfinity++;

    // Mandelbrot Formula
    z.Set(z.Multiply(z).Add(c));


    if (z.Magnitude() > infinity) {
      //println("infinity");
      return iterationsUntilInfinity;
      //break;
    }
    //println("0");
  }

  // get integer value between 0 and 255 based on speed of divergence
  /*
  int speed = 0;
   if (z.Magnitude() > infinity)
   speed = (int)map(iterationsUntilInfinity, 1, maxIterations, 255, 0);
   //println("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEe");
   return speed;
   */

  return iterationsUntilInfinity;
}

void drawMandelbrot(int maxIterations, int infinity) {
  // Loop through pixels
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      //PVector mandelPos = new PVector((float)(x-int(width*0.5)) * (float)zoom, (float)(y-int(height*0.5)) * (float)zoom);
      //mandelPos.add(cameraPosition);

      // PVectors are float and thus are booty
      // let's use doubles instead
      double mandelPosX = (x-int(width*0.5)) * zoom;
      mandelPosX += cameraPositionX;
      double mandelPosY = (y-int(height*0.5)) * zoom;
      mandelPosY += cameraPositionY;

      
      int pixelValue = IterateMandelbrotFunction(new Complex(mandelPosX, mandelPosY), maxIterations, infinity);
      color c = color(0,0,0);
      
      // color
      if(colorRendering){
      int hue = int((255 * pixelValue) / maxIterations);
      int value = pixelValue==maxIterations? 0 : 255;
      // Draw pixel color
      colorMode(HSB, 255);
      c = color(hue, 255, value);
      } else {
        // grey-scale
        //int value = int((255 * pixelValue) / maxIterations);
        int value = int((255 * pixelValue) / maxIterations);
        int alpha = 255;//int((255 * pixelValue) / maxIterations);
        c = color(value, value, value, alpha);
      }

      set(x, y, c);
      //println("DRAWWWWWWWWWN");
    }
  }
}

void drawMandelbrotLine(int maxIterations, int infinity, int line) {
  // Loop through pixels
  for (int x = 0; x < width; x++) {
    //PVector mandelPos = new PVector((float)(x-int(width*0.5)) * (float)zoom, (float)(y-int(height*0.5)) * (float)zoom);
    //mandelPos.add(cameraPosition);

    // PVectors are float and thus are booty
    // let's use doubles instead
    double mandelPosX = (x-int(width*0.5)) * zoom;
    mandelPosX += cameraPositionX;
    double mandelPosY = (line-int(height*0.5)) * zoom;
    mandelPosY += cameraPositionY;

    int pixelValue = IterateMandelbrotFunction(new Complex(mandelPosX, mandelPosY), maxIterations, infinity);
    int hue = int((255 * pixelValue) / maxIterations);
    int value = pixelValue==maxIterations? 0 : 255;

    // Draw pixel color
    colorMode(HSB, 255);
    color c = color(hue, 255, value);

    set(x, line, c);
    //println("DRAWWWWWWWWWN");
  }
}

void mouseDragged() {
  // Old Controlls
  /*
  if (mouseButton == LEFT) {
   //PVector deltaMouse = new PVector(mouseX - pmouseX, mouseY - pmouseY);
   double deltaMouseX = mouseX - pmouseX;
   double deltaMouseY = mouseY - pmouseY;
   //deltaMouse.mult((float)zoom);
   deltaMouseX *= zoom;
   deltaMouseY *= zoom;
   cameraPositionX -= deltaMouseX;
   cameraPositionY -= deltaMouseY;
   }
   */

  if (mouseButton == LEFT || mouseButton == RIGHT) {
    if(mouseButton == LEFT){
      zoomIn = true;
    }else if(mouseButton == RIGHT){
      zoomIn = false;
    }
    // Start drawing rectangle
    if (!initialSelection && !makingSelection) {
      makingSelection = true;
      initialSelection = true;
      initialSelectionPos.set(mouseX, mouseY);
    } else {
      initialSelection =false;
    }
  }
}

void mouseReleased() {
  if (mouseButton == LEFT || mouseButton == RIGHT) {
    makingSelection = false;
    startZoom = true;
  }
}

void keyPressed() {
  if(key == 'h'){
    showTut = showTut? false : true;
  }
  
  if(key == 'c'){
    // Capture Screen
    String directory = "screenshots/";
    String imageName = "(" + cameraPositionX + ", " + cameraPositionY + ")[" + zoom + "]";
    renderedFractalImage.save(directory + imageName + ".png");
    println("Image " + imageName + " saved!");
  }
  
  if(key == 's'){
    smoothing = smoothing? false : true;
    renderWholeFractal();
  }
  
  if(key == 'l'){
    colorRendering = colorRendering? false : true;
    renderWholeFractal();
  }
  
  if(key == 'r'){
    // Reload
    renderWholeFractal();
  }
  
  if(key == 'i'){
    zoom = 0.005;
    cameraPositionX = 0;
    cameraPositionY = 0;
    maximumIterations = 200;
    renderWholeFractal();
  }
  
  /*
  if (key == 'w') {
    zoom(1);
  } else if (key == 's') {
    zoom(-1);
  }
  */
  if (key == 'q') {
    maximumIterations -= maximumIterations-deltaIterations>=10? deltaIterations : 0;
  } else if (key == 'e') {
    maximumIterations += deltaIterations;
  }
}

double pointToLine(Complex point, Complex line) {
  double distance = 0;
  // check if slope is 0
  if (line.real == 0) {
    // distance squared
    distance = (line.imaginary - point.imaginary) * (line.imaginary - point.imaginary);
  } else {
    double intersectX = (point.imaginary - (1.0/line.real) * point.real - line.imaginary) / (line.real - (1.0/line.real));
    double intersectY = line.real * intersectX + line.imaginary;

    double deltaX = intersectX - point.real;
    double deltaY = intersectY - point.imaginary;

    distance = (deltaX * deltaX) + (deltaY * deltaY);
  }

  return distance;
}