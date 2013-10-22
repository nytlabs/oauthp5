/**
 * oauthP5 FacebookExample
 *
 * The 3-legged OAuth flow allows your application to obtain an access token
 * by redirecting a user to Facebook and having them authorize your application.
 * Official guide from Facebook: 
 * http://developers.facebook.com/docs/authentication/
 *
 * This example demonstrates both how to read data from your Facebook profile
 * and how to post a status update to the account, assuming you have already
 * registered an application with Facebook on developers.facebook.com and have the
 * corresponding API key and secret.
 * For official documentation on the Facebook Graph API see:
 * http://developers.facebook.com/docs/reference/api/
 *
 * by New York Times R&D Lab (achang), 2012
 * www.nytlabs.com/oauthp5
 *
 */

import oauthP5.apis.FacebookApi;
import oauthP5.oauth.*;
import controlP5.*;

final String PROFILE_RESOURCE_URL = "https://graph.facebook.com/me";
final String WALL_POST_URL = "https://graph.facebook.com/me/feed";
final String API_KEY = "405574196167719";  // use your own app's key...
final String API_SECRET = "745083bea6d2a26d61315592e3bb0e17";
final Token EMPTY_TOKEN = null;

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
    .provider(FacebookApi.class)
      .apiKey(API_KEY)
        .apiSecret(API_SECRET)
          .callback("https://www.facebook.com/connect/login_success.html")
           // The scope parameter is a comma-separated list of permissions your 
           // app is requesting from the user. This line is required to post on
           // a user's wall, but not necessary for read-access. If you wish to
           // perform other actions you might need to request different permissions.
           // See: http://developers.facebook.com/docs/authentication/permissions/
           .scope("publish_stream")
            .build();


  println("=== Facebook's OAuth Workflow ===");
  println();

  // Obtain the Request Token
  println("Fetching the Authorization URL...");
  authorizationUrl = service.getAuthorizationUrl(EMPTY_TOKEN);
  println("Got the Authorization URL!");
  println();

  println("Now go and authorize your application here by clicking the OPEN button.");
  println("(in case you're curious it links to here: "+authorizationUrl+" )");
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
  Token accessToken = service.getAccessToken(EMPTY_TOKEN, verifier);
  println("Got the Access Token!");
  println("(if you're curious it looks like this: " + accessToken + " )");
  println();

  // Read demo:

  println("Let's check out the information on your Facebook profile...");
  OAuthRequest request = new OAuthRequest(Verb.GET, PROFILE_RESOURCE_URL);
  service.signRequest(accessToken, request);

  // No query parameters for our read-only case.
  Response response = request.send();

  println("Got it! Let's see what we found...");
  println();
  println(response.getBody());
  if (response.getCode() == 200) {
    println();
    println("That's it! Go and build something awesome with your data!");
  }
  println();

  // Post demo:

  println("Now let's try and post a message to your wall...");
  request = new OAuthRequest(Verb.POST, WALL_POST_URL);

  // Facebook expects the request to be signed with your query parameters,
  // so make sure you set those before generating the signature.
  request.addBodyParameter("message", "oauthP5 says hi from Processing! w00t!");

  service.signRequest(accessToken, request);

  response = request.send();

  println("Got it! Let's check the response...");
  println();
  println(response.getBody());
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
    .setText("FACEBOOK (3-LEGGED) OAUTH")
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

