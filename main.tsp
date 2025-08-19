import "@typespec/http";
import "@typespec/versioning";
import "./service/group.tsp";
import "./service/user.tsp";
import "./service/auth.tsp";
import "./service/admin.tsp";
import "./service/job.tsp";
import "./service/search.tsp";

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
