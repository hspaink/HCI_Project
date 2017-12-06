import java.io.*;
import java.util.*;


public class myFileReader {  
  private int iteration = 0;
  private List<JSONObject> blocks = new ArrayList();

  public myFileReader() {
    String line = null;
    String exampleData = "";
    try {
      BufferedReader bufferedReader = createReader("exampleData.JSON");
      while ((line = bufferedReader.readLine()) != null) {
        exampleData += line;
      }   
      bufferedReader.close();
    }
    catch(FileNotFoundException ex) {
      System.out.println("Unable to open file");
    }
    catch(IOException ex) {
      ex.printStackTrace();
    }
    blockify(exampleData);
  }

  private void blockify(String s) {
    JSONObject bigBlock = parseJSONObject(s);
    JSONObject timeSeries = bigBlock.getJSONObject("Time Series (1min)");
    String timeStamp = bigBlock.getJSONObject("Meta Data").getString("3. Last Refreshed");
    Stack<JSONObject> blocksBuffer = new Stack();

    // Get all elements not yet in blocks and put them in a temporary stack
    // This allows for them to be put in the blocks array in the right order because of stack: filo
    while ((blocks.isEmpty() || timeSeries.getJSONObject(timeStamp) != blocks.get(blocks.size())) && !timeSeries.isNull(timeStamp)) {
      blocksBuffer.push(timeSeries.getJSONObject(timeStamp));
      timeStamp = decreaseTimeStamp(timeStamp);
    }
    // Move all elements from stack to blocks array
    while (true) {
      try { 
        blocks.add(blocksBuffer.pop());
      } 
      catch (EmptyStackException ex) {
        break;
      }
    }
  }

  private String decreaseTimeStamp(String timeStamp) {
    // Extract from timestamp: "yyyy-mm-dd hh:mm:ss" the integers hour and minute
    String time = timeStamp.substring(timeStamp.indexOf(' ')+1, timeStamp.length());
    int hour = Integer.parseInt(time.substring(0, time.indexOf(':')));
    time = time.substring(time.indexOf(':')+1);
    int minute = Integer.parseInt(time.substring(0, time.indexOf(':'))); 
    time = time.substring(time.indexOf(':'));
    // Decrease time by 1 minute
    if (minute == 0) {
      minute = 59;
      hour--;
    } else
      minute--;
    // Make adjustments for integers of just 1 digit
    String strMinute = "", strHour = "";
    if (minute < 10)
      strMinute += "0";
    strMinute += Integer.toString(minute);
    if (hour < 10)
      strHour += "0";
    strHour += Integer.toString(hour);
    // Stitch everything back together as a timestamp
    return timeStamp.substring(0, timeStamp.indexOf(' ')+1)+strHour+":"+strMinute+time;
  }

  public JSONObject getBlock() {
    iteration++;
    return blocks.get(iteration-1);
  }

  public boolean done() {
    return !(iteration < blocks.size());
  }
}