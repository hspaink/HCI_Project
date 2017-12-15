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

  public void output() {
    for (int i = 0; i < NUM_OUTPUTS; ++i) {
      oscP5.send((new OscMessage("/Speakers/"+i).add(speakers.get(i).getPitch())).add(min(speakers.get(i).getVolume(), 0.5)), puredata);
      oscP5.send((new OscMessage("/Speakers/"+(i+NUM_OUTPUTS)).add(speakers.get(i+NUM_OUTPUTS).getPitch())).add(min(speakers.get(i+NUM_OUTPUTS).getVolume(), 0.5)), puredata);
    }
  }

  public void update(int speakerIndex, float pitchLevel, float[] volumeLevels) {    
    System.out.println(speakerIndex);
    for (Speaker speaker : speakers) {
      speaker.setVolume(0);
      speaker.setPitch(0);
    }
    speakers.get(speakerIndex).setPitch(pitchLevel);
    speakers.get(speakerIndex).setVolume(volumeLevels[0]);
    speakers.get(speakerIndex+NUM_OUTPUTS).setPitch(pitchLevel);
    speakers.get(speakerIndex+NUM_OUTPUTS).setVolume(volumeLevels[1]);
    
    
    
    System.out.println("----------------------");
    for (int i = 0; i < NUM_OUTPUTS; ++i) {
      System.out.println("Speaker " + i);
      System.out.println("Pitch: " + (speakers.get(i).getPitch() - 100));
      System.out.println("Volume: " + speakers.get(i).getVolume());
    }
  }

  public void silence() {
    System.out.println("Silence");
    for (int i = 0; i < NUM_OUTPUTS; ++i) {
      oscP5.send((new OscMessage("/Speakers/"+i).add(0)).add(0), puredata);
      oscP5.send((new OscMessage("/Speakers/"+(i+NUM_OUTPUTS)).add(0)).add(0), puredata);
    }    
  }

  public void togglePaused() {
    dataStream.togglePaused();
  }

  public float getSpeakerOnePitch() {
    return speakers.get(0).getPitch();
  }
}