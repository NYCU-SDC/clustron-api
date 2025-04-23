import "@typespec/http";
import "@typespec/versioning";

using Http;
using Versioning;

@service(#{ title: "Clustron API", version: "1.0.0" })
@server("https://example.com", "Single server endpoint")
@versioned(Versions)
namespace Clustron;

enum Versions {
  v1: "1.0.0",
}

@doc("User settings that are needed for access to the machine.")
model UserSettings {
  username: string;
  publicKey: string[];
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

  @route("/settings/username")
  @get
  op getUsername(): {
    @statusCode statusCode: 200;
    @body username: string;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings/username")
  @put
  op updateUsername(@body username: string): {
    @statusCode statusCode: 200;
    @body username: string;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings/publickey")
  @get
  op getPublicKey(): {
    @statusCode statusCode: 200;
    @body publicKey: string[];
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings/publickey")
  @post
  op addPublicKey(@body publicKey: string): {
    @statusCode statusCode: 200;
    @body publicKey: string;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings/publickey")
  @delete
  op deletePublicKey(@body publicKey: string): {
    @statusCode statusCode: 200;
    @body publicKey: string;
  } | {
    @statusCode statusCode: 404;
  };
}
