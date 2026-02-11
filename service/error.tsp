import "@typespec/http";
using Http;

@tag("Error")
namespace Clustron.Error {
  @doc("Generic error response model.")
  model ErrorResponse {
    @doc("A short, human-readable summary of the problem.")
    Title: string;

    @doc("The HTTP status code.")
    Status: int32;

    @doc("Reference link for status code.")
    Type: string;

    @doc("A detailed description of the error.")
    Detail: string;
  }

  @error
  @doc("Request body field validation failed.")
  model ValidationProblem {
    @statusCode
    statusCode: 400;
  }

  @error
  @doc("Invalid page, page size, or sorting field.")
  model InvalidPaginationParametersProblem {
    @statusCode
    statusCode: 400;
  }

  @error
  @doc("Invalid UUID format.")
  model InvalidUuidFormatProblem {
    @statusCode
    statusCode: 400;
  }

  @error
  @doc("No user are appended. Request failed.")
  model NoMemberAppendedProblem {
    @statusCode
    statusCode: 400;
  };
}
