import "@typespec/http";
import "@typespec/openapi3";

using Http;
using OpenAPI;

@tag("SystemGroup")
namespace Clustron.SystemGroup {
  @doc("Compute nodes on which a local group has a given gid.")
  model GidServers {
    @example(999)
    gidNumber: int64;

    @example(#["node01", "node02"])
    servers: string[];
  }

  @doc("A different local group that uses the candidate's gid on a compute node. Registering the candidate would grant this group there.")
  model GidConflict {
    @example("cpu01")
    server: string;

    @example("systemd-journal")
    name: string;

    @example(999)
    gidNumber: int64;
  }

  @doc("A server-local group discovered on active compute nodes. Denylisted groups and groups with gid 0 or gid >= 1000 are not listed.")
  model SystemGroupCandidate {
    @example("docker")
    @doc("Local group name, used as the LDAP cn when registered.")
    name: string;

    @example(true)
    @doc("True when every compute node that has the group uses the same gid.")
    consistent: boolean;

    @example(999)
    @doc("The gid. Present only when consistent is true.")
    gidNumber?: int64;

    @doc("Each gid the group has and the compute nodes using it.")
    gids: GidServers[];

    @example(#["cpu01"])
    @doc("Active compute nodes with discovery data that do not have this group.")
    missingServers: string[];

    @doc("Other local groups using one of this group's gids. Registration is refused while this is non-empty.")
    conflicts: GidConflict[];

    @example(false)
    @doc("True when the group is already registered as a system group.")
    registered: boolean;
  }

  model RegisterSystemGroupRequest {
    @example("docker")
    @doc("Name of a discovered local group. The backend resolves the gid.")
    @pattern("^[a-z_][a-z0-9_-]{0,31}$")
    @maxLength(32)
    name: string;

    @example("Docker access on GPU nodes")
    @maxLength(1024)
    description?: string;
  }

  model SystemGroupResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    id: uuid;

    @example("docker")
    name: string;

    @example(999)
    gidNumber: int64;

    @example("Docker access on GPU nodes")
    @doc("Empty string when no description was given.")
    description: string;

    createdAt: utcDateTime;
  }

  model AddSystemGroupMemberRequest {
    @example("123e4567-e89b-12d3-a456-426614174001")
    @doc("Clustron user ID. The user must have an LDAP account.")
    userId: uuid;
  }

  @doc("A Clustron user that Clustron added to the system group.")
  model SystemGroupMemberResponse {
    @example("123e4567-e89b-12d3-a456-426614174001")
    userId: uuid;

    @example("alice@example.com")
    email: email;

    @example("Alice Chen")
    fullName: string;

    addedAt: utcDateTime;
  }

  // --- Operations ---

  @doc("List registrable local groups discovered on active compute nodes.")
  @route("/systemGroups/candidates")
  @get
  op listSystemGroupCandidates(): {
    @statusCode statusCode: 200;
    @body response: SystemGroupCandidate[];
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Re-read /etc/group on every active compute node in the background. Candidates update when the Ansible run finishes.")
  @route("/systemGroups/discover")
  @post
  op discoverSystemGroups(): {
    @statusCode statusCode: 202;
  };

  @doc("List registered system groups.")
  @route("/systemGroups")
  @get
  op listSystemGroups(): {
    @statusCode statusCode: 200;
    @body response: SystemGroupResponse[];
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Register a discovered local group by name. The backend resolves its gid and creates an LDAP posixGroup with the same name and gid, so LDAP members receive the local group's gid on login.")
  @route("/systemGroups")
  @post
  op registerSystemGroup(@body req: RegisterSystemGroupRequest):
    | {
        @statusCode statusCode: 201;
        @body response: SystemGroupResponse;
      }
    | {
        @doc("Invalid request body or group name.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("The group is denylisted, or its gid is 0 or >= 1000.")
        @statusCode
        statusCode: 403;
      }
    | {
        @doc("The group was not discovered on any active compute node.")
        @statusCode
        statusCode: 404;
      }
    | {
        @doc("The gid differs across compute nodes, the gid is used by another local group, or the name or gid is already registered.")
        @statusCode
        statusCode: 409;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("Delete a system group and its LDAP group. Members lose the gid on their next login.")
  @route("/systemGroups/{id}")
  @delete
  op deleteSystemGroup(
    @doc("The system group UUID.")
    @path
    id: uuid,
  ):
    | {
        @statusCode statusCode: 204;
      }
    | {
        @doc("Invalid UUID.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("System group not found.")
        @statusCode
        statusCode: 404;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("List members Clustron added to the system group.")
  @route("/systemGroups/{id}/members")
  @get
  op listSystemGroupMembers(
    @doc("The system group UUID.")
    @path
    id: uuid,
  ):
    | {
        @statusCode statusCode: 200;
        @body response: SystemGroupMemberResponse[];
      }
    | {
        @doc("Invalid UUID.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("System group not found.")
        @statusCode
        statusCode: 404;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("Add a user to the system group by adding their LDAP uid to the group's memberUid. Takes effect on the user's next login.")
  @route("/systemGroups/{id}/members")
  @post
  op addSystemGroupMember(
    @doc("The system group UUID.")
    @path
    id: uuid,

    @body req: AddSystemGroupMemberRequest,
  ):
    | {
        @statusCode statusCode: 204;
      }
    | {
        @doc("Invalid UUID or body, or the user has no LDAP account.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("System group not found.")
        @statusCode
        statusCode: 404;
      }
    | {
        @doc("The user is already a member.")
        @statusCode
        statusCode: 409;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("Remove a user from the system group. A member whose LDAP account no longer exists is still removed.")
  @route("/systemGroups/{id}/members/{user_id}")
  @delete
  op removeSystemGroupMember(
    @doc("The system group UUID.")
    @path
    id: uuid,

    @doc("The Clustron user UUID.")
    @path
    user_id: uuid,
  ):
    | {
        @statusCode statusCode: 204;
      }
    | {
        @doc("Invalid UUID.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("System group not found, or the user is not a member.")
        @statusCode
        statusCode: 404;
      }
    | {
        @statusCode statusCode: 500;
      };
}
