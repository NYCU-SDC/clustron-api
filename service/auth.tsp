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
    @example("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    accessToken: string;

    @doc("The expiration date of the refresh token.")
    @example(1700000000)
    expirationTime: integer;

    @doc("The new refresh token.")
    @example("rftk_1234567890abcdef")
    refreshToken: string;
  }

  model BindLoginInfoResponse {
    @doc("OAuth url")
    @example("/api/bind/oauth/google?http://localhost:8080/callback/bind")
    url: string;
  }

  @route("/login/oauth/{provider}")
  @get
  op loginGoogle(
    @doc("The OAuth2 provider to use for login.")
    @path
    provider: OAuthProviders,

    @doc("The callback URL of the OAuth2 login. [See details](https://clustron.atlassian.net/wiki/spaces/cd/pages/18219016/Backend+OAuth+JWT+Manual)")
    @query
    @example("http://localhost:8080/callback")
    c: string,

    @doc("The redirect URL for login callback.")
    @query
    @example("http://localhost:8080/")
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
    @example("rftk_1234567890abcdef")
    refreshToken: string,
  ): {
    @statusCode statusCode: 200;
    @body refreshToken: RefreshToken;
  } | {
    @statusCode statusCode: 404;
  } | Error.InvalidUuidFormatProblem;

  @route("/logout")
  @post
  op logout(): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/bind/oauth/{provider}")
  @post
  op bindOAuth(
    @doc("The OAuth2 provider to bind.")
    @path
    provider: OAuthProviders,

    @doc("The callback URL of the OAuth2 login. [See details](https://clustron.atlassian.net/wiki/spaces/cd/pages/18219016/Backend+OAuth+JWT+Manual)")
    @query
    @example("http://localhost:8080/callback")
    c: string,

    @doc("The redirect URL for login callback.")
    @query
    @example("http://localhost:8080/")
    r?: string,
  ): {
    @statusCode statusCode: 200;
    @body url: BindLoginInfoResponse;
  } | {
    @statusCode statusCode: 404;
  };
}
