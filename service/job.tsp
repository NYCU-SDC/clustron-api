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
    @get
    op listJobs(...PaginatedParams, ...FilterParams): {
        @statusCode statusCode: 200;
        @body response: PaginatedResponse<JobResponse>;
    } | {
        @statusCode statusCode: 404;
    };

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
}
