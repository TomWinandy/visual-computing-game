import java.util.ArrayList; 
import java.util.List; 
import java.util.TreeSet; 

class BlobDetection {

  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    //TODO Comment gérer les pixels aux extremites?
    //A voir 

    // create a new, initially transparent, 'result' image 
  PImage result = createImage(input.width, input.height, RGB); 
  input.loadPixels();// load pixels
  result.loadPixels();// load pixels

    // First pass: label the pixels and store labels' equivalences 
    int [] labels = new int [input.width*input.height]; 

    ArrayList<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();

    int currentLabel = 1; 

    for (int x = 1; x < input.width-1; x++) {
      for (int y = 1; y < input.height-1; y++) {
        if (input.pixels[y * input.width + x] == color(255, 255, 255)) {

          TreeSet<Integer> neighbourLabels = new TreeSet<Integer>();//Tree containing the labels of every neighbor
          if (labels[(y-1) * input.width + (x-1)] != 0) {
            neighbourLabels.add(labels[(y-1) * input.width + (x-1)]);
          }
          if (labels[(y-1) * input.width + (x)] != 0) {
            neighbourLabels.add(labels[(y-1) * input.width + x]);
          }
          if (labels[(y-1) * input.width + (x+1)] != 0) {
            neighbourLabels.add(labels[(y-1) * input.width + (x+1)]);
          }
          if (labels[(y) * input.width + (x-1)] != 0) {
            neighbourLabels.add(labels[y * input.width + (x-1)]);
          }

          //Merge neighbourLabels with labelsEquivalences 
          boolean added = false;
          for (int i = 0; i < labelsEquivalences.size(); i++) {
            if (!neighbourLabels.isEmpty() && labelsEquivalences.get(i).contains(neighbourLabels.first())) {
              labelsEquivalences.get(i).addAll(neighbourLabels);
              added = true;
            }
          }
          if (!neighbourLabels.isEmpty() && !added) {
            labelsEquivalences.add(neighbourLabels);
          }

          //Assign the correct label to the pixel
          if (!neighbourLabels.isEmpty()) {
            labels[y * input.width + x] = neighbourLabels.first();
          } else {
            labels[y * input.width + x] = currentLabel;
            ++currentLabel;
          }
        }
      }
    }

      ArrayList<Integer> labelsQuantity = new ArrayList<Integer>(currentLabel);
    //Initialize labelsQuantity
    for (int i = 0; i <= currentLabel; i++) {
      labelsQuantity.add(i, 0);
    }

    // Second pass: re-label the pixels by their equivalent class 
    // if onlyBiggest==true, count the number of pixels for each label 
    for (int x = 1; x < input.width-1; x++) {
      for (int y = 1; y < input.height-1; y++) {
        if (input.pixels[y * input.width + x] == color(255, 255, 255)) {
          for (int i = 0; i < labelsEquivalences.size(); i++) {
            if (labelsEquivalences.get(i).contains(labels[y * input.width + x])) {
              labels[y * input.width + x] = labelsEquivalences.get(i).first();
            }
          }
          if (onlyBiggest) {
            labelsQuantity.set(labels[y * input.width + x], labelsQuantity.get(labels[y * input.width + x]) + 1);
          }
        }
      }
    }

    //Determine the biggest labels if (onlybiggest==true) max or iterate 

    int biggestLabel = 0;
    int numberBiggestLabel = 0;
    //if (onlyBiggest) {
      for (int i = 0; i < currentLabel; i++) {
        if (labelsQuantity.get(i) > numberBiggestLabel) {
          biggestLabel = i;
          numberBiggestLabel = labelsQuantity.get(i);
        }
      }
    //}

    // Finally: 
    // if onlyBiggest==false, output an image with each blob colored in one uniform color 
    // if onlyBiggest==true, output an image with the biggest blob in white and others in black 
    for (int x = 0; x < input.width; x++) {
      for (int y = 0; y < input.height; y++) {
        if (onlyBiggest) {
          if (labels[y * input.width + x] == biggestLabel) {
            result.pixels[y * input.width + x] = color(255, 255, 255);
          } else {
            result.pixels[y * input.width + x] = color(0, 0, 0);
          }
        } else {
          result.pixels[y * input.width + x] = color(0, 0, 0);
          for (int i = 1; i < currentLabel; i++) {
            if (labels[y * input.width + x] == i) {
              //TODO How change color?
              //Generer random color 
              result.pixels[y * input.width + x] = color(i*30, i*30, i*30);
            }
          }
        }
      }
    }

    result.updatePixels();
    //println(labelsQuantity.toString());
    
  return result;
  }
}
