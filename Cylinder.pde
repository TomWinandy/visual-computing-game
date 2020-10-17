class Cylinder {
  public static final float CYLINDER_HEIGHT = 20;
  public static final int CYLINDER_RESOLUTION = 20; 
  
  PShape openCylinder = new PShape();
  //PVector coordinates;
  
  Cylinder(float cylinderBaseSize) {
    float angle;
    float[] x = new float[CYLINDER_RESOLUTION + 1];
    float[] y = new float[CYLINDER_RESOLUTION + 1];

    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / CYLINDER_RESOLUTION) * i; 
      x[i] = sin(angle) * cylinderBaseSize; 
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
  
    openCylinder.beginShape(TRIANGLES);
    for (int i = 0; i < x.length-1; i++) {
      openCylinder.vertex(x[i], -CYLINDER_HEIGHT, y[i]);
      openCylinder.vertex(x[i+1], -CYLINDER_HEIGHT, y[i+1]);
      openCylinder.vertex(0, -CYLINDER_HEIGHT, 0);
    }
    openCylinder.endShape();
    
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder 
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0, y[i]);
      openCylinder.vertex(x[i], -CYLINDER_HEIGHT, y[i]);
    }
    openCylinder.endShape();
  } 

  public void drawCylinder(PVector coor, PGraphics graphic) {
    
    graphic.pushMatrix();
    graphic.translate(coor.x, 0, coor.y); 
    graphic.shape(openCylinder);
    graphic.popMatrix();
  }
}
