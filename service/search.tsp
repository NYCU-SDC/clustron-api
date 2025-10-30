import "@typespec/http";
using Http;

@tag("Search")
namespace Clustron.Search {
  model SearchUserResponse {
    @doc("student ID or email address")
    @example("R12345678")
    identifier: string;
  }

  @doc("Search for users by a query string with prefix search.")
  @route("/searchUser")
  @get
  op searchUser(
    @doc("The search query string used to match facts and references.")
    @query
    @example("ali")
    query: string,

    ...PaginatedParams,
  ): {
    @statusCode statusCode: 200;
    @body body: PaginatedResponse<SearchUserResponse>;
  };
}
