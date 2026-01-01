import "@typespec/http";
using Http;

@tag("Setup")
namespace Clustron.Setup {
    @doc("Indicate whether the system setup is complete.")
    model SetupStatus {
        progress: {
            @doc("Indicates whether there is at least one user in the system.")
            adminAccountCreated: boolean;
        }
    }

    @doc("Get the current setup status of the system. If any of the status is false, the system setup is not complete.")
    @route("/setup/status")
    @get
    op getSetupStatus(): {
        @statusCode statusCode: 200;
        @body body: SetupStatus;
    };
}