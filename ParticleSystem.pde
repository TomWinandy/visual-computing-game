class ParticleSystem {
  public static final int   NUM_ATTEMPTS    = 100;
  public static final float PARTICLE_RADIUS = 10;
  PGraphics graphic;
  
  ArrayList<PVector> centers; 
  PVector origin;
  Cylinder cylinder;
  
  ParticleSystem(PGraphics graphic){
    this.graphic = graphic;
    centers = new ArrayList<PVector>(); 
  }
  
  ParticleSystem(PVector origin,PGraphics graphic ) {
    this.graphic = graphic;
    this.origin = origin.copy();
    centers = new ArrayList<PVector>(); 
    centers.add(origin);
    cylinder = new Cylinder(PARTICLE_RADIUS);
  }
  
  boolean isEmpty(){
    return centers.size()==0;
  }
  
  void addParticle() { 
    PVector center;
    for(int i=0; i<NUM_ATTEMPTS; i++) {
      // Pick a cylinder and its center.
      int index = int(random(centers.size())); 
      center = centers.get(index).copy();
      
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*PARTICLE_RADIUS; 
      center.y += cos(angle) * 2*PARTICLE_RADIUS; 
      if(checkPosition(center)) {
        centers.add(center);
        break;
      }
    } 
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created 
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  // return true iff the positon is valid
  boolean checkPosition(PVector center) {
    PVector l = new PVector(mover.location.x, mover.location.y, 0);
    if(!checkBoundaries(center.x, center.y, PARTICLE_RADIUS) 
                  || checkOverlap(center, l, SPHERE_RAD + PARTICLE_RADIUS)){
      return false;
    }
    for(PVector center2 : centers){
      if(checkOverlap(center, center2, PARTICLE_RADIUS*2)) {
        return false;
      }    
    }
    updateScore(false);
    return true;
  }
  
  void run() {
    for (int i = centers.size()-1; i >= 0; i--) {
      cylinder.drawCylinder(centers.get(i), graphic);
    }
    
    int index_coll = mover.checkCylinderCollision(centers);

    if      (index_coll > 0)  {
      centers.remove(index_coll);
      updateScore(true);
  }
    else if (index_coll == 0) {
      centers.clear();
      initScore();
    }
  }
}
