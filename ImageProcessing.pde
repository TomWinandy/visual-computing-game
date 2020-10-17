import processing.video.*;
import gab.opencv.*;

public class ImageProcessing extends PApplet{
      public static final int     WIDTH                    = 1400;
      public static final int     HEIGHT                   = 270;
      public static final float   SCALE_FACTOR             = 0.5;
      //Image that is treated
      PImage img;
      //Test image that is compared with the result of the treated image (img). It' not necessaraly used.
      PImage imgTest;  
      
      //Class that gives access to the static function findConnectedComponents(...)
      BlobDetection blobDetector;
      
      HoughTransform houghTransformer; 
      
      QuadGraph quadGraph;
      
      OpenCV opencv;
      
      TwoDThreeD twoDThreeD;
      Movie cam;
      
      PVector rotations;
      
      boolean foundQuads = false;
      
      void settings() {
        size(WIDTH,HEIGHT);
      }
      
      void setup() {
        blobDetector = new BlobDetection();
        houghTransformer = new HoughTransform();
        quadGraph = new QuadGraph();
        cam = new Movie(this, "C:\\testvideo.avi");
        cam.loop();
        opencv= new OpenCV(this,100,100);  
      } 
      
      void draw() {
      
        if (cam.available() == true) {
          cam.read();
        }
        img = cam.get();

  
        int w = (int) (img.width*SCALE_FACTOR);
        int h = (int) (img.height*SCALE_FACTOR);
        image(img, 0, 0, w, h);//show image (on the left of the screen)
        
        PImage img1 = img.copy();
        img1 = hueMap(img1, 80, 142, 60, 255, 10, 230);//Apply the hue filter
        img1 = blurring(img1);
        img1 = blobDetector.findConnectedComponents(img1, true);
        PImage img2 = img1.copy();
        img1 = scharr(img1);
        img1 = threshold(img1, 150);
        List<PVector> lines = houghTransformer.hough(img1,4);
        drawLines(img1,lines);
        displayQuads(img1,lines);
      
        image(img1, w, 0, w, h);
        
        green(img2);
        image(img2, w*2, 0, w, h);
        
        twoDThreeD = new TwoDThreeD(img1.width,img1.height,0);
        List<PVector> bestQuads = quadGraph.findBestQuad(lines, img1.width, img1.height, 1000000,1000, false);
        foundQuads = bestQuads.size() > 0;
        eucledeanToHom(bestQuads);
        rotations = twoDThreeD.get3DRotations(bestQuads);
        println("rx = " + Math.toDegrees(rotations.x));
        println("ry = " + Math.toDegrees(rotations.y));
        println("rz = " + Math.toDegrees(rotations.z));
       
      }
      
      boolean quad(){
        return foundQuads;
      }
      
      PVector getRotation(){
        return rotations;
      }
      
      void green(PImage img){
        for (int i = 0; i < img.width*img.height; i++){
          if(brightness(img.pixels[i])>100){
            img.pixels[i] = color(0,255,0);
          }
        }
      }
      
      void displayQuads(PImage edgeImg,List<PVector> lines){
        List<PVector> bestQuads = quadGraph.findBestQuad(lines, edgeImg.width, edgeImg.height, 1000000,110, false);
        for(PVector vector : bestQuads){
          fill(255,0,0,128);  //color red semi-transparent
          stroke(128,0,255,128); //color purple semi-transparent
          ellipse(vector.x*SCALE_FACTOR,vector.y*SCALE_FACTOR,25,25);
        }
      }
      
      void eucledeanToHom(List<PVector> bestQuads){
          for(PVector vector : bestQuads){
            vector.z =1;
          }
      }
      
      void drawLines(PImage edgeImg,List<PVector> lines){
        
        for (int idx = 0; idx < lines.size(); idx++) { 
          PVector line=lines.get(idx);
          float r = line.x*SCALE_FACTOR;
          float phi = line.y;
          
          // compute the intersection of this line with the 4 borders of 
          // the image
          int x0 = 0;
          int y0 = (int) (r / sin(phi));
          int x1 = (int) (r / cos(phi));
          int y1 = 0;
          int x2 = (int) (edgeImg.width*SCALE_FACTOR);
          int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); 
          int y3 = (int) (edgeImg.height*SCALE_FACTOR);
          int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
               // Finally, plot the lines
          stroke(204,102,0); 
          if (y0 > 0) {
            if (x1 > 0)
              line(x0, y0, x1, y1);
            else if (y2 > 0)
              line(x0, y0, x2, y2);
            else
              line(x0, y0, x3, y3);
          }
          else {
            if (x1 > 0) {
              if (y2 > 0)
                line(x1, y1, x2, y2); 
              else
                 line(x1, y1, x3, y3);
            }
            else
              line(x2, y2, x3, y3);
          }
        }
      }
      
      
      PImage threshold(PImage img, int threshold) {
        // create a new, initially transparent, 'result' image 
        PImage result = createImage(img.width, img.height, RGB); 
        img.loadPixels();// load pixels
        result.loadPixels();// load pixels
        for (int i = 0; i < img.width * img.height; i++) {
          //if the pixel is bright enough, it becomes white, otherwise it becomes black
          if (brightness(img.pixels[i]) > threshold) {
            result.pixels[i] = color(255, 255, 255);
          } else {
            result.pixels[i] = color(0, 0, 0);
          }
        }
        result.updatePixels();
        return result;
      }
      
      PImage hueMap(PImage input, int hueBelow, int hueAbove, int saturationBelow, int saturationAbove, int brightnessBelow, int brightnessAbove) {
        // create a new, initially transparent, 'result' image 
        PImage result = createImage(input.width, input.height, RGB); 
        input.loadPixels();// load pixels
        result.loadPixels();// load pixels
        
        float hueValue;
        float saturationValue;
        float brightnessValue;
        
        for (int i = 0; i < input.width * input.height; i++) {
          hueValue = hue(input.pixels[i]);
          saturationValue = saturation(input.pixels[i]);
          brightnessValue = brightness(input.pixels[i]);
          //if the pixel is in the appropriate color range, it becomes white, otherwise it becomes black
          if (hueValue >= hueBelow && hueValue <= hueAbove && saturationValue >= saturationBelow && saturationValue <= saturationAbove && brightnessValue >= brightnessBelow && brightnessValue <= brightnessAbove) {
            //result.pixels[i] = img.pixels[i]; 
            result.pixels[i] = color(255, 255, 255);
          } else {
            result.pixels[i] = color(0, 0, 0);
          }
        }
        result.updatePixels();
        return result;
      }
      
      //return true if the 2 images are equals
      boolean imagesEqual(PImage img1, PImage img2) {
        if (img1.width != img2.width || img1.height != img2.height)
          return false; 
        for (int i = 0; i < img1.width*img1.height; i++)
          //assuming that all the three channels have the same value
          if (red(img1.pixels[i]) != red(img2.pixels[i]))
            return false;
        return true;
      }
      
      int applyKernelToPixel(PImage img, int px, int py, float[][] kernel){
        int sum=0;
        
        for (int dx = -1; dx<2; ++dx){
          for (int dy = -1; dy<2; ++dy){
            sum += brightness(img.pixels[(py+dy) * img.width + (px+dx)]) * kernel[1+dy][1+dx];
          }
        }
        return sum;
      }
      
      //Apply kernel on the image (the gaussian blur)
      PImage blurring(PImage img) {
      
        float[][] kernel = {{ 9,  12, 9  }, 
                            { 12, 15, 12 }, 
                            { 9,  12, 9  }};
      
        float normFactor = 99.f; 
      
        // create a greyscale image (type: ALPHA) for output 
        PImage result = createImage(img.width, img.height, ALPHA); 
        img.loadPixels();// load pixels
        result.loadPixels();// load pixels
        for (int x = 1; x < img.width-1; x++) {
          for (int y = 1; y < img.height-1; y++) {
            float intensities = applyKernelToPixel(img, x, y, kernel)/normFactor;
            result.pixels[y * img.width + x] = color(intensities, intensities, intensities);
          }
        }
        result.updatePixels();
        return result;
      }
      
      //Apply to kernel on the image. These kernels renders the value of the graident
      PImage scharr(PImage img) {
        float[][] vKernel = {
          { 3, 0, -3 }, { 10, 0, -10 }, { 3, 0, -3 } };
        float[][] hKernel = {
          { 3, 10, 3 }, { 0, 0, 0 }, { -3, -10, -3 } };
        PImage result = createImage(img.width, img.height, ALPHA); // clear the image
        for (int i = 0; i < img.width * img.height; i++) {
          result.pixels[i] = color(0);
        }
        float max=0;
        float[] buffer = new float[img.width * img.height]; 
      
        //Apply the kernel without normalization
        for (int x = 1; x < img.width-1; x++) {
          for (int y = 1; y < img.height-1; y++) {
            float sum_h = applyKernelToPixel(img, x, y, hKernel);
            float sum_v = applyKernelToPixel(img, x, y, vKernel);
            float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
            
            if (sum > max) {max = sum;}
            buffer[y * img.width + x] = sum;
          }
        }
      
      
        //Apply the normalization
        for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
          for (int x = 1; x < img.width - 1; x++) { // Skip left and right
            int val=(int) ((buffer[y * img.width + x] / max)*255); 
            result.pixels[y * img.width + x]=color(val);
          }
        } 
        return result;
      }
}
