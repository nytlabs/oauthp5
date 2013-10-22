package oauthP5.apis;

import oauthP5.oauth.BaseStringExtractor;
import oauthP5.oauth.BaseStringExtractorImpl;
import oauthP5.oauth.OAuthRequest;
import oauthP5.oauth.Parameter;
import oauthP5.oauth.ParameterList;
import oauthP5.oauth.Token;


/**
 * @author achang
 * 
 */
public class OpenPathsApi extends DefaultApi10a {

	@Override
	public String getAccessTokenEndpoint() {
		return null;
	}

	@Override
	public String getRequestTokenEndpoint() {
		return null;
	}

	@Override
	public String getAuthorizationUrl(Token requestToken) {
		return null;
	}

	@Override
	public BaseStringExtractor getBaseStringExtractor() {
		return new OpenPathsBaseStringExtractor();
	}

	/**
	 * So these are actually non-ideal because they require changing access
	 * levels of Scribe's original code (which means we can't use Scribe in a
	 * jar.) But maybe that's okay and we only want selected parts of Scribe in
	 * our P5-OAuth library anyway.
	 * 
	 * @author achang
	 */
	public class ParameterListExt extends ParameterList {
		public boolean remove(Parameter p) {
			return params.remove(p);
		}
	}

	/**
	 * @author achang
	 */
	public class OpenPathsBaseStringExtractor extends BaseStringExtractorImpl {
		@Override
		protected String getSortedAndEncodedParams(OAuthRequest request) {
			ParameterListExt params = new ParameterListExt();
			params.addAll(request.getQueryStringParams());
			params.addAll(request.getBodyParams());
			params.addAll(new ParameterList(request.getOauthParameters()));
			System.out.println(params.remove(new Parameter("oauth_token", "")));
			return params.sort().asOauthBaseString();
		}

	}

}
