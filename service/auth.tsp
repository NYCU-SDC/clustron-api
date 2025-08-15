import "@typespec/http";

using Http;

@tag("Auth")
namespace Clustron.Auth {
  enum OAuthProviders {
    google: "google",
    nycu: "nycu",
  }

  model RefreshToken {
    @doc("The new JWT")
    accessToken: string;

    @doc("The expiration date of the refresh token.")
    expirationTime: integer;

    @doc("The new refresh token.")
    refreshToken: string;
  }

  @route("/login/oauth/{provider}")
  @get
  op loginGoogle(
    @doc("The OAuth2 provider to use for login.")
    @path
    provider: OAuthProviders,

    @doc("The callback URL of the OAuth2 login. [See details](https://clustron.atlassian.net/wiki/spaces/cd/pages/18219016/Backend+OAuth+JWT+Manual)")
    @query
    c: string,

    @doc("The redirect URL for login callback.")
    @query
    r?: string,
  ): {
    @statusCode statusCode: 302;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/refreshToken/{refreshToken}")
  @get
  op refreshToken(
    @doc("The refresh token to use for refreshing the access token.")
    @path
    refreshToken: string,
  ): {
    @statusCode statusCode: 200;
    @body refreshToken: RefreshToken;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/logout")
  @post
  op logout(): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/bind/oauth/{provider}")
  @get
  op bindOAuth(
    @doc("The OAuth2 provider to bind.")
    @path
    provider: OAuthProviders,

    @doc("The callback URL of the OAuth2 login. [See details](https://clustron.atlassian.net/wiki/spaces/cd/pages/18219016/Backend+OAuth+JWT+Manual)")
    @query
    c: string,

    @doc("The redirect URL for login callback.")
    @query
    r?: string,
  ): {
    @statusCode statusCode: 302;
  } | {
    @statusCode statusCode: 404;
  };
}
