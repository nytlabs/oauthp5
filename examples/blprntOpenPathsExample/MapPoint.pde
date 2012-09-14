class MapPoint implements Comparable {

  PVector pos = new PVector();
  String timeString;
  Date d;
  float distance = 0;              //Distance, in KM
  float time = 0;                  //Time, in ms
  float speed = 0;                 //Speed, in m/s

  float rot;
  float dayTime = 0;

  int speedLevel = 0;

  MapPoint() {
  }

  void render() {

    if (safeCheck()) totalDistance += distance;
    boolean chk = false;
    if (sqrt(mouseX - pos.x) < 2 && sqrt(mouseY - pos.y) < 2 ) {
      fill(255);
      text(d.toString() + ": "+ speed, 50, 50); 
      chk = true;
    }

    //
    float m = map(pow(distance, 1.0/5), 0, pow(maxDist, 1.0/5), 0, 255);
    color col;
    if (speed > 70) {
      col = color(#FF0000);
    } 
    else if (speed > 10) {
      col = color(#FFFF00);
    } 
    else if (speed > 2) {
      col = color(#00FF00);
    } 
    else {
      col = color(#0000FF);
    }


    fill(col);
    pushMatrix();
    translate(pos.x, pos.y);
    ellipse(0, 0, m/25, m/25); 
    if (chk) {
      stroke(255);
      noFill();
      ellipse(0, 0, 10, 10); 
      noStroke();
    }

    popMatrix();
  }

  void renderDirection() {


    color col;
    if (speed > 70) {
      col = color(#FF0000);
    } 
    else if (speed > 10) {
      col = color(#FFFF00);
    } 
    else if (speed > 2) {
      col = color(#00FF00);
    } 
    else {
      col = color(#0000FF);
    }

    stroke(col, 100);
    //stroke(col,50);
    pushMatrix();

    rotate(rot - PI/2);

    float w = pow(distance, 0.6) * 40;
    line(0, 0, w, 0);

    translate(w, 0);
    pushMatrix();
    rotate(PI * 0.85);
    line(0, 0, 5, 0);
    popMatrix();
    pushMatrix();
    rotate(-PI * 0.85);
    line(0, 0, 5, 0);
    popMatrix();

    popMatrix();
  }

  void init(MapPoint prevPoint) {
    if (prevPoint != null) {
      distance = getDistance(pos, prevPoint.pos);
      float t = (float) ((time/1000) - (prevPoint.time/1000));
      rot = atan2(pos.x - prevPoint.pos.x, pos.y - prevPoint.pos.y);
      speed = abs((distance * 1000)/t);

      if (speed > 70) {
        speedLevel = 3;
      } 
      else if (speed > 10) {
        speedLevel = 2;
      } 
      else if (speed > 2) {
        speedLevel = 1;
      } 
      else {
        speedLevel = 0;
      }

      if (t > 0) {
        maxSpeed = max(speed, maxSpeed);
        minSpeed = min(speed, minSpeed);

        maxDist = max(distance, maxDist);
        minDist = min(distance, minDist);
      }
    }
  }

  MapPoint fromString(String s) {

    String[] ll = s.split(",");
    pos.x = float(ll[0]);
    pos.y = float(ll[1]);
    timeString = ll[3];

    try {
      d = sdf.parse(timeString);
      time = d.getTime();
      int day = 1000 * 60 * 60 * 24;
      int h = d.getHours();
      int m = d.getMinutes();
      int secs = d.getSeconds();
      dayTime = (float) ((h * 60 * 60 * 1000) + (m * 60 * 1000) + (secs * 2000)) / day;
    } 
    catch(Exception e) {
    }

    return(this);
  }

  MapPoint fromJSON(JSONObject jo) {
    //{"os":"4.0.4","lon":-73.9721194,"t":1338644827,"alt":0,"device":"samsung crespo","lat":40.7145911,"version":"1.0"}
    try {
      pos.x = float(jo.getString("lon"));
      pos.y = float(jo.getString("lat"));
      d = new Date(jo.getLong("t") * 1000);
      time = d.getTime();
      int day = 1000 * 60 * 60 * 24;
      int h = d.getHours();
      int m = d.getMinutes();
      int secs = d.getSeconds();
      dayTime = (float) ((h * 60 * 60 * 1000) + (m * 60 * 1000) + (secs * 2000)) / day;
    } 
    catch (Exception e) {
      println(e);
    }
    println(jo); 
    return(this);
  }

  public int compareTo(Object o) {
    int r = 0;
    MapPoint c = (MapPoint) o;
    if (sortMode == 0) {
      r = (int) time - (int) c.time;
    } 
    else {
      r = (int) speed - (int) c.speed;
    }
    return(r);
  }

  boolean safeCheck() {
    boolean c = (pos.y > topBorder && pos.y < bottomBorder);
    return(c);
  }
}

