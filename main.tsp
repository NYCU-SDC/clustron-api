import "@typespec/http";
import "@typespec/versioning";
import "./service/user.tsp";
import "./service/auth.tsp";

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
