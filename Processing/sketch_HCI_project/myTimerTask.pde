import java.lang.reflect.Method;

public class myTimerTask extends Thread {
  private Object object;
  private Method method;
  private int interval;
  private boolean end = false;

  public myTimerTask(Object object, String methodName, int interval) {
    this.object = object;
    try {
      Method method = object.getClass().getMethod(methodName);
      this.method = method;
    } catch (Exception e) {
      e.printStackTrace();
    }
    this.interval = interval;
  }

  @Override
    public void run() {
    while (!end) {
      try {
        method.invoke(object);
        Thread.sleep(interval);
      } catch (Exception e) {
        e.printStackTrace();
        break;
      }
    }
  }

  public void endTimerTask() {
    end = true;
  }
}