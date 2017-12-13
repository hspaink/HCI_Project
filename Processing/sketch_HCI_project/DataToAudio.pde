import oscP5.*;
import netP5.*;
import java.util.*;


public class DataToAudio {
  private List<Speaker> speakers = new ArrayList();
  private DataStream dataStream;

  OscP5 oscP5;
  NetAddress puredata;

  // Constructor
  public DataToAudio() {
    for (int i = 0; i < NUM_OUTPUTS*2; ++i) {
      speakers.add(new Speaker());
    }
    dataStream = new DataStream(this);
    init();
  }

  public void init() {
    oscP5 = new OscP5(this, 12000);
    puredata = new NetAddress("127.0.0.1", 9000);
  }

  public void update() {
    for (int i = 0; i < NUM_OUTPUTS; ++i) {
      oscP5.send((new OscMessage("/Speakers/"+i).add(speakers.get(i).getPitch())).add(speakers.get(i).getVolume()), puredata);
      oscP5.send((new OscMessage("/Speakers/"+(i+NUM_OUTPUTS)).add(speakers.get(i+NUM_OUTPUTS).getPitch())).add(speakers.get(i+NUM_OUTPUTS).getVolume()), puredata);
    }
    System.out.println(speakers.get(0).getVolume());
  }

  public void output(float[] pitchLevels, float[][] volumeLevels) {
    for (int i = 0; i < NUM_OUTPUTS; ++i) {
      //System.out.println("Speakerset "+(i+1)+":");
      //System.out.println("  pitch   :"+pitchLevels[i]);
      //System.out.println("  vol up  :"+volumeLevels[i][0]);
      //System.out.println("  vol down:"+volumeLevels[i][1]);
      speakers.get(i).setPitch(pitchLevels[i]);
      speakers.get(i+NUM_OUTPUTS).setPitch(pitchLevels[i]);
      speakers.get(i).setVolume(volumeLevels[i][0]);
      speakers.get(i+NUM_OUTPUTS).setVolume(volumeLevels[i][1]);
    }
    //System.out.println("----------------------------");
  }

  public void togglePaused() {
    dataStream.togglePaused();
  }
  
  public float getSpeakerOnePitch() {
    return speakers.get(0).getPitch();
  }
}