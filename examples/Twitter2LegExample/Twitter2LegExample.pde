/**
* oauthP5 Twitter2LegExample
*
* Twitter offers the ability for you to retrieve a single access token 
* (complete with oauth_token_secret) from your application detail page found 
* on dev.twitter.com/apps. This is ideal for applications with single-user
* use cases. By using a single access token, you don't need to implement 
* the entire OAuth token acquisition dance. Instead, you can pick up from 
* the point where you are working with an access token to make signed 
* requests for Twitter resources.
* Official guide from Twitter: 
* https://dev.twitter.com/docs/auth/oauth/single-user-with-examples
*
* This example demonstrates both how to read data from your twitter
* feed and how to post a tweet to your account, assuming you have already
* registered an application with Twitter on dev.twitter.com.
*
* by New York Times R&D Lab (achang), 2012
* www.nytlabs.com/oauthp5
*
*/

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
  //uncomment the following line to see details on what ServiceBuilder is doing
//  .debugStream(System.out)
  .build();

println("=== Twitter's 2-legged OAuth Workflow ===");
println();

// Read demo:

println("Let's check out the latest tweets in your twitter feed...");
OAuthRequest request = new OAuthRequest(Verb.GET, READ_URL);
service.signRequest(new Token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET), request);

// No query parameters for our read-only case.
Response response = request.send();

println("Got it! Let's see what we found...");
println();
println(response.getBody());
if (response.getCode() == 200) {
  println();
  println("Thats it! Go and build something awesome with your data!");
}

// Post demo:

println("Now let's try and post a tweet...");
request = new OAuthRequest(Verb.POST, POST_URL);

// Twitter expects the request to be signed with your query parameters,
// so make sure you set those before generating the signature.
request.addBodyParameter("status", "this is sparta!");

service.signRequest(new Token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET), request);

response = request.send();

println("Got it! Let's check the response...");
println();
println(response.getBody());
if (response.getCode() == 200) {
  println();
  println("Thats it! Go and build something awesome with your data!");
}

