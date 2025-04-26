import "@typespec/http";
import "@typespec/versioning";

using Http;
using Versioning;

@service(#{ title: "Clustron API", version: "1.0.0" })
@server("https://example.com", "Single server endpoint")
@versioned(Versions)
@route("/api")
namespace Clustron;

enum Versions {
  v1: "1.0.0",
}

model UserSettings {
  @doc("The computer username of the user.")
  username: string;
}

model PublicKey {
  @doc("The public key title set by the user.")
  title: string;

  @doc("The public key of the user.")
  publicKey: string;
}

@tag("User")
namespace Settings {
  @route("/settings")
  @get
  op getUserSettings(): {
    @statusCode statusCode: 200;
    @body settings: UserSettings;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings")
  @put
  op updateUsername(@body username: string): {
    @statusCode statusCode: 200;
    @body username: string;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings/username")
  @get
  op getUsername(): {
    @statusCode statusCode: 200;
    @body username: string;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @get
  op getPublicKey(
    @doc("Get 10 head characters of publickey as short public key in 'publickey' field.")
    @query
    short?: boolean,
  ): {
    @statusCode statusCode: 200;
    @body publicKey: PublicKey[];
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @post
  op addPublicKey(@body publicKey: string): {
    @statusCode statusCode: 200;
    @body publicKey: PublicKey;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @delete
  op deletePublicKey(@body publicKey: string): {
    @statusCode statusCode: 200;
    @body title: string;
  } | {
    @statusCode statusCode: 404;
  };
}
