import "@typespec/http";
using Http;

@tag("Files")
namespace Clustron.Files {
  model UploadFileResponse {
    @doc("The ID of the file.")
    @example("550e8400-e29b-41d4-a716-446655440000")
    id: uuid;

    @doc("The name of the file.")
    @example("design.bit")
    filename: string;

    @doc("The size of the file in bytes.")
    @example(1048576)
    size: int64;
  }

  @doc("Upload a file to the backend server.")
  @route("/files")
  @post
  op uploadFile(
    @header("Content-Type") contentType: "multipart/form-data",
    @multipartBody body: {
      file: HttpPart<File>;
    },
  ): {
    @statusCode statusCode: 201;
    @body response: UploadFileResponse;
  } | {
    @statusCode statusCode: 400;
  } | {
    @statusCode statusCode: 500;
  };
}
