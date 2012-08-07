import oauthP5.apis.OpenPathsApi;
import oauthP5.oauth.*;


final String ACCESS = "XWCK2YLNWMUGNIKGZGZRPUF342UH2IWL4SM7GNW6MQ6VRWZDVCIQ";
final String SECRET = "NAXMTNM76FD2YC9BR4HQC7MRVYKNAW6W91Z8V1C5FKH6YLY0ORZZXEO4TIFSSO2X";
final String URL = "https://openpaths.cc/api/1" ;

OAuthService service = new ServiceBuilder()
  .provider(OpenPathsApi.class)
  .apiKey(ACCESS)
  .apiSecret(SECRET)
  //.debugStream(System.out)
  .build();

println("=== OpenPaths' OAuth Workflow ===");
println();
println("Now we're going to access a protected resource...");

OAuthRequest request = new OAuthRequest(Verb.GET, URL);

// For 3-legged authentication you would need to request the
// authorization token, but OpenPaths is a two-legged OAuth server, so
// the token is empty.         
Token token = new Token("", "");
service.signRequest(token, request);

// Make sure your request is signed before you add these parameters,
// because the OpenPaths server expects a signature base string that
// doesn't include non-oauth params. 
request.addQuerystringParameter("start_time", String.valueOf(System.currentTimeMillis() - 24*60*60));
request.addQuerystringParameter("end_time", String.valueOf(System.currentTimeMillis()));

// Now we can send the fully-formed request.
Response response = request.send();

//	    println(request.getCompleteUrl());
//	    println(request.getHeaders());
println();
println("Got it! Lets see what we found...");
println();
println(response.getBody());
if (response.getCode() == 200) {
  println();
  println("Thats it man! Go and build something awesome with Scribe! :)");
}
