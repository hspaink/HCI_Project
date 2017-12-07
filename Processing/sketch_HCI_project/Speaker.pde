public class Speaker {
  private float pitch;
  private float volume;
  
  public Speaker() {
    pitch = volume = 0;
  }
  
  public void setPitch(float pitch) {
    this.pitch = pitch;
  }
  
  public float getPitch() {
    return pitch;
  }
  
  public void setVolume(float volume) {
    this.volume = volume;
  }
  
  public float getVolume() {
    return volume/2000;
  }
}