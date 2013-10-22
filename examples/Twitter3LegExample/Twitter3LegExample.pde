/**
 * oauthP5 Twitter3LegExample
 *
 * The 3-legged OAuth flow allows your application to obtain an access token
 * by redirecting a user to Twitter and having them authorize your application.
 * Official guide from Twitter: 
 * https://dev.twitter.com/docs/auth/3-legged-authorization
 *
 * This example demonstrates both how to read data from your twitter
 * feed and how to post a tweet to your account, assuming you have already
 * registered an application with Twitter on dev.twitter.com and have the
 * corresponding consumer key and secret.
 *
 * by New York Times R&D Lab (achang), 2012
 * www.nytlabs.com/oauthp5
 *
 */

import oauthP5.apis.TwitterApi;
import oauthP5.oauth.*;
import controlP5.*;

final String READ_URL = "https://api.twitter.com/1/statuses/home_timeline.json";
final String POST_URL = "https://api.twitter.com/1/statuses/update.json";
final String CONSUMER_KEY = "hssrnvvwlp72wAS3DmU9g"; // use your own app's key...
final String CONSUMER_SECRET = "NHkVrXBxmw5vj4jWreX2hN0XigCPFtmFafvdomds";

// OAuth
OAuthService service;
Token requestToken;
// UI
ControlP5 cp5;
Textlabel tl, tl2, tl3;
Copypaste cp = new Copypaste();
final int V_KEYCODE = 86;
final int APPLE_KEYCODE = 157;


void setup() {
  initUI();
  initOAuth();
}

// ControlP5 requires this to do things in the background, but we ourselves
// don't actually need to draw anything
void draw() {
}


// --- OAuth ---

// This function builds the oauth service object that will handle the request for us.
// In initialization, we feed in our credentials and get the authorization url and 
// then we wait for the user to go to the url, authorize their account, and bring
// back a verification code.
void initOAuth() {
  service = new ServiceBuilder()
    .provider(TwitterApi.class)
      .apiKey(CONSUMER_KEY)
        .apiSecret(CONSUMER_SECRET)
          .build();

  println("=== Twitter's 3-Legged OAuth Workflow ===");
  println();

  // Obtain the Request Token
  println("Fetching the Request Token...");
  requestToken = service.getRequestToken();
  println("Got the Request Token!");
  println();

  println("Now go and authorize your application here by clicking the OPEN button.");
  println("(in case you're curious it links to here: "+service.getAuthorizationUrl(requestToken)+" )");
  println("And paste the verifier in the text field.");
  println();
}

// Once the user submits a verification code in the textfield, we have permission to
// let our oauth service make a request for data.
void makeOAuthRequest(String verifierString) {

  // Make Verifier object
  Verifier verifier = new Verifier(verifierString);
  println("Got the authorization code "+verifierString+".");
  println();

  // Trade the Request Token and Verifier for the Access Token
  println("Trading the Request Token for an Access Token...");
  Token accessToken = service.getAccessToken(requestToken, verifier);
  println("Got the Access Token!");
  println("(if you're curious it looks like this: " + accessToken + " )");
  println();

  // Read demo:
  
  println("Let's check out the latest tweets in the user's twitter feed...");
  OAuthRequest request = new OAuthRequest(Verb.GET, READ_URL);
  service.signRequest(accessToken, request);
  
  // No query parameters for our read-only case.
  Response response = request.send();
  
  println("Got it! Let's see what we found...");
  println();
  println(response.getBody());
  if (response.getCode() == 200) {
    println();
    println("That's it!");
    println();
  }
  
  // Post demo:
  
  println("Now let's try and post a tweet...");
  request = new OAuthRequest(Verb.POST, POST_URL);
  // Twitter expects the request to be signed with your query parameters,
  // so make sure you set them (if you want any) before generating the signature.
  request.addBodyParameter("status", "this is sparta!");

  // Sign and send the request
  service.signRequest(accessToken, request);
  response = request.send();
  println("Got it! Lets see what we found...");
  println();
  println(response.getBody());
  println();
  if (response.getCode() == 200) {
    println();
    println("That's it! Go and build something awesome with your data!");
  }
}



// ---- UI ----

void initUI() {
  size(380, 170);
  background(0);

  cp5 = new ControlP5(this);

  tl = cp5.addTextlabel("title")
    .setText("TWITTER 3-LEGGED OAUTH")
      .setPosition(10, 10);

  tl2 = cp5.addTextlabel("label")
    .setText("First, authorize your application here via the browser:")
      .setPosition(10, 40);

  cp5.addBang("open")
    .setPosition(10, 50)
      .setSize(80, 20)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  tl3 = cp5.addTextlabel("label2")
    .setText("Then paste the verifier PIN here:")
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
  link(service.getAuthorizationUrl(requestToken), "_new");
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
// we don't need paste-functionality here, but you can do it this way:
//  final int C_KEYCODE = 67;
//  if (checkKey(CONTROL) && checkKey(C_KEYCODE)) {
//    cp.copyString(cp5.get(Textfield.class, "verifier").getText());
//  }
}
