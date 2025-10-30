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
    @doc("Validation problem response model.")
    model ValidationProblem {
        @statusCode
        statusCode: 400;
    }
    // model ValidationProblem extends ErrorResponse {
    //     @statusCode
    //     statusCode: 400;

    //     Title: "Validation Problem";
    //     Status: 400;
    //     Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400";
    //     Detail: "One or more validation errors occurred.";
    // }

    @error
    model InvalidPageOrPageSizeProblem extends ErrorResponse {
        @statusCode
        statusCode: 400;

        Title: "Validation Problem";
        Status: 400;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400";
        Detail: "Invalid page or size.";
    }

    @error
    model InvalidSortingFieldProblem extends ErrorResponse {
        @statusCode
        statusCode: 400;

        Title: "Validation Problem";
        Status: 400;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400";
        Detail: "Invalid sorting field.";
    }

    @error
    model UnauthorizedProblem extends ErrorResponse {
        @statusCode
        statusCode: 401;

        Title: "Unauthorized";
        Status: 401;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401";
        Detail: "You must be logged in to access this resource.";
    }

    @error
    model ForbiddenProblem extends ErrorResponse {
        @statusCode
        statusCode: 403;

        Title: "Forbidden";
        Status: 403;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403";
        Detail: "Make sure you have the right permissions.";
    }

    @error
    model NotFoundProblem extends ErrorResponse {
        @statusCode
        statusCode: 404;

        Title: "Not Found";
        Status: 404;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404";
        Detail: "The requested resource was not found.";
    }

    @error
    model InternalServerProblem extends ErrorResponse {
        @statusCode
        statusCode: 500;

        Title: "Internal Server Error";
        Status: 500;
        Type: "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/500";
        Detail: "Internal server error.";
    }

    alias CommonErrorResponse =
        | ValidationProblem
        | UnauthorizedProblem
        | ForbiddenProblem
        | NotFoundProblem
        | InternalServerProblem;
}
