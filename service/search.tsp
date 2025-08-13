import "@typespec/http";
using Http;

@tag("Search")
namespace Clustron.Search {
    model SearchUserResponse {
        identifier: string;
    }

    @route("/searchUser")
    @get
    op searchUser(
        @doc("The search query string used to match facts and references.")
        @query
        query: string,
        ...PaginatedParams,
    ): {
        @statusCode statusCode: 200;
        @body body: PaginatedResponse<SearchUserResponse>;
    };
}
