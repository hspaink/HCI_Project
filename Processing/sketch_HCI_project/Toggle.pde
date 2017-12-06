public class Toggle {
  private int xsize; 
  private int ysize;
  private int fill;
  private float xpos; 
  private float ypos;
  private String text;

  public Toggle (int x, int y, int f, float xp, float yp, String t) {
    xsize = x;
    ysize = y;
    fill = f;
    xpos = xp;
    ypos = yp;
    text = t;
  }

  public void display() {
    rectMode(CENTER);
    fill(fill);
    rect(xpos, ypos, xsize, ysize);
    fill(255);
    textAlign(CENTER,CENTER);
    text(text, xpos, ypos);
  }

  public float getxpos() {
    return xpos;
  }

  public float getypos() {
    return ypos;
  }

  public float getxsize() {
    return xsize;
  }

  public float getysize() {
    return ysize;
  }
}