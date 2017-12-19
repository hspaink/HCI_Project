import java.util.*;
import java.lang.reflect.Method;

public class DataStream {
  // To get block of data every second
  private myTimerTask getDataTimerTask = new myTimerTask(this, "getData", 1);
  private myTimerTask outputStreamTimerTask = new myTimerTask(this, "changeOutput", UPDATE_FREQ);

  private int speakerIndex = 0;

  private boolean paused = true;

  private DataToAudio dataToAudio = null;
  private myFileReader fileReader = new myFileReader();;

  // Data storage + values
  private Queue<JSONObject> dataBuffer = new ArrayDeque<JSONObject>(); // Queue datastructure because of fifo properties
  private float streamHighest = 0;
  private float streamLowest = Float.MAX_VALUE;
  private float graphHeight = 0.5;

  private float currentPrice = 0;

  // Speakers: {front, middle, back} [{top, bottom}]
  private float pitchLevel = 0;
  private float[] volumeLevels = {0, 0};


  public DataStream(DataToAudio dataToAudio) {
    this.dataToAudio = dataToAudio;
    initStream();
  }

  private void initStream() {
    // TODO: setup real data stream

    System.out.println("Starting stream...");
    getDataTimerTask.start();
    outputStreamTimerTask.start();
  }

  public void togglePaused() {
    paused = !paused;
    STATE = !paused?"Streaming":"Paused";

    dataToAudio.silence();
  }

  public void changeOutput() {
    if (!paused) {
      dataToAudio.update(speakerIndex, pitchLevel, volumeLevels);
      speakerIndex = (speakerIndex + 1) % NUM_OUTPUTS;
      if (speakerIndex == 0)
        outputStream();
    }
  }

  public void outputStream() {
    // send parsed data as updated pitch and volume levels to speakers 1 trough 6
    if (!paused) {
      // Get first object from buffer
      JSONObject object;
      if ((object = dataBuffer.poll()) == null) {
        outputStreamTimerTask.endTimerTask();
        STATE = "End";
        dataToAudio.silence();
        return;
      }
      // Update pitch
      float newPrice = (Float.parseFloat(object.getString("1. open"))+Float.parseFloat(object.getString("4. close")))/2; // Difference in price open : close
      float newPitch = newPrice-currentPrice;
      currentPrice = newPrice;
      // Update volume
      float tradeVolume = Float.parseFloat(object.getString("5. volume"));
      float newHeight = (Float.parseFloat(object.getString("2. high"))+Float.parseFloat(object.getString("3. low")))/2; // Difference in price high : low
      streamHighest = max(streamHighest, newHeight);
      streamLowest = min(streamLowest, newHeight);
      // Set levels
      pitchLevel = newPitch;
      if (streamHighest-streamLowest != 0) {
        graphHeight = (newHeight-streamLowest)/(streamHighest-streamLowest);
        //System.out.println(graphHeight + " " + tradeVolume);
        volumeLevels[0] = tradeVolume * graphHeight;
        volumeLevels[1] = tradeVolume * (1.0 - graphHeight);
      } else 
        volumeLevels[0] = volumeLevels[1] = 2000;
    }
  }

  //Temporary solution:
  public void getData() {
    if (!fileReader.done()) {
      dataBuffer.add(fileReader.getBlock());
      System.out.println("Block received!");
    } else {
      System.out.println("End of stream...");
      getDataTimerTask.endTimerTask();
    }
  }
  
  public float getGraphHeight() {
    return graphHeight;
  }
}