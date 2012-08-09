/**
 * oauthP5 FlickrExample
 *
 * The 3-legged OAuth flow allows your application to obtain an access token
 * by redirecting a user to Flickr and having them authorize your application.
 * Official Flickr OAuth guide:
 * http://www.flickr.com/services/api/auth.oauth.html
 *
 * This example retrieves and displays the last 5 photos modified in your
 * Flickr feed, assuming you have already registered an application in 
 * Flickr's App Garden on http://www.flickr.com/services/apps/create/ and
 * have the corresponding API key and secret.
 * Official Flickr API documentation:
 * http://www.flickr.com/services/api/
 *
 * by New York Times R&D Lab (achang), 2012
 * www.nytlabs.com/oauthp5
 *
 */

import oauthP5.apis.FlickrApi;
import oauthP5.oauth.*;
import controlP5.*;
import org.json.*; // documentation at http://www.json.org/java/

final String PROTECTED_RESOURCE_URL = "http://api.flickr.com/services/rest/";
final String API_KEY = "ehbfecf529ace14cda7721c5034482ae";  // use your own app's key...
final String API_SECRET = "22b6d23491c40178";


// OAuth
OAuthService service;
Token requestToken;
String authorizationUrl;
// UI
ControlP5 cp5;
Textlabel tl, tl2, tl3;
Copypaste cp = new Copypaste();
final int V_KEYCODE = 86;
final int APPLE_KEYCODE = 157;
// Photos
String[] urls = new String[0];
PImage[] imgs = new PImage[0];
final int OFFSET = 250;


void setup() {
  initUI();
  initOAuth();
}

void draw() {
  drawPhotos();
}


// --- OAuth ---

// This function builds the oauth service object that will handle the request for us.
// In initialization, we feed in our credentials and get the authorization url and 
// then we wait for the user to go to the url, authorize their account, and bring
// back a verification code.
void initOAuth() {
  service = new ServiceBuilder()
    .provider(FlickrApi.class)
      .apiKey(API_KEY)
        .apiSecret(API_SECRET)
          .build();


  println("=== Flickr's OAuth Workflow ===");
  println();

  // Obtain the Request Token
  println("Fetching the Request Token...");
  requestToken = service.getRequestToken();
  println("Got the Request Token!");
  // Unfortunately the permissions parameter wasn't built into Scribe's Flickr 
  // Service Builder so we need to tag it on below.  If you just remove the 'perms'
  // parameter, then the app will request the user for write (e.g. comment,
  // upload, and delete) permissions.
  authorizationUrl = service.getAuthorizationUrl(requestToken) + "&perms=read";
  println();

  println("Now go and authorize your application here by clicking the OPEN button.");
  println("(in case you're curious it links to here: "+authorizationUrl+" )");
  println();
  println("Once the user logs in they will be redirected to a page that simply says 'Success'.");
  println("Copy the code after 'code=' in the url field and paste it in Processing.");
  println();
}

// Once the user submits a verification code in the textfield, we have permission to
// let our oauth service make a request for data.
void makeOAuthRequest(String verifierString) {

  // Make Verifier object
  Verifier verifier = new Verifier(verifierString);
  println("Got the authorization code "+verifierString);
  println();

  // Trade the Request Token and Verifier for the Access Token
  println("Trading the Request Token for an Access Token...");
  Token accessToken = service.getAccessToken(requestToken, verifier);
  println("Got the Access Token!");
  println("(if you're curious it looks like this: " + accessToken + " )");
  println();

  // Read demo:

  println("Let's check out the last 5 photos in your Flickr stream...");
  OAuthRequest request = new OAuthRequest(Verb.GET, PROTECTED_RESOURCE_URL);

  // Flickr expects the request to be signed with your query parameters,
  // so make sure you set them (if you want any) before generating the signature.
  // Required parameters for the recentlyUpdated method is documented
  // here: http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.htm 
  request.addQuerystringParameter("method", "flickr.photos.recentlyUpdated");
  request.addQuerystringParameter("min_date", "01/01/2011");
  request.addQuerystringParameter("per_page", "5");
  request.addQuerystringParameter("page", "1");
  request.addQuerystringParameter("format", "json");
  request.addQuerystringParameter("nojsoncallback", "1");

  service.signRequest(accessToken, request);
  Response response = request.send();

  println("Got it! Let's see what we found...");
  println();
  println(response.getBody());
  if (response.getCode() == 200) {
    println();
    println("Cool, we got our data. Now let's draw it!");
    makePhotos(response.getBody());
  }
  println();
}

// ---- Photos ----

// Parse the returned data and draw the images. Note that
// Flickr doesn't ever actually return image urls for you.
// Instead, they give you information to construct urls
// for the specific image format you want. In this example
// we pull the small size photo, which is defined as being
// 240px on the longest side.
// More here about constructing Flickr Photo Source URLs:
// http://www.flickr.com/services/api/misc.urls.html
void makePhotos(String s) {
  try {
    JSONObject obj = new JSONObject(s);
    JSONArray photos = obj.getJSONObject("photos").getJSONArray("photo");
    urls = new String[photos.length()];
    imgs = new PImage[photos.length()];
    for (int i = 0; i < urls.length; i++) {
      JSONObject p = photos.getJSONObject(i);
      urls[i] = "http://farm" + p.getInt("farm")
        + ".staticflickr.com/" + p.getString("server")
          + "/" + p.getString("id") + "_" + p.getString("secret")
            + "_m.jpg";
      imgs[i] = loadImage(urls[i], "jpg");
    }
  } 
  catch(Exception e) {
    println("JSON parsing error. Check your string. "+e);
  }
}

void drawPhotos() {
    for (int i = 0; i < urls.length; i++) {
    image(imgs[i], i*OFFSET+10, 170);
  }
}


// ---- UI ----

void initUI() {
  size(1250, 440);
  background(0);

  cp5 = new ControlP5(this);

  tl = cp5.addTextlabel("title")
    .setText("FLICKR OAUTH")
      .setPosition(10, 10);

  tl2 = cp5.addTextlabel("label")
    .setText("First, authorize your application here via the browser:")
      .setPosition(10, 40);

  cp5.addBang("open")
    .setPosition(10, 50)
      .setSize(80, 20)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  tl3 = cp5.addTextlabel("label2")
    .setText("Copy the 'code' given at the end of the url and paste it here:")
      .setPosition(10, 90);

  cp5.addTextfield("verifier")
    .setPosition(10, 100)
      .setSize(200, 20)
        .setFont(createFont("arial", 12))
          .setAutoClear(false);

  cp5.addBang("ok")
    .setPosition(215, 100)
      .setSize(40, 20)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
}

// Clicking the OPEN button opens a new browser tab to Twitter's authentication page
public void open() {
  link(authorizationUrl, "_new");
}

// Clicking the OK button will initiate an oauth request using the textfield string as verifier
public void ok() {
  String verifierString = cp5.get(Textfield.class, "verifier").getText();
  makeOAuthRequest(verifierString);
}

// Processing doesn't natively handle copy-paste from your OS clipboard,
// so we add the Clipboard class in the other file, and add code to handle 
// corresponding key events here.
void keyReleased()
{ 
  keys[keyCode] = false;
}
void keyPressed()
{ 
  keys[keyCode] = true;
  if ((checkKey(CONTROL) && checkKey(V_KEYCODE)) // windows
  ||
    (checkKey(APPLE_KEYCODE) && checkKey(V_KEYCODE))) // mac
  {
    cp5.get(Textfield.class, "verifier").setText(cp.pasteString());
    println("Pasted from clipboard: "+cp.pasteString());
  }
  // we don't need paste-functionality here, but if you want you can do it this way:
  //  final int C_KEYCODE = 67;
  //  if (checkKey(CONTROL) && checkKey(C_KEYCODE)) {
  //    cp.copyString(cp5.get(Textfield.class, "verifier").getText());
  //  }
}

