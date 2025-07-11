import "@typespec/http";
import "./group.tsp";
using Http;

@tag("Admin")
namespace Clustron.Admin {
  model CreateRoleRequest {
    @doc("The name of the role.")
    roleName: string;

    @doc("The access level of the role.")
    accessLevel: string;
  }

  @doc("get all mapping between group wise role and group wise access level")
  @route("/roles")
  @get
  op getRoleAccessLevelMapping(): {
    @statusCode statusCode: 200;
    @body roles: Clustron.Groups.Role[];
  } | {
    @statusCode statusCode: 403;
  };

  @doc("post new mapping between group wise role and group wise access level")
  @route("/roles")
  @post
  op postRoleAccessLevelMapping(@body body: CreateRoleRequest): {
    @statusCode statusCode: 200;
    @body roles: Clustron.Groups.Role[];
  } | {
    @statusCode statusCode: 403;
  } | {
    @statusCode statusCode: 400;
  };

  @doc("delete mapping between group wise role and group wise access level")
  @route("/roles/{id}")
  @delete
  op deleteRoleAccessLevelMapping(@path id: uuid): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 403;
  };

  @doc("update mapping between group wise role and group wise access level")
  @route("/roles/{id}")
  @put
  op putRoleAccessLevelMapping(@path id: uuid, @body body: CreateRoleRequest): {
    @statusCode statusCode: 200;
    @body roles: Clustron.Groups.Role[];
  } | {
    @statusCode statusCode: 403;
  } | {
    @statusCode statusCode: 400;
  };
}
