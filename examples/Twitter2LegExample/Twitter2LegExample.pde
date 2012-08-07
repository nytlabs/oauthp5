import oauthP5.apis.TwitterApi;
import oauthP5.oauth.*;

final String READ_URL = "https://api.twitter.com/1/statuses/home_timeline.json";
final String POST_URL = "https://api.twitter.com/1/statuses/update.json";
final String CONSUMER_KEY = "hssrnvvwlp72wAS3DmU9g";
final String CONSUMER_SECRET = "NHkVrXBxmw5vj4jWreX2hN0XigCPFtmFafvdomds";
final String ACCESS_TOKEN = "633268302-2GEpq2svYsp2b48lwlxm4SjCnzUp3nrxSvLzja10";
final String ACCESS_TOKEN_SECRET = "C9zhkMvu2d1mQro1aexyiUhnfMGzSFIZtu57aVjYAU";


OAuthService service = new ServiceBuilder()
  .provider(TwitterApi.class)
  .apiKey(CONSUMER_KEY)
  .apiSecret(CONSUMER_SECRET)
  .debugStream(System.out)
  .build();

println("=== Twitter's 2-legged OAuth Workflow ===");
println();

// Now let's go and ask for a protected resource!
println("Now we're going to access a protected resource...");
OAuthRequest request = new OAuthRequest(Verb.GET, READ_URL);
service.signRequest(new Token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET), request);

// No query parameters for our read-only case.
Response response = request.send();

println("Got it! Lets see what we found...");
println();
println(response.getBody());
if (response.getCode() == 200) {
  println();
  println("Thats it man! Go and build something awesome with Scribe! :)");
}

// Now let's go and ask for a protected resource!
request = new OAuthRequest(Verb.POST, POST_URL);

// Twitter expects the request to be signed with your query parameters,
// so make sure you set those before generating the signature.
request.addBodyParameter("status", "this is sparta! *");

service.signRequest(new Token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET), request);

response = request.send();

println("Got it! Lets see what we found...");
println();
println(response.getBody());
if (response.getCode() == 200) {
  println();
  println("Thats it man! Go and build something awesome with Scribe! :)");
}

