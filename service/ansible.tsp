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

    @example("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID...")
    @doc("""
      The trusted SSH host key (authorized-key form) to pin for this node, as returned by a prior
      successful health check. Rendered into the Ansible known_hosts so the deploy verifies the
      host instead of blocking on a first-connect prompt.
      """)
    @maxLength(1024)
    host_key?: string;

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

    @doc("Per-node feature toggles. Both features are enabled when the object or an individual field is omitted, so existing clients keep the current behaviour. Features can only be disabled on compute nodes, and are set only at creation time.")
    features?: RequestFeatures;
  }

  @doc("Per-node feature toggles. Every field defaults to true.")
  model RequestFeatures {
    @example(true)
    @doc("Whether to install Slurm on this node. When false, /opt/clustron_share and /etc/slurm are not mounted and the node is excluded from slurm.conf.")
    slurm?: boolean = true;

    @example(true)
    @doc("Whether to mount /home from the head node over NFS. When false, home directories are created on the node's local disk.")
    nfs_home?: boolean = true;
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

  @doc("The trust state of a scanned SSH host key.")
  enum HostKeyStatus {
    @doc("No trusted key was supplied; the client must confirm the returned fingerprint.")
    New: "new",

    @doc("A trusted key was supplied but the live host key differs; ask the user to re-trust.")
    Changed: "changed",

    @doc("The live host key matches the supplied trusted key.")
    Ok: "ok",

    @doc("Host key handled by Ansible/OpenSSH (ssh_config_host alias path); not scanned in Go.")
    Skipped: "skipped",
  }

  @doc("Direct-IP connection details to health-check before a node is created.")
  model DirectIpHealthCheckRequest {
    @example("node-01")
    @maxLength(253)
    ansible_name: string;

    @example("192.168.1.100")
    @doc("The IP address used to connect to the node.")
    ip_address: string;

    @example("ubuntu")
    @minLength(1)
    @maxLength(255)
    ssh_user: string;

    @example("cluster.key")
    @maxLength(255)
    ssh_key_name?: string;

    @example("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID...")
    @doc("""
      The host key the client has chosen to trust (authorized-key form). Omit on the first call:
      the backend scans the live key and returns it with host_key_status 'new' for confirmation.
      Send it back on the follow-up call to proceed through login and the Ansible ping.
      """)
    @maxLength(1024)
    trusted_host_key?: string;
  }

  @doc("SSH-config-alias connection details to health-check before a node is created.")
  model SshConfigHealthCheckRequest {
    @example("node-01")
    @maxLength(253)
    ansible_name: string;

    @example("my-cluster-node-1")
    @minLength(1)
    @maxLength(255)
    ssh_config_host: string;

    @example("ubuntu")
    @minLength(1)
    @maxLength(255)
    ssh_user?: string;

    @example("cluster.key")
    @maxLength(255)
    ssh_key_name?: string;
  }

  @oneOf
  @doc("A health-check target using either a direct IP connection or an SSH config host alias.")
  union HealthCheckRequest {
    directIp: DirectIpHealthCheckRequest,
    sshConfig: SshConfigHealthCheckRequest,
  }

  @doc("""
    The outcome of a connection health check. `ok` is true only when every applicable stage
    passed. When `host_key_status` is 'new' or 'changed', `ok` is false and the client should
    show the `fingerprint` for the user to trust, then retry with `trusted_host_key` set to
    `host_key`.
    """)
  model HealthCheckResponse {
    @example(false)
    @doc("Whether the whole check passed.")
    ok: boolean;

    @example("host_key")
    @doc("The stage reached: reachable, host_key, login, ansible_ping, or done.")
    stage: string;

    @example(true)
    @doc("Whether the host accepted a TCP connection on SSH (direct-IP path).")
    reachable: boolean;

    @example("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID...")
    @doc("The live host key in authorized-key form (direct-IP path).")
    host_key?: string;

    @example("SHA256:abc123...")
    @doc("SHA256 fingerprint of the host key, for the user to confirm.")
    fingerprint?: string;

    @doc("The trust state of the scanned host key.")
    host_key_status: HostKeyStatus;

    @example(false)
    @doc("Whether the provided identity logged in successfully (direct-IP path).")
    login_ok: boolean;

    @example(false)
    @doc("Whether `ansible -m ping -b` succeeded (usable Python interpreter and become/sudo).")
    ansible_ping_ok: boolean;

    @example("login as \"ubuntu\" failed: ssh: unable to authenticate")
    @doc("Human-readable detail about a failed or incomplete stage.")
    detail?: string;
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

    @example("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID...")
    @doc("The pinned SSH host key (authorized-key form) used to verify this node during deploys.")
    host_key?: string;

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

    @doc("The resolved feature toggles of this node. Always present.")
    features: ResponseFeatures;
  }

  @doc("The resolved per-node feature toggles.")
  model ResponseFeatures {
    @example(true)
    @doc("Whether Slurm is installed on this node.")
    slurm: boolean;

    @example(true)
    @doc("Whether /home is mounted from the head node over NFS.")
    nfs_home: boolean;
  }

  model AddNodesResponse {
    servers: ServerResponse[];
  }

  model UpdateRoleRequest {
    @example(AnsibleRole.ComputeNodes)
    @doc("The new Ansible role to assign.")
    ansible_role: AnsibleRole;
  }

  @doc("Groups allowed to log in to this server. An empty array clears the list.")
  model UpdateAllowedLoginGroupParams {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The ID of the group allowed to log in to this server.")
    groupId: string;

    @example(GroupType.Admin)
    @doc("Type of the group.")
    groupType: GroupType;
  }

  @doc("Short representation of an LDAP group.")
  model LdapGroupSummaryResponse {
    @example("123e4567-e89b-12d3-a456-426614174000")
    @doc("The group ID.")
    groupId: uuid;

    @example(GroupType.Admin)
    @doc("allowed login group type.")
    type: GroupType;

    @example("Administrators")
    @doc("The display title of the group.")
    title: string;

    @example("research")
    @doc("The LDAP Common Name (ldap_groups.ldap_cn) written to SSSD simple_allow_groups or Slurm AllowGroups.")
    ldapCn: string;
  }

  @doc("Group IDs allowed to submit jobs to a partition. An empty array closes the partition: no group may submit jobs to it.")
  model UpdatePartitionAllowedGroupsRequest {
    @doc("The IDs of the LDAP groups (ldap_groups.id) allowed to submit jobs to this partition.")
    ldapGroupIds: uuid[];
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
  } | {
    @doc("A feature in `features` is false while `ansible_role` is not `compute_nodes`: slurm and nfs home can only be disabled on compute nodes.")
    @statusCode
    statusCode: 422;
  };

  @doc("""
    Validate a node's SSH connection before it is created: reachability, host-key trust, key
    login, and an `ansible -m ping -b` check. No server row is created. Runs synchronously and
    returns 200 with the per-stage outcome. On an unknown or changed host key it returns
    ok=false with the scanned fingerprint; the client confirms, then retries with
    `trusted_host_key` set. Direct-IP targets get the full check; ssh_config_host aliases are
    validated by the Ansible ping only (host_key_status 'skipped').
    """)
  @route("/servers/healthCheck")
  @post
  op healthCheckNode(@body req: HealthCheckRequest): {
    @statusCode statusCode: 200;
    @body response: HealthCheckResponse;
  } | {
    @statusCode statusCode: 400;
  };

  @doc("Trigger the setup process for all nodes. This is an asynchronous operation running cluster-wide. A legacy NFS mount of the whole /opt is unmounted automatically; only /opt/clustron_share is shared.")
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
        @body response: LdapGroupSummaryResponse[];
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

    @body req: UpdateAllowedLoginGroupParams[],
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

  @doc("Get the groups allowed to submit jobs to a Slurm partition. An empty array means no group may submit jobs to it.")
  @route("/partitions/{partition_name}/allowedGroups")
  @get
  op getPartitionAllowedGroups(
    @doc("The name of the Slurm partition.")
    @path
    partition_name: string,
  ): {
    @statusCode statusCode: 200;
    @body response: LdapGroupSummaryResponse[];
  } | {
    @statusCode statusCode: 500;
  };

  @doc("Replace the groups allowed to submit jobs to a Slurm partition. The array is the complete new allow list; an empty array closes the partition to every group.")
  @route("/partitions/{partition_name}/allowedGroups")
  @put
  op updatePartitionAllowedGroups(
    @doc("The name of the Slurm partition.")
    @path
    partition_name: string,

    @body req: UpdatePartitionAllowedGroupsRequest,
  ): {
    @statusCode statusCode: 204;
  } | {
    @doc("Request body is in the wrong format.")
    @statusCode
    statusCode: 400;
  } | {
    @doc("Partition or one or more LDAP groups not found.")
    @statusCode
    statusCode: 404;
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
  op addNodes(@body req: AddNodesRequest):
    | {
        @statusCode statusCode: 201;
        @body response: AddNodesResponse;
      }
    | {
        @statusCode statusCode: 400;
      }
    | {
        @doc("A feature in `features` is false while `ansible_role` is not `compute_nodes`: slurm and nfs home can only be disabled on compute nodes. Every server is validated before any is written; if one fails, none are created.")
        @statusCode
        statusCode: 422;
      }
    | {
        @statusCode statusCode: 500;
      };

  @doc("Reset a specific node's configuration/status. Triggers a background Ansible run and resets status to 'provisioning'. A legacy NFS mount of the whole /opt is unmounted automatically; only /opt/clustron_share is shared.")
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
  ):
    | {
        @statusCode statusCode: 200;
        @body response: ServerResponse;
      }
    | {
        @statusCode statusCode: 400;
      }
    | {
        @statusCode statusCode: 404;
      }
    | {
        @doc("A server with a feature in `features` disabled cannot become a head node.")
        @statusCode
        statusCode: 409;
      };
}
