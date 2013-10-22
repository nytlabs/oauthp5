/*

OpenPaths / oauthP5 example
blprnt@blprnt.com

This sketch produces an abstract composition based on your OpenPaths location data.
Location points are given a direction & duration of travel, and are arranged radially by their direction.
Color indicates speed of travel.

8/13/12

- Requires json.jar to be in the code folder.
- Requires OAuth details from OpenPaths to be entered below.

*/


import oauthP5.oauth.*;
import oauthP5.apis.*;

//OpenPaths OAuth Stuff
final String ACCESS = "YOUR ACCESS TOKEN HERE";
final String SECRET = "YOUR SECRET HERE";
final String URL = "https://openpaths.cc/api/1" ;

//ArrayList to hold all of the points received from OP
ArrayList<MapPoint> points = new ArrayList();

//Min/Max values
float maxSpeed;
float minSpeed;

float maxDist;
float minDist;

long startTime;
long endTime;

//Edges
float topBorder = 0;
float bottomBorder = 0;

//Total distance counter
float totalDistance = 0;

//Sort mode for MapPoint comparator
int sortMode = 1;

//Date converter - used when loading from a CSV file
SimpleDateFormat sdf;


void setup() {
  //Set size.
  size(1000, 1000, OPENGL);
  //Load points.
  loadPoints();
  //That's it.
}

void draw() {
  background(0);
  totalDistance = 0;
  
  //Move to the center of the screen.
  pushMatrix();
  translate(width/2, height/2);
  
  //The whole system was meant for print, so it's big. Let's shrink it.
  scale(0.5);
  noStroke();
  
  //Draw all of the point/segments.
  for (int i = 0; i < points.size(); i++) {
    MapPoint mp = (MapPoint) points.get(i);
    pushMatrix();
    float r = 50 + (sqrt(mp.distance) * 100);
    translate(cos(mp.rot - PI/2) * r, sin(mp.rot - PI/2) * r);
    mp.renderDirection();
    popMatrix();
  }

  popMatrix();
}


/*

Function to load points from the OpenPaths API.

*/
void loadPoints() {
  //OAuth
  OAuthService service = new ServiceBuilder()
    .provider(OpenPathsApi.class)
      .apiKey(ACCESS)
        .apiSecret(SECRET)
          .build();

  OAuthRequest request = new OAuthRequest(Verb.GET, URL);

  // For 3-legged authentication you would need to request the
  // authorization token, but OpenPaths is a two-legged OAuth server, so
  // the token is empty.         
  Token token = new Token("", "");
  service.signRequest(token, request);

  // Add parameters to specify that we want to retrieve location points
  // logged within the last year.
  // Make sure your request is signed before you add these parameters,
  // because the OpenPaths server expects a signature base string that
  // doesn't include non-oauth params. 
  request.addQuerystringParameter("start_time", String.valueOf((System.currentTimeMillis()/1000) - 365*24*60*60));
  request.addQuerystringParameter("end_time", String.valueOf((System.currentTimeMillis()/1000)));

  // Now we can send the fully-formed request.
  Response response = request.send();

  //The response body is in JSON form. So let's convert it:
  try {
    JSONArray ja = new JSONArray(response.getBody());
    
    for (int i = 0; i < ja.length(); i++) {
      MapPoint mp = new MapPoint().fromJSON(ja.getJSONObject(i));
      if (i > 1) {
        MapPoint lp = (MapPoint) points.get(points.size() - 1);
        mp.init(lp);
      }
      points.add(mp);
    }

    println("Minimum speed:" + minSpeed + " Maximum speed:" + maxSpeed);
    println("Minimum distance:" + minDist + " Maximum distance:" + maxDist);

    Collections.sort(points);

    startTime = points.get(0).d.getTime();
    endTime = new Date().getTime();
  } 
  catch (Exception e) {
    println("Problem loading points from the OpenPaths API:" + e);
  }
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
  if (key == 's') save("outs/OpenpathsDirections" + hour() + "_" + minute() + "_" + second()  + ".png");
}

