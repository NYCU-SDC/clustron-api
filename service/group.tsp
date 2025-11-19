import "@typespec/http";
import "./error.tsp";
using Http;

@tag("Group")
namespace Clustron.Groups {
  enum AccessLevel {
    GroupOwner: "GROUP_OWNER",
    GroupAdmin: "GROUP_ADMIN",
    User: "USER",
  }

  model Role {
    @example("123e4567-e89b-12d3-a456-426614174000")
    id: uuid;

    @example("Member")
    roleName: string;

    @example(AccessLevel.User)
    accessLevel: AccessLevel;
  }

  model MemberResponse {
    @example("123e4567-e89b-12d3-a456-426614174001")
    id: uuid;

    @example("Alice Chen")
    fullName: string;

    @example("alice@university.edu")
    email: email;

    @example("R12345678")
    studentId: string;

    @example(#{
      id: "123e4567-e89b-12d3-a456-426614174000",
      roleName: "Member",
      accessLevel: AccessLevel.User,
    })
    role: Role;
  }

  model PendingMemberResponse {
    @example("123e4567-e89b-12d3-a456-426614174002")
    id: uuid;

    @example("applicant@example.edu")
    userIdentifier: string;

    @example(#{
      id: "123e4567-e89b-12d3-a456-426614174000",
      roleName: "Member",
      accessLevel: AccessLevel.User,
    })
    role: Role;
  }

  model AddMembersRequest {
    members: AddMemberRequest[];
  }

  model AddMemberRequest {
    @doc("The email or student id of the user.")
    @example("bob@university.edu")
    member: email | string;

    @doc("The role id of the member.")
    @example("123e4567-e89b-12d3-a456-426614174000")
    roleId: uuid;
  }

  model UpdateMemberRequest {
    @doc("The role id of the member.")
    @example("123e4567-e89b-12d3-a456-426614174000")
    roleId: uuid;
  }

  model LinkResponse {
    @doc("The ID of the link.")
    @example("123e4567-e89b-12d3-a456-426614174010")
    id: uuid;

    @doc("The title of the link.")
    @example("Lab Resources")
    title: string;

    @doc("The URL of the link.")
    @example("https://wiki.university.edu/lab-resources")
    url: string;
  }

  model CreateLinkRequest {
    @doc("The title of the link.")
    @example("Lab Resources")
    title: string;

    @doc("The URL of the link.")
    @example("https://example.com")
    url: string;
  }

  model UpdateLinkRequest {
    @doc("The title of the link.")
    @example("Updated Lab Resources")
    title: string;

    @doc("The URL of the link.")
    @example("https://example.com")
    url: string;
  }

  model GroupResponse {
    @example("123e4567-e89b-12d3-a456-426614174100")
    id: uuid;

    @example("GPU Research Group")
    title: string;

    @example("Group for GPU research and experiments.")
    description: string;

    @example(false)
    isArchived: boolean;

    @example("2024-01-01T12:00:00Z")
    createdAt: string;

    @example("2024-10-01T12:00:00Z")
    updatedAt: string;

    me: {
      @doc("The user is a member of the group.")
      type: "membership";

      role: Role;
    } | {
      @doc("The admin user is not a member of the group.")
      type: "adminOverride";
    };
  }

  model GroupResponseWithLinks extends GroupResponse {
    @example(#[
      #{
        id: "123e4567-e89b-12d3-a456-426614174010",
        title: "Lab Resources",
        url: "https://wiki.university.edu/lab-resources",
      }
    ])
    links: LinkResponse[];
  }

  model AddMemberError {
    @example("bob@university.edu")
    member: string;

    @example("123e4567-e89b-12d3-a456-426614174000")
    role: uuid;

    @example("User not found")
    message: string;
  }

  model AddMembersResult {
    @example(3)
    addedSuccessNumber: int32;

    @example(1)
    addedFailureNumber: int32;

    @example(#[
      #{
        member: "bob@university.edu",
        role: "123e4567-e89b-12d3-a456-426614174000",
        message: "User not found",
      }
    ])
    errors: AddMemberError[];
  }

  model CreateGroupResponse extends GroupResponse {
    @example(#{ addedSuccessNumber: 2, addedFailureNumber: 0, errors: #[] })
    addedResult: AddMembersResult;
  }

  model CreateGroupRequest {
    @example("Distributed Systems Project")
    title: string;

    @example("Group for the distributed systems course project.")
    description: string;

    @example(#[
      #{
        member: "alice@university.edu",
        roleId: "123e4567-e89b-12d3-a456-426614174000",
      }
    ])
    members?: AddMemberRequest[];

    @example(#[#{ title: "Lab Resources", url: "https://example.com" }])
    links?: CreateLinkRequest[];
  }

  model TransferGroupOwnershipRequest {
    @doc("The new owner id in UUID format.")
    @example("123e4567-e89b-12d3-a456-426614174200")
    identifier: string;
  }

  @doc("Get all groups of the user.")
  @route("/groups")
  @get
  op getGroups(...PaginatedParams): {
    @statusCode statusCode: 200;
    @body groups: PaginatedResponse<GroupResponse>;
  } | {
    @statusCode statusCode: 404;
  } | Error.InvalidPaginationParametersProblem;

  @doc("Get a group by id.")
  @route("/groups/{id}")
  @get
  op getGroupById(id: string): {
    @statusCode statusCode: 200;
    @body group: GroupResponseWithLinks;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Get all members of a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/members")
  @get
  op getMembers(id: string, ...PaginatedParams): {
    @statusCode statusCode: 200;
    @body members: PaginatedResponse<MemberResponse>;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Create a new group. Only admin level can reach this endpoint.")
  @route("/groups")
  @post
  op createGroup(@body body: CreateGroupRequest): {
    @statusCode statusCode: 200;
    @body group: CreateGroupResponse;
  } | {
    @statusCode statusCode: 404;
  } | Error.ValidationProblem;

  @doc("Archive a group. Will reject the request from access level 'user', 'group-admin'.")
  @route("/groups/{id}/archive")
  @post
  op archiveGroup(id: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Unarchive a group. Will reject the request from access level 'user', 'group-admin'.")
  @route("/groups/{id}/unarchive")
  @post
  op unarchiveGroup(id: string): {
    @statusCode statusCode: 200;
    @body group: GroupResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Add a member to a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/members")
  @post
  op addMember(id: string, @body body: AddMembersRequest): {
    @statusCode statusCode: 200;
    @body member: MemberResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Remove a member from a group. Will reject the request from access level 'user'")
  @route("/groups/{id}/members/{memberId}")
  @delete
  op removeMember(id: string, memberId: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Update a member's access level.  Will reject the request from access level 'user'")
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

  @doc("Transfer group ownership to another member. Will reject the request from access level 'user'")
  @route("/groups/{id}/transfer")
  @post
  op transferGroupOwnership(
    id: string,
    @body body: TransferGroupOwnershipRequest,
  ): {
    @statusCode statusCode: 200;
    @body group: GroupResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Get all pending members of a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/pendingMembers")
  @get
  op getPendingMembers(id: string, ...PaginatedParams): {
    @statusCode statusCode: 200;
    @body pendingMembers: PaginatedResponse<PendingMemberResponse>;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Update a pending member's access level.  Will reject the request from access level 'user'")
  @route("/groups/{id}/pendingMembers/{pendingId}")
  @put
  op updatePendingMember(
    id: string,
    pendingId: string,
    @body body: UpdateMemberRequest,
  ): {
    @statusCode statusCode: 200;
    @body pendingMember: PendingMemberResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Remove a pending member from a group. Will reject the request from access level 'user'")
  @route("/groups/{id}/pendingMembers/{pendingId}")
  @delete
  op removePendingMember(id: string, pendingId: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Create a link for a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/link")
  @post
  op createGroupLink(id: string, @body body: CreateLinkRequest): {
    @statusCode statusCode: 200;
    @body link: LinkResponse;
  } | {
    @statusCode statusCode: 400;
  };

  @doc("Update a link for a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/link/{linkId}")
  @put
  op updateGroupLink(
    id: string,
    linkId: string,
    @body body: UpdateLinkRequest,
  ): {
    @statusCode statusCode: 200;
    @body link: LinkResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Delete a link for a group. Will reject the request from access level 'user'.")
  @route("/groups/{id}/link/{linkId}")
  @delete
  op deleteGroupLink(id: string, linkId: string): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  };
}
