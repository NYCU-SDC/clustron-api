import "@typespec/http";
import "@typespec/openapi3";

using Http;
using OpenAPI;

@tag("Ansible")
namespace Clustron.Ansible {
  @doc("The deployment status of the server node.")
  enum ServerStatus {
    Unset: "unset",
    Provisioning: "provisioning",
    Active: "active",
    Failed: "failed",
  }

  @doc("The group type of an allowed login group.")
  enum GroupType {
    Admin: "ADMIN",
    Base: "BASE",
  }

  @doc("The supported Ansible roles for cluster nodes based on the playbook.")
  enum AnsibleRole {
    @doc("The head node of the cluster (NFS, LDAP, Slurm controller).")
    HeadNodes: "head_nodes",

    @doc("A standard compute node for running jobs.")
    ComputeNodes: "compute_nodes",
  }

  model AddNodeCommonRequest {
    @example("node-01")
    @doc("The Ansible hostname of the node.")
    @minLength(1)
    @maxLength(253)
    ansible_name: string;

    @example("cluster.key")
    @doc("The name of the SSH key to use for connection.")
    @maxLength(255)
    ssh_key_name?: string;

    @example(AnsibleRole.ComputeNodes)
    @doc("The Ansible role assigned to this node.")
    ansible_role: AnsibleRole;

    @example("batch")
    @doc("The Slurm partition this node belongs to.")
    @maxLength(255)
    slurm_partition?: string;

    @example(32)
    @doc("Number of CPU cores.")
    @minValue(1)
    cpu_cores?: int32;

    @example(131072)
    @doc("Amount of memory in MB.")
    @minValue(1)
    memory_mb?: int32;
  }

  @doc("A node connected directly by IP address.")
  model DirectIpAddNodeRequest extends AddNodeCommonRequest {
    @example("192.168.1.100")
    @doc("The IP address used to connect to the node.")
    ip_address: string;

    @example("ubuntu")
    @doc("The SSH user used to connect to the node.")
    @minLength(1)
    @maxLength(255)
    ssh_user: string;

    @example("my-cluster-node-1")
    @doc("An optional SSH config host alias.")
    @maxLength(255)
    ssh_config_host?: string;

    @example("10.0.0.5")
    @doc("An optional private IP address used for internal cluster traffic.")
    private_ip?: string;
  }

  @doc("A node connected through an SSH config host alias.")
  model SshConfigAddNodeRequest extends AddNodeCommonRequest {
    @example("my-cluster-node-1")
    @doc("The SSH config host alias used to connect to the node.")
    @minLength(1)
    @maxLength(255)
    ssh_config_host: string;

    @example("10.0.0.5")
    @doc("The private IP address used for internal cluster traffic.")
    private_ip: string;

    @example("ubuntu")
    @doc("An optional SSH user override.")
    @minLength(1)
    @maxLength(255)
    ssh_user?: string;
  }

  @oneOf
  @doc("A node using either a direct IP connection or an SSH config host.")
  union AddNodeRequest {
    directIp: DirectIpAddNodeRequest,
    sshConfig: SshConfigAddNodeRequest,
  }

  model AddNodesRequest {
    @doc("Servers to add in one transaction.")
    @minItems(1)
    @maxItems(50)
    servers: AddNodeRequest[];
  }

  model ServerResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The unique identifier of the server.")
    id: uuid;

    @example("node-01")
    @doc("The Ansible hostname of the node.")
    @pattern("^([a-zA-Z0-9]{1}[a-zA-Z0-9-]{0,62})(\\.[a-zA-Z0-9]{1}[a-zA-Z0-9-]{0,62})*?$")
    ansible_name: string;

    @example("192.168.1.100")
    ip_address?: string;

    @example("my-cluster-node-1")
    ssh_config_host?: string;

    @example("10.0.0.5")
    private_ip?: string;

    @example("ubuntu")
    ssh_user?: string;

    @example("cluster-key")
    ssh_key_name?: string;

    @example(AnsibleRole.ComputeNodes)
    @doc("The Ansible role assigned to this node.")
    ansible_role: AnsibleRole;

    @example("batch")
    slurm_partition?: string;

    @example(ServerStatus.Failed)
    @doc("The current status of the server. Will be 'provisioning' during Ansible execution.")
    status: ServerStatus;

    @example("Stage: Install Slurm\nError: connection timeout")
    @doc("Detailed information about the last provisioning task or error summary.")
    provision_detail?: string;

    @example(32)
    @minValue(1)
    cpu_cores?: int32;

    @example(131072)
    @minValue(1)
    memory_mb?: int32;
  }

  model AddNodesResponse {
    servers: ServerResponse[];
  }

  model UpdateRoleRequest {
    @example(AnsibleRole.ComputeNodes)
    @doc("The new Ansible role to assign.")
    ansible_role: AnsibleRole;
  }

  model AllowedLoginGroupParams {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The ID of the group allowed to log in to this server.")
    groupId: string;

    @example(GroupType.Admin)
    @doc("Type of the group.")
    groupType: GroupType;
  }

  model UpdateAllowedLoginGroupsRequest {
    @doc("Groups allowed to log in to this server. An empty array clears the list.")
    allowedLoginGroups: AllowedLoginGroupParams[];
  }

  model AllowedLoginGroupResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The unique identifier of the LDAP group (ldap_groups.id).")
    ldapGroupId: uuid;

    @example("Administrators")
    @doc("The display title of the group.")
    title: string;

    @example("research-base")
    @doc("The LDAP Common Name (ldap_groups.ldap_cn) written to SSSD simple_allow_groups.")
    ldapCn: string;
  }

  // --- Operations ---

  @doc("List all managed servers.")
  @route("/servers")
  @get
  op listServers(): {
    @statusCode statusCode: 200;
    @body response: ServerResponse[];
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Add a new node to the cluster. This is an asynchronous operation. The node status will initially be 'provisioning'. Poll the server status to see when it becomes 'active' or 'failed'.")
  @route("/servers")
  @post
  op addNode(@body req: AddNodeRequest): {
    @statusCode statusCode: 201;
    @body response: ServerResponse;
  } | {
    @statusCode statusCode: 400;
  };

  @doc("Trigger the setup process for all nodes. This is an asynchronous operation running cluster-wide.")
  @route("/servers/setup")
  @post
  op setupAllNodes(): {
    @statusCode statusCode: 204;
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Get the list of LDAP groups allowed to log in to a server.")
  @route("/servers/{server_id}/allowedLoginGroups")
  @get
  op getAllowedLoginGroups(
    @doc("The target server UUID.")
    @path
    server_id: uuid,
  ):
    | {
        @statusCode statusCode: 200;
        @body response: AllowedLoginGroupResponse[];
      }
    | {
        @statusCode statusCode: 400;
      }
    | {
        @statusCode statusCode: 404;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("Update the allowed LDAP groups for a specific server using ldap_groups.id values. Head nodes cannot have an allowed group list.")
  @route("/servers/{server_id}/allowedLoginGroups")
  @put
  op updateAllowedLoginGroups(
    @doc("The target server UUID.")
    @path
    server_id: uuid,

    @body req: UpdateAllowedLoginGroupsRequest,
  ):
    | {
        @statusCode statusCode: 204;
      }
    | {
        @doc("UUID or request body is in the wrong format.")
        @statusCode
        statusCode: 400;
      }
    | {
        @doc("Server or LDAP group not found.")
        @statusCode
        statusCode: 404;
      }
    | {
        @doc("Set simple allowed group for head node.")
        @statusCode
        statusCode: 422;
      };

  @doc("Get a specific server by its ID.")
  @route("/servers/{server_id}")
  @get
  op getServerById(
    @doc("The UUID of the server to retrieve.")
    @path
    server_id: uuid,
  ): {
    @statusCode statusCode: 200;
    @body response: ServerResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Delete a server from the cluster.")
  @route("/servers/{server_id}")
  @delete
  op deleteServer(
    @doc("The UUID of the server to delete.")
    @path
    server_id: uuid,
  ): {
    @statusCode statusCode: 204;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Add 1–50 nodes in one transaction. Provisioning starts asynchronously after all records are created.")
  @route("/servers/batch")
  @post
  op addNodes(@body req: AddNodesRequest): {
    @statusCode statusCode: 201;
    @body response: AddNodesResponse;
  } | {
    @statusCode statusCode: 400;
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Reset a specific node's configuration/status. Triggers a background Ansible run and resets status to 'provisioning'.")
  @route("/servers/{server_id}/reset")
  @post
  op resetNode(
    @doc("The UUID of the server to reset.")
    @path
    server_id: uuid,
  ): {
    @statusCode statusCode: 200;
    @body response: ServerResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @doc("Update the Ansible role of a specific server. This triggers a background Ansible run. Status will be reset to 'provisioning'.")
  @route("/servers/{server_id}/role")
  @patch
  op updateRole(
    @doc("The UUID of the server.")
    @path
    server_id: uuid,

    @body req: UpdateRoleRequest,
  ): {
    @statusCode statusCode: 200;
    @body response: ServerResponse;
  } | {
    @statusCode statusCode: 400;
  } | {
    @statusCode statusCode: 404;
  };
}
