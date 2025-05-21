import "@typespec/http";

using Http;

@tag("User")
namespace Clustron.Settings {
  model UserSettings {
    @doc("The real name of the user.")
    fullName: string;

    @doc("The computer account name of the user.")
    linuxUsername: string;
  }

  model PublicKey {
    @doc("The public key id in UUID format.")
    id: string;

    @doc("The public key title set by the user.")
    title: string;

    @doc("The public key of the user.")
    publicKey: string;
  }

  model AddPublicKeyRequest {
    @doc("The public key title set by the user.")
    title: string;

    @doc("The public key of the user.")
    publicKey: string;
  }

  model DeletePublicKeyRequest {
    @doc("The public key id in UUID format.")
    id: string;
  }

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
  op updateSettings(@body body: UserSettings): {
    @statusCode statusCode: 200;
    @body newSettings: UserSettings;
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
  op addPublicKey(@body body: AddPublicKeyRequest): {
    @statusCode statusCode: 200;
    @body publicKey: PublicKey;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @delete
  op deletePublicKey(@body body: DeletePublicKeyRequest): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };
}
