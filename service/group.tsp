import "@typespec/http";
using Http;

@tag("Group")
namespace Clustron.Groups {
  enum AccessLevel {
    GroupOwner: "GROUP_OWNER",
    GroupAdmin: "GROUP_ADMIN",
    User: "USER",
  }

  model Role {
    id: uuid;
    roleName: string;
    accessLevel: AccessLevel;
  }

  model MemberResponse {
    id: uuid;
    fullName: string;
    email: email;
    studentId: string;
    role: Role;
  }

  model PendingMemberResponse {
    id: uuid;
    userIdentifier: string;
    role: Role;
  }

  model AddMembersRequest {
    members: AddMemberRequest[];
  }

  model AddMemberRequest {
    @doc("The email or student id of the user.")
    member: email | string;

    @doc("The role id of the member.")
    roleId: uuid;
  }

  model UpdateMemberRequest {
    @doc("The role id of the member.")
    roleId: uuid;
  }

  model GroupResponse {
    id: uuid;
    title: string;
    description: string;
    isArchived: boolean;
    createdAt: string;
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

  model AddMemberError {
    member: string;
    role: uuid;
    message: string;
  }

  model AddMembersResult {
    addedSuccessNumber: int32;
    addedFailureNumber: int32;
    errors: AddMemberError[];
  }

  model CreateGroupResponse extends GroupResponse {
    addedResult: AddMembersResult;
  }

  model CreateGroupRequest {
    title: string;
    description: string;
    members: AddMemberRequest[];
  }

  model TransferGroupOwnershipRequest {
    @doc("The new owner id in UUID format.")
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
  };

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
}
