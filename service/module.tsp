import "@typespec/http";
using Http;

@tag("Module")
namespace Clustron.Module {
    model CreateModuleRequest {
        title: string;

        @doc("the environment variables for the module")
        environment: {
            key: string;
            value: string;
        }[];
    }

    model ModuleResponse {
        id: string;
        title: string;

        @doc("the environment variables for the module")
        environment: {
            key: string;
            value: string;
        }[];
    }

    @doc("list the user's module")
    @route("/modules")
    @get
    op listModules(): {
        @statusCode statusCode: 200;
        @body response: ModuleResponse[];
    } | {
        @statusCode statusCode: 404;
    };

    @doc("get a module by id")
    @route("/modules/{id}")
    @get
    op getModule(id: string): {
        @statusCode statusCode: 200;
        @body response: ModuleResponse;
    } | {
        @statusCode statusCode: 404;
    };

    @doc("create module")
    @route("/modules")
    @post
    op createModule(@body request: CreateModuleRequest): {
        @statusCode statusCode: 201;
        @body response: ModuleResponse;
    } | {
        @statusCode statusCode: 400;
    };

    @doc("update module by id")
    @route("/modules/{id}")
    @put
    op updateModule(id: string, @body request: CreateModuleRequest): {
        @statusCode statusCode: 200;
        @body response: ModuleResponse;
    } | {
        @statusCode statusCode: 404;
    };

    @doc("delete module by id")
    @route("/modules/{id}")
    @delete
    op deleteModule(id: string): {
        @statusCode statusCode: 204;
    } | {
        @statusCode statusCode: 404;
    };
}
