import java.util.*;
import java.lang.reflect.Method;

public class DataStream {
  // To get block of data every second
  private myTimerTask getDataTimerTask;
  private myTimerTask outputStreamTimerTask;

  private boolean paused = true;

  private DataToAudio dataToAudio = null;
  private myFileReader fileReader = null;

  // Data storage + values
  private Queue<JSONObject> dataBuffer = new ArrayDeque<JSONObject>(); // Queue datastructure because of fifo properties
  private float streamHighest;
  private float streamLowest;

  private float currentPrice;

  // Speakers: {front, middle, back} [{top, bottom}]
  private float[] pitchLevels = new float[NUM_OUTPUTS];
  private float[][] volumeLevels = new float[NUM_OUTPUTS][2];


  public DataStream(DataToAudio dataToAudio) {
    // Init variables
    getDataTimerTask = new myTimerTask(this, "getData", UPDATE_FREQ);
    outputStreamTimerTask = new myTimerTask(this, "outputStream", UPDATE_FREQ);
    this.dataToAudio = dataToAudio;
    fileReader = new myFileReader();
    streamHighest = 0;
    streamLowest = Float.MAX_VALUE;
    currentPrice = 0;
    for (float pitchLevel : pitchLevels)
      pitchLevel = 0;
    for (float[] volumeLevel : volumeLevels) {
      volumeLevel[0] = 0;
      volumeLevel[1] = 0;
    }

    initStream();
  }

  private void initStream() {
    // TODO setup real data stream

    // Temporary solution:
    System.out.println("Starting stream...");
    getDataTimerTask.start();
    outputStreamTimerTask.start();    
  }

  public void togglePaused() {
    paused = !paused;
    STATE = !paused?"Streaming":"Paused";
  }

  public void outputStream() {
    // send parsed data as updated pitch and volume levels to speakers 1 trough 6
    if (!paused) {
      // Get first object from buffer
      JSONObject object;
      if ((object = dataBuffer.poll()) == null) {
        outputStreamTimerTask.endTimerTask();
        STATE = "End";
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
      for (int i = NUM_OUTPUTS-1; i > 0; --i) {
        pitchLevels[i] = pitchLevels[i-1];
        volumeLevels[i][0] = volumeLevels[i-1][0];
        volumeLevels[i][1] = volumeLevels[i-1][1];
      }
      pitchLevels[0] = newPitch;
      if (streamHighest-streamLowest != 0) {
        volumeLevels[0][0] = tradeVolume * (newHeight-streamLowest)/(streamHighest-streamLowest);
        volumeLevels[0][1] = tradeVolume * (1 - (newHeight-streamLowest)/(streamHighest-streamLowest));
      }
      else 
        volumeLevels[0][0] = volumeLevels[0][1] = 2000;

      dataToAudio.output(pitchLevels, volumeLevels);
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
  
}