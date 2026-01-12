import "@typespec/http";
import "./group.tsp";
using Http;

@tag("Admin")
namespace Clustron.Admin {
  enum Role {
    Admin: "ADMIN", // super admin
    Organizer: "ORGANIZER", // can create group
    User: "USER", // normal user
  }

  model CreateRoleRequest {
    @doc("The name of the role.")
    @example("project-member")
    role: string;

    @doc("The access level of the role.")
    @example(Clustron.Groups.AccessLevel.User)
    accessLevel: Clustron.Groups.AccessLevel;
  }

  model UserResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    id: uuid;

    @example("Alice Chen")
    fullName: string;

    @example("alice@university.edu")
    email: email;

    @example("R12345678")
    studentId: string;

    @example(Role.User)
    @doc("The website role of the user.")
    role: Role;
  }

  model UpdateUserRoleRequest {
    @doc("The new role of the user.")
    @example(Role.Organizer)
    role: Role;
  }

  model SearchUserParams {
    @doc("Search term to filter users by name, email or student ID.")
    @example("alice")
    @query
    search?: string;

    @doc("Filter users by their global role.")
    @example(Role.Admin)
    @query
    role?: Role;
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
  } | Error.InvalidUuidFormatProblem;

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

  @doc("get all avaliable global roles")
  @route("/globalRoles")
  @get
  op getAllGlobalRoles(): {
    @statusCode statusCode: 200;
    @body roles: Role[];
  } | {
    @statusCode statusCode: 403;
  };

  model UserPaginatedParams {
    ...OmitProperties<PaginatedParams, "sortBy">;
    
    @query
    sortBy?: "fullName" | "email" | "studentID";
  }

  @doc("get all users")
  @route("/users")
  @get
  op getAllUsers(...UserPaginatedParams, ...SearchUserParams): {
    @statusCode statusCode: 200;
    @body users: PaginatedResponse<UserResponse>;
  } | {
    @statusCode statusCode: 403;
  };

  @doc("update a user's global role")
  @route("/users/{id}/globalRole")
  @put
  op updateUserRole(@path id: uuid, @body body: UpdateUserRoleRequest): {
    @statusCode statusCode: 200;
    @body user: UserResponse;
  } | {
    @statusCode statusCode: 403;
  } | Error.InvalidUuidFormatProblem;
}
