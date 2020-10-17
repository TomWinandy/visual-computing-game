class Mover {
  public static final float ELASTIC_FACTOR   = 0.8;
  public static final float GRAVITY_CONSTANT = 0.07;
  public static final float MU               = 0.2; 
  
  private final float BOUNDARY_X = PLATE_DIM.x/2 - SPHERE_RAD;
  private final float BOUNDARY_Y = PLATE_DIM.z/2 - SPHERE_RAD;

  PVector location;
  PVector velocity;
  PVector gravityForce;

  float normalForce; 
  float frictionMagnitude; 
  PVector friction; 


  Mover() {
    location =     new PVector(0, 0, SPHERE_RAD + PLATE_DIM.y/2); 
    velocity =     new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
    friction =     new PVector(0, 0, 0);
  }
  

  void update(float rx, float rz) {
    gravityForce.x =  sin(rz) * GRAVITY_CONSTANT; 
    gravityForce.y = -sin(rx) * GRAVITY_CONSTANT;
    
    normalForce = GRAVITY_CONSTANT * cos(rz) * cos(rx);
    frictionMagnitude = normalForce * MU;   
    friction = velocity.copy()
                       .normalize()
                       .mult(-frictionMagnitude); 

    velocity.add(gravityForce)
            .add(friction);
            
    location.add(velocity);
  } 

  void checkEdges() {
    if (abs(location.x) > BOUNDARY_X) {
      velocity.x = -velocity.x * ELASTIC_FACTOR;
      location.x = (location.x > BOUNDARY_X) ? BOUNDARY_X : -BOUNDARY_X;
    } 
    if (abs(location.y) > BOUNDARY_Y) {
      velocity.y = -velocity.y * ELASTIC_FACTOR;
      location.y = (location.y > BOUNDARY_Y) ? BOUNDARY_Y : -BOUNDARY_Y;
    }
  }
  
  // check whether there is a collision and bounce the ball
  // if there is a collision : return the index of the collision (in the array)
  int checkCylinderCollision(ArrayList<PVector> centers){
    PVector l = new PVector(location.x, location.y, 0);
    int i=0;
    for(PVector c : centers){
      if(checkOverlap(c, l, SPHERE_RAD+ParticleSystem.PARTICLE_RADIUS)){
        PVector n = l.sub(c).normalize();
        PVector Vnormal = n.mult(velocity.dot(n)); // = n * |Vy| * cos(angle(n,Vy);
        velocity = velocity.sub(Vnormal.mult(1+ELASTIC_FACTOR));
        return i;
      }
      i++;
    }
    return -1;
  }
}
