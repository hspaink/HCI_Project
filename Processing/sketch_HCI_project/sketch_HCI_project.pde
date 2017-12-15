final static int NUM_OUTPUTS = 3; // Front, Middle, Back
final static int FRAME_RATE = 60;
final static int UPDATE_FREQ = 1000; // Give new value every 1000ms
final static float LEFT_MARGIN = 0;
static String STATE = "End";

DataToAudio dataToAudio; // Main functional class

// Graphical display variables
ArrayList<GraphPoint> points;
float counter;
EnumMap<Toggles, Toggle> toggles = new EnumMap<Toggles, Toggle>(Toggles.class);
float pointSpawnX;
float oldPitch;

void setup() {
  size(800,600);
  frameRate(FRAME_RATE);

  dataToAudio = new DataToAudio();
  points = new ArrayList();
  counter = 0;
  // Create Pause button
  toggles.put(Toggles.START, new Toggle(100, 100, 0, (float)width-200, (float)height/2, "START / STOP"));
  
  pointSpawnX = width/2;
  oldPitch = 0;
}

void draw() {
  if (STATE != "End")
    dataToAudio.output();
  background(-1);

  toggles.get(Toggles.START).display();

  noFill();
  stroke(0);
  beginShape();
  if (STATE != "Paused" && STATE != "End") {
    float pitch = dataToAudio.getSpeakerOnePitch();
    counter = (counter-1 == FRAME_RATE*UPDATE_FREQ/1000) ? 1 : counter+1;
    //System.out.println(pitch);
    //System.out.println(((pitch-oldPitch)*counter/(FRAME_RATE*UPDATE_FREQ/1000)+oldPitch-2000)*10);
    points.add(new GraphPoint(pointSpawnX, ((pitch-oldPitch)*counter/(FRAME_RATE*UPDATE_FREQ/1000)+oldPitch)*0.01-height));
    if (counter == 1)
      oldPitch = pitch;
  } 
  else
    points.add(new GraphPoint(pointSpawnX, height/2));  
  for (int i = 0; i < points.size(); ++i) {
    --points.get(i).x;
    vertex(points.get(i).x, points.get(i).y);
    if (points.get(i).x < LEFT_MARGIN)
      points.remove(i);
  }
  endShape();


  strokeWeight(5);
  rectMode(CORNER);
  rect(pointSpawnX-100, -5, 100, height+5);
  strokeWeight(1);
}


class GraphPoint {
  float x, y;
  GraphPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

void keyPressed() {
  switch(key) {
    case ' ':
      dataToAudio.togglePaused();
      break;
    case 'q':
    case 'Q':
      exit();
      break;
  }
}

void mouseClicked() {
  // TODO: Cleanup please...
  if (dist(mouseX, mouseY, toggles.get(Toggles.START).getxpos(), toggles.get(Toggles.START).getypos()) <= 0.5*Math.sqrt(toggles.get(Toggles.START).getxsize()*toggles.get(Toggles.START).getxsize()+toggles.get(Toggles.START).getysize()*toggles.get(Toggles.START).getysize())) {
    dataToAudio.togglePaused();
  }
}