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
    @example("test-job")
    name: string;

    @example("My test job for experiments")
    comment?: string;

    @example("/home/<user>")
    current_working_directory: string;

    @example("#!/bin/bash\nhostname\necho a\n")
    script: string;

    @example(#[
      "HOME=/home/<user>",
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin",
      "SHELL=/bin/bash"
    ])
    environment: string[];

    @example("node[1-2]")
    nodes?: string;

    @example(1)
    minimum_nodes?: numeric;

    @example(2)
    maximum_nodes?: numeric;

    @example(4)
    tasks: numeric;

    @example(2)
    cpus_per_task: numeric;

    @example(4096)
    memory_per_cpu: numeric;

    @example(8192)
    memory_per_node: numeric;

    @example("debug")
    partition: string;

    @example(3600)
    time_limit: numeric;

    @example("/dev/null")
    standard_input?: string;

    @example("job.out")
    standard_output?: string;

    @example("job.err")
    standard_error?: string;
  }

  model JobResponse {
    @doc("The ID of the job.")
    @example(12345)
    id: numeric;

    @doc("The name of the job.")
    @example("test-job")
    name: string;

    @doc("The description of the job.")
    @example("My test job for experiments")
    comment: string;

    @doc("The status of the job.")
    @example("RUNNING")
    status: string;

    @doc("The computer user who created the job.")
    @example("alice")
    user: string;

    @doc("The partition the job belongs to.")
    @example("short")
    partition: string;

    @doc("The resources allocated for the job.")
    resources: {
      @example(8)
      cpu: numeric;

      @example(32768)
      memory: numeric;

      @example(0)
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
