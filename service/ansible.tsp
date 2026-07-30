import "@typespec/http";

using Http;

@tag("Ansible")
namespace Clustron.Ansible {
  @doc("The deployment status of the server node.")
  enum ServerStatus {
    Unset: "unset",
    Provisioning: "provisioning",
    Active: "active",
    Failed: "failed",
  }

  @doc("The supported Ansible roles for cluster nodes based on the playbook.")
  enum AnsibleRole {
    @doc("The head node of the cluster (NFS, LDAP, Slurm controller).")
    HeadNodes: "head_nodes",

    @doc("A standard compute node for running jobs.")
    ComputeNodes: "compute_nodes",
  }

  model AddNodeRequest {
    @example("node-01")
    @doc("The Ansible hostname of the node.")
    @minLength(1)
    ansible_name: string;

    @example("192.168.1.100")
    @doc("The IP address to connect to. Required if ssh_config_host is not provided.")
    ip_address?: string;

    @example("my-cluster-node-1")
    @doc("The SSH config host alias. Required if ip_address is not provided.")
    ssh_config_host?: string;

    @example("10.0.0.5")
    @doc("The private IP address of the node.")
    private_ip?: string;

    @example("ubuntu")
    @doc("The SSH user to connect as.")
    @minLength(1)
    ssh_user: string;

    @example("cluster-key")
    @doc("The name of the SSH key to use for connection.")
    ssh_key_name?: string;

    @example(AnsibleRole.ComputeNodes)
    @doc("The Ansible role assigned to this node.")
    ansible_role: AnsibleRole;

    @example("batch")
    @doc("The Slurm partition this node belongs to.")
    slurm_partition?: string;

    @example(32)
    @doc("Number of CPU cores.")
    cpu_cores?: int32;

    @example(131072)
    @doc("Amount of memory in MB.")
    memory_mb?: int32;
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
    ansible_name: string;

    @example("192.168.1.100")
    ip_address?: string;

    @example("my-cluster-node-1")
    ssh_config_host?: string;

    @example("10.0.0.5")
    private_ip?: string;

    @example("ubuntu")
    ssh_user: string;

    @example("cluster-key")
    ssh_key_name?: string;

    @example(AnsibleRole.ComputeNodes)
    @doc("The Ansible role assigned to this node.")
    ansible_role: AnsibleRole;

    @example("batch")
    slurm_partition?: string;

    @example(ServerStatus.Provisioning)
    @doc("The current status of the server. Will be 'provisioning' during Ansible execution.")
    status: ServerStatus;

    @example("Stage: Install Slurm\nError: connection timeout")
    @doc("Detailed information about the last provisioning task or error summary.")
    provision_detail?: string;

    @example(32)
    cpu_cores?: int32;

    @example(131072)
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

  model UpdateAllowedLoginGroupsRequest {
    @example(#[
      "123e4567-e89b-12d3-a456-426614174000",
      "987fcdeb-51a2-43d7-9012-345678901234"
    ])
    @doc("List of group UUIDs allowed to log in.")
    groupIds: uuid[];
  }

  model AllowedLoginGroupResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The unique identifier of the group.")
    groupId: uuid;

    @example("Administrators")
    @doc("The display title of the group.")
    title: string;

    @example("cn=admins,ou=groups,dc=example,dc=com")
    @doc("The LDAP Common Name associated with the group.")
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

  @doc("Get the list of groups allowed to log in to servers.")
  @route("/servers/allowedLoginGroups")
  @get
  op getAllowedLoginGroups(): {
    @statusCode statusCode: 200;
    @body response: AllowedLoginGroupResponse[];
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Update the list of groups allowed to log in. Fails if a group lacks a base LDAP group. Triggers a background job to re-render sssd.conf on all nodes.")
  @route("/servers/allowedLoginGroups")
  @put
  op updateAllowedLoginGroups(@body req: UpdateAllowedLoginGroupsRequest): {
    @statusCode statusCode: 204;
  } | {
    @statusCode statusCode: 400;
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
