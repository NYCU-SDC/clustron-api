import "@typespec/http";
import "@typespec/versioning";
import "./service/group.tsp";

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

@format("uuid")
scalar uuid extends string;

@format("email")
scalar email extends string;

model PaginatedParams {
  @example(1)
  @query
  page?: int32;

  @example(10)
  @minValue(1)
  @maxValue(100)
  @query
  size?: int32;

  @example("asc")
  @query
  sort?: "asc" | "desc";

  @example("createdAt")
  @query
  sortBy?: string;
}

model PaginatedResponse<T> {
  items: T[];

  @example(10)
  totalPages: int32;

  @example(100)
  totalItems: int32;

  @example(1)
  currentPage: int32;

  @example(10)
  pageSize: int32;

  @example(true)
  hasNextPage: boolean;
}

model UserSettings {
  @doc("The real name of the user.")
  username: string;

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

@tag("User")
namespace Settings {
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
