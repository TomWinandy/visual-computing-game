
public static final int     WIDTH                    = 1200;
public static final int     HEIGHT                   = 750;
public static final PVector PLATE_DIM                = new PVector(320, 10, 320);
public static final float   SPHERE_RAD               = 8;
public static final int     ONE_SECOND               = 1000;
public static final int     FPS                      = 60;
public static final int     REWARD                   = 20;
public static final float   SPEED_COEF               = 100;
public static final float   MAX_ANGLE                = PI/3; 
public static final float   MAX_SPEED                = 5;      // Max value of speed of plate
public static final float   MIN_SPEED                = 0.2;    // Min value of Speed of plate
public static final float   UPDATE_SPEED             = 1.07;   // Magic number to update speed for plate
public static final float   TOP_VIEW_SCALE           = 1.4;    // Magic Number to keep topView elements reasonably scaled
public static final int     INFORMATION_BOX_HEIGHT   = 240;
public static final int     INFORMATION_BOX_WIDTH    = 240;
public static final int     heightOrigin             = INFORMATION_BOX_HEIGHT/2;    //Representing the origin value of the vertical axis in the barChart board   




//---------------------------
private PGraphics gameSurface;
private PGraphics scoreBoard;
private PGraphics topView;
private PGraphics scoreView;
private PGraphics barChart;

private PVector origin;
private float speed = 1f;
private float rx    = 0f;
private float rz    = 0f;
private int space   =0;
private int time;

private boolean drawMode = false;
private boolean gameStarted = false;



private ArrayList<Integer> scoreList;
private Mover mover;
private ParticleSystem ps;
private HScrollbar scrollBar;
private PShape robotnik; 
private int score ;
private int lastScore;

private ImageProcessing imgproc;



//---------------------------

void settings() {
  size(WIDTH, HEIGHT, P3D);
}

void setup() {
  imgproc = new ImageProcessing();
  String[]args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  scoreList = new ArrayList();
  gameSurface = createGraphics(WIDTH,HEIGHT-300,P3D);
  scoreBoard = createGraphics(WIDTH,300);
  topView = createGraphics(INFORMATION_BOX_WIDTH, INFORMATION_BOX_HEIGHT, P2D);
  scoreView = createGraphics(INFORMATION_BOX_WIDTH,INFORMATION_BOX_HEIGHT,P2D);
  barChart = createGraphics(WIDTH-scoreView.width-topView.width-40,INFORMATION_BOX_HEIGHT,P2D);

  score = 0;
  lastScore = 0;
  time = millis();

  frameRate(FPS);
  mover    = new Mover();
  ps       = new ParticleSystem(gameSurface);
  scrollBar= new HScrollbar(scoreView.width + topView.width + 30,HEIGHT-20,150,15);
  robotnik = loadShape("robotnik.obj");
}

void draw() {
    PVector rot= imgproc.getRotation();
    if(rot == null) rot = new PVector(rx,0,rz);
    //ICI BUT: [-60,60] avec operations +-180
    if(rot.x < - PI/3) {
      rot.x += PI;
    }else if(rot.x> PI/3){
      rot.x -= PI;
    }
    if(rot.z < - PI/3) {
      rot.z += PI;
    }else if(rot.z>PI/3){
      rot.z -= PI;
    }
    Boolean condition = imgproc.quad() && rot.z>=-MAX_ANGLE && rot.z<= MAX_ANGLE && rot.x>=-MAX_ANGLE && rot.x<= MAX_ANGLE;
    if(condition){
        rx = rot.x;
        rz = rot.z;
     }
    scrollBar.display();
    scrollBar.update();
    drawGame();
    image(gameSurface, 0, 0);
    drawScore();
    image(scoreBoard,0,HEIGHT-300);
    drawTopView();
    image(topView, 10, HEIGHT - (topView.height +25));
    drawScoreView();
    image(scoreView,topView.width+20,HEIGHT - (scoreView.height + 25));
    drawBarChartView();
    image(barChart,scoreView.width + topView.width + 30,HEIGHT - (scoreView.height + 25));
}

void drawBarChartView(){
  barChart.beginDraw();
    barChart.background(160,160,160);  
    generateRect();

    //update the rectangles amount every 2 seconds
    if(millis() - time >=   ONE_SECOND && gameStarted){
      if(ps.isEmpty()){
        scoreList = new ArrayList();
      } else{
         scoreList.add(score);       
         time = millis();
      }
    }
  
  barChart.endDraw();
}

void drawScoreView(){
  scoreView.beginDraw();
    scoreView.background(130,130,130);
    scoreView.textSize(25);
    scoreView.text("Total Score : " + score,10,50);
    scoreView.text("Velocity : " + nfs(mover.velocity.mag(),int(log(mover.velocity.mag())),3),10,130);
    scoreView.text("Last Score : " + lastScore,10,210);
  scoreView.endDraw();
}

void drawTopView() {
  topView.beginDraw();
    topView.background(96,96,96);
    float xPos = (float)topView.width /2 + (mover.location.x * ((float)topView.width / PLATE_DIM.x));
    float zPos = (float)topView.height /2 + (mover.location.y * ((float)topView.height / PLATE_DIM.z));
    topView.fill(0,128,255);
    topView.ellipse(xPos, zPos, SPHERE_RAD*TOP_VIEW_SCALE, SPHERE_RAD*TOP_VIEW_SCALE);

    float c_xPos;
    float c_zPos;
    for(PVector c : ps.centers) {
      c_xPos = (float)topView.width/2 + (c.x * ((float)topView.width / PLATE_DIM.x));
      c_zPos = (float)topView.height/2 + (c.y * ((float)topView.height / PLATE_DIM.z));
      if(c == origin)
        topView.fill(185,50,60);
      else
        topView.fill(0,76,135);
      topView.ellipse(c_xPos, c_zPos, ParticleSystem.PARTICLE_RADIUS*TOP_VIEW_SCALE, ParticleSystem.PARTICLE_RADIUS*TOP_VIEW_SCALE);
    }
    topView.endDraw();
}

void drawScore(){
  scoreBoard.beginDraw();
    gameSurface.background(220);
  scoreBoard.endDraw();
}

void drawGame(){
  gameSurface.beginDraw();
  
    gameSurface.directionalLight(70, 100, 125, 0, 1, -1);
    gameSurface.ambientLight(102, 102, 102);
    gameSurface.background(200);
    
    //Print some useful informations in the screen
    gameSurface.text("Rotation en X : " + rx               , 10, 30);
    gameSurface.text("Rotation en Z : " + rz               , 10, 60);
    gameSurface.text("Mouse speed   : " + speed*100 + "%"  , 10, 90);
    
    gameSurface.pushMatrix();
      gameSurface.translate(width/2, (height-300)/2, 0);
      
      if (drawMode){
        gameSurface.rotateX(-PI/2);
      }
      else {
        gameSurface.rotateX(rx);
        gameSurface.rotateZ(rz);
        mover.checkEdges();
        mover.update(rx, rz);
        
        if(!ps.isEmpty()){
          gameStarted = true;
          drawRobotnik();
          if(frameCount%FPS == 0 || (frameCount+FPS/2)%FPS == 0){
            ps.addParticle();
          }
        }       
      }
      
      gameSurface.noStroke();
      gameSurface.box(PLATE_DIM.x, PLATE_DIM.y, PLATE_DIM.z);       
      drawSphere();
      
      gameSurface.stroke(0);
      ps.run();
    gameSurface.popMatrix();
    
    
  gameSurface.endDraw();
}


//tool method to update the score each frame (called in draw method)
void updateScore(boolean up){
    if (up){
          score += mover.velocity.mag()+1;
    } else{
      score -= 1;
    }
}

//tool method to initiate the score to 0
void initScore(){
    lastScore = score + REWARD;
    score = 0;
}



//drawing the rectangles score graph method
void generateRect(){ 
  int scoreSign = 0 ; //  signe du score 
  int columnScore = 0; // score à un instant t précis
  float squareDim = 10; 

  if(scrollBar.getPos()> 0.5){
    squareDim += abs(scrollBar.getPos()-0.5)*squareDim;
  }else if (scrollBar.getPos()<0.5){                // when it's equal to 0.5 we leave it as it is
    squareDim -= abs(scrollBar.getPos()-0.5)*squareDim;
  }
  for(int c = 0; c<scoreList.size();c++){
      columnScore = scoreList.get(c);
      if(columnScore != 0)
      scoreSign = columnScore/abs(columnScore);
       int indiceMax=ceil (abs(columnScore)/2.5);
      for(int i = 0; i<indiceMax;i++){      
          float yRec=heightOrigin-scoreSign*i*squareDim;
          barChart.fill(130,1000*(yRec/HEIGHT),30);
          barChart.rect(space,yRec,squareDim,squareDim);
      }
      space+=squareDim;
  }
  space = 5;
}


//drawing Tobotnik method
void drawRobotnik(){
  gameSurface.pushMatrix();
    float robotnikX = ps.centers.get(0).x;
    float robotnikY = ps.centers.get(0).y;
    float robotnikAngle = atan((mover.location.x-robotnikX)/(mover.location.y-robotnikY));
    if (mover.location.y-robotnikY > 0) {robotnikAngle += PI;}
    
    gameSurface.translate(robotnikX, -Cylinder.CYLINDER_HEIGHT, robotnikY);
    gameSurface.rotateY(robotnikAngle);
    gameSurface.scale(-30);
    gameSurface.shape(robotnik);
  gameSurface.popMatrix(); 
}

// drawing sphere method
void drawSphere(){
  gameSurface.pushMatrix(); 
    gameSurface.translate(mover.location.x, -mover.location.z, mover.location.y);
    if (drawMode) {gameSurface.fill(60);}
    gameSurface.sphere(SPHERE_RAD);
    gameSurface.fill(200);
  gameSurface.popMatrix();
}


 
// return whether particle c1 and c2 overlap
boolean checkOverlap(PVector c1, PVector c2, float dist) {
  return c1.dist(c2)<dist;
}

// check whether the circle centered on (x,y) of radius r is in the plate 
// (as we consider the center of the plate to be (0,0))
boolean checkBoundaries(float x, float y, float r){
  return abs(x)< PLATE_DIM.x/2-r && abs(y) < PLATE_DIM.z/2-r;
}
  

void keyPressed() {
  if (keyCode == SHIFT) {drawMode = true;}
}

void keyReleased() {
  if (keyCode == SHIFT) {drawMode = false;}
}

void mouseClicked() {
  float x = mouseX-width/2;
  float y = mouseY-(height-300)/2;
  if (drawMode && checkBoundaries(x, y, ParticleSystem.PARTICLE_RADIUS) ) {
    origin = new PVector(x,y,0);
    ps = new ParticleSystem(origin,gameSurface);
  }
}

//Check if we can change the speed to set highr or lower once the mouseWheel position has changed
void mouseWheel(MouseEvent event){
    float wheel = event.getCount();
    speed =(wheel < 0)? min(speed * UPDATE_SPEED, MAX_SPEED):max(speed / UPDATE_SPEED, MIN_SPEED);
}

    
// mouseY is the current mouse position on the Y axis and pmouseY is the mouse position on 
//the Y axis one frame before the current frame
void mouseDragged() {  
  if(!scrollBar.locked){
      float newRx = rx- (mouseY - pmouseY)*speed/SPEED_COEF;
  if (abs(newRx)<MAX_ANGLE) {rx = newRx;}
  
  float newRz = rz- (pmouseX - mouseX)*speed/SPEED_COEF; 
  if (abs(newRz)<MAX_ANGLE) {rz = newRz;}
  }

}
