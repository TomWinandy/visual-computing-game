import java.util.Collections;
class HoughTransform{
  
  List<PVector> hough(PImage edgeImg, int nLines) {
    
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f; 

    int minVotes=50;
    

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative 
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
        edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1); 
        
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    
    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }

    // Fill the accumulator: on edge points (ie, white pixels of the edge 
    // image), store all possible (r, phi) pairs describing lines going 
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        float phi =0;
        for (int i =0; i<phiDim; i++) {
          int phiIndex= Math.round(phi/discretizationStepsPhi);
          double r = x*tabCos[phiIndex]+y*tabSin[phiIndex];
          int rIndex = Math.round((float)(r)+(rDim-1)/2);     
          accumulator[(phiIndex)*(rDim)+rIndex] +=1;
          phi+= discretizationStepsPhi;
         }
        } 
      }
    }
    // size of the region we search for a local maximum
    int neighbourhood = 10;
    
    boolean bestCandidate;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        int idx = (accPhi ) * (rDim ) + accR ;
        if (accumulator[idx] > minVotes) {
           bestCandidate=true;
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim)
              continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              if (accR+dR < 0 || accR+dR >= rDim)
                continue;
              int neighbourIdx = (accPhi + dPhi ) * (rDim ) + accR + dR ;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            bestCandidates.add(idx);
          }
        }
      }
    }
    
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    
    
    ArrayList<PVector> lines=new ArrayList<PVector>(); 

    int linesNumber = min(nLines,bestCandidates.size());
    for (int idx = 0 ; idx < linesNumber ; idx++){
        // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (bestCandidates.get(idx) / (rDim));
        int accR = bestCandidates.get(idx) - (accPhi) * (rDim);
        float r = (accR - (rDim) * 0.5f) * discretizationStepsR; 
        float phi = accPhi * discretizationStepsPhi; 
        lines.add(new PVector(r,phi));
    }
 
    return lines;
  }
}
