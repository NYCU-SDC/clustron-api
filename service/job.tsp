import "@typespec/http";
using Http;

@tag("Job")
namespace Clustron.Job {
  model FilterParams {
    @example("status")
    @doc("The column to filter by.")
    @query
    filterBy?: string;

    @example("running")
    @doc("The value to filter by.")
    @query
    filterValue?: string;
  }

  @doc("View [detail design document](https://clustron.atlassian.net/wiki/spaces/cd/pages/60358660/Slurm+Job+API+design) for more information.")
  model JobRequest {
    name: string;
    comment?: string;
    current_working_directory: string;
    script: string;
    environment: string[];
    nodes: string;
    minimum_nodes: numeric;
    maximum_nodes: numeric;
    tasks: numeric;
    cpus_per_task: numeric;
    memory_per_cpu: numeric;
    memory_per_node: numeric;
    partition: string;
    time_limit: numeric;
    standard_input: string;
    standard_output: string;
    standard_error: string;
  }

  model JobResponse {
    @doc("The ID of the job.")
    id: numeric;

    @doc("The name of the job.")
    name: string;

    @doc("The description of the job.")
    comment: string;

    @doc("The status of the job.")
    status: string;

    @doc("The computer user who created the job.")
    user: string;

    @doc("The partition the job belongs to.")
    partition: string;

    @doc("The resources allocated for the job.")
    resources: {
      cpu: numeric;
      memory: numeric;
      gpu: numeric;
    };
  }

  @route("/jobs")
  @post
  op submitJob(
    @body
    job: JobRequest,
  ): {
    @statusCode statusCode: 201;
    @body response: JobResponse;
  } | {
    @statusCode statusCode: 400;
  };

  @route("/jobs")
  @get
  op listJobs(...PaginatedParams, ...FilterParams): {
    @statusCode statusCode: 200;
    @body response: PaginatedResponse<JobResponse>;
  } | {
    @statusCode statusCode: 404;
  } | Error.InvalidPaginationParametersProblem;

  @doc("Count jobs by status.")
  @route("/jobs/counts")
  @get
  op countJobs(
    @doc("The status of jobs to count. If not provided, counts all statuses.")
    @query
    status?:
      | "RUNNING"
      | "PENDING"
      | "COMPLETED"
      | "FAILED"
      | "TIMEOUT"
      | "CANCELLED",
  ): {
    @statusCode statusCode: 200;
    @body response: {
      running: numeric;
      pending: numeric;
      completed: numeric;
      failed: numeric;
      timeout: numeric;
      cancelled: numeric;
    };
  } | {
    @statusCode statusCode: 400;
  };

  @doc("Get available partitions.")
  @route("/partitions")
  op getPartitions(): {
    @statusCode statusCode: 200;
    @body response: {
      partitions: string[];
    };
  } | {
    @statusCode statusCode: 404;
  };
}
