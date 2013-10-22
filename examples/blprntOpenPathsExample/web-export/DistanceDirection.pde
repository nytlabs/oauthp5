ArrayList<MapPoint> points = new ArrayList();

float maxSpeed;
float minSpeed;

float maxDist;
float minDist;

float topBorder = 0;
float bottomBorder = 0;
boolean setting = false;

float totalDistance = 0;

long startTime;
long endTime;

SimpleDateFormat sdf;

void setup() {
  size(1280,720);
  
  //2010-09-16 02:56:33
  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  loadPoints();
  
  
}

void draw() {
  background(0);
  totalDistance = 0;
  translate(0, height/2);
  
  noStroke();
  for (int i = 0; i < points.size(); i++) {
    
    MapPoint mp = (MapPoint) points.get(i);
    /*
    //mp.pos.x = map(i, 0, points.size(), 0, width);
    mp.pos.x = map(mp.d.getTime(), startTime, endTime, 50, width - 50);
    //mp.pos.y = 500 - map(pow(mp.speed, 1.0/4), 0, pow(maxSpeed, 1.0/4), 0, 480);
    mp.pos.y = 500 - map(log(mp.speed), 0, log(maxSpeed), 0, 480);
    */
    pushMatrix();
    //rotate(map(mp.dayTime, 0, 1, 0, TWO_PI));
    translate(map(mp.dayTime, 0, 1, 50, width - 50),0);
    mp.renderDirection();
    popMatrix();
  }

  fill(255);
  text(frameRate, 50, 70);
}

void loadPoints() {
  //Get points from CSV - this should be replaced by a JSON return
  String[] plist = loadStrings("openpaths_house.csv");
  for (int i = 1; i < plist.length; i++) {
    MapPoint mp = new MapPoint().fromString(plist[i]);
    if (i > 1) {
      MapPoint lp = (MapPoint) points.get(points.size() - 1);
      mp.init(lp);
    }
    points.add(mp);
  }

  println(minSpeed + ":" + maxSpeed);
  println(minDist + ":" + maxDist);

  Collections.sort(points);
  
  startTime = points.get(0).d.getTime();
  endTime = new Date().getTime();//points.get(points.size() - 1).d.getTime();
  
  println(points.get(0).timeString);
  println(points.get(points.size() - 1).timeString);
}

float getDistance(PVector p1, PVector p2) {

  float R = 6367;
  float dlon = degreesToRadians(p1.y) - degreesToRadians(p2.y);
  float dlat = degreesToRadians(p1.x) - degreesToRadians(p2.x);
  float a = pow( sin(dlat/2), 2) + cos(degreesToRadians(p2.x)) * cos(degreesToRadians(p1.x)) * pow(sin(dlon/2), 2);
  float c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return( R * c);
}

float degreesToRadians(float d) {
  return((d/180) * PI);
};

void keyPressed() {
 if (key == 's') save("outs/moon" + hour() + "_" + minute() + "_" + second()  + ".png"); 
}

class MapPoint implements Comparable {

  PVector pos = new PVector();
  String timeString;
  Date d;
  float distance = 0;              //Distance, in KM
  float time = 0;                  //Time, in ms
  float speed = 0;                 //Speed, in m/s
  
  float rot;
  float dayTime = 0;

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
    stroke(255,60);
    
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
    //stroke(col,50);
    pushMatrix();
     
      rotate(rot - PI/2);
      
      float w = pow(distance,0.3) * 40;
      line(0,0,w,0);
      
      translate(w,0);
      pushMatrix();
        rotate(PI * 0.85);
        line(0,0,5,0);
      popMatrix();
      pushMatrix();
        rotate(-PI * 0.85);
        line(0,0,5,0);
      popMatrix();

    popMatrix();
  }

  void init(MapPoint prevPoint) {
    if (prevPoint != null) {
      distance = getDistance(pos, prevPoint.pos);
      float t = (float) ((time/1000) - (prevPoint.time/1000));
      rot = atan2(pos.x - prevPoint.pos.x, pos.y - prevPoint.pos.y);
      speed = abs((distance * 1000)/t);

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
    
    //2010-09-16 02:56:33
    //long t = Long.parseLong(split(timeString, ".")[0]) * 1000;
    try {
      d = sdf.parse(timeString);
      time = d.getTime();
      int day = 1000 * 60 * 60 * 24;
      int h = d.getHours();
      int m = d.getMinutes();
      int secs = d.getSeconds();
      dayTime = (float) ((h * 60 * 60 * 1000) + (m * 60 * 1000) + (secs * 2000)) / day;
    } catch(Exception e) {
      
    }
    
    return(this);
  }

  public int compareTo(Object o) {
    MapPoint c = (MapPoint) o;
    return((int) time - (int) c.time);
  }

  boolean safeCheck() {
    boolean c = (pos.y > topBorder && pos.y < bottomBorder);
    return(c);
  }
}

class PathSegment {
  
  ArrayList points = new ArrayList();
 
  PathSegment() {
    
  }
  
}
public class Segmentor {
  
  ArrayList<PathSegment> segments = new ArrayList();
  PathSegment currentSegment;
  
  Segmentor() {
  
  }
  
  void segment(ArrayList<MapPoint> points) {
    
  }
  
  boolean linkCheck(MapPoint a, MapPoint b) {
    return(true);
  }
}

