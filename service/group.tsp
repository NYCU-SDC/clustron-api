import "@typespec/http";
using Http;

@tag("Group")
namespace Clustron.Groups {
  enum AccessLevel {
    Organizer: "organizer",
    GroupAdmin: "groupAdmin",
    User: "user",
  }

  enum Role {
    Student: "student",
    Teacher: "teacher",
    TeacherAssistant: "teacherAssistant",
  }

  model MemberResponse {
    id: uuid;
    username: string;
    email: email;
    studentId: string;
    role: Role;
    accessLevel: AccessLevel;
  }

  model AddMemberRequest {
    @doc("The email or student id of the user.")
    member: email | string;

    @doc("The access level of the user.")
    role: Role;
  }

  model UpdateMemberRequest {
    id: uuid;

    @doc("The access level of the user.")
    role: Role;
  }

  model GroupResponse {
    id: uuid;
    title: string;
    description: string;
    isArchived: boolean;
    createdAt: string;
    updatedAt: string;
  }

  model CreateGroupRequest {
    title: string;
    description: string;
    members: AddMemberRequest[];
  }

  @doc("Get all groups of the user.")
  @route("/groups")
  @get
  op getGroups(...PaginatedParams): {
    @statusCode statusCode: 200;
    @body groups: PaginatedResponse<GroupResponse>;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Get a group by id.")
  @route("/groups/{id}")
  @get
  op getGroupById(id: string): {
    @statusCode statusCode: 200;
    @body group: GroupResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Get all members of a group.")
  @route("/groups/{id}/members")
  @get
  op getMembers(id: string, ...PaginatedParams): {
    @statusCode statusCode: 200;
    @body members: PaginatedResponse<MemberResponse>;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Create a new group.")
  @route("/groups")
  @post
  op createGroup(@body body: CreateGroupRequest): {
    @statusCode statusCode: 200;
    @body group: GroupResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Archive a group.")
  @route("/groups/{id}/archive")
  @post
  op archiveGroup(id: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Unarchive a group.")
  @route("/groups/{id}/unarchive")
  @post
  op unarchiveGroup(id: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Add a member to a group.")
  @route("/groups/{id}/members")
  @post
  op addMember(id: string, @body body: AddMemberRequest): {
    @statusCode statusCode: 200;
    @body member: MemberResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Remove a member from a group.")
  @route("/groups/{id}/members/{memberId}")
  @delete
  op removeMember(id: string, memberId: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Update a member's access level.")
  @route("/groups/{id}/members/{memberId}")
  @put
  op updateMember(
    id: string,
    memberId: string,
    @body body: UpdateMemberRequest,
  ): {
    @statusCode statusCode: 200;
    @body member: MemberResponse;
  } | {
    @statusCode statusCode: 404;
  };
}
