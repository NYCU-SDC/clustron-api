import "@typespec/http";

using Http;

@tag("User")
namespace Clustron.User {
  model Settings {
    @doc("The real name of the user.")
    @example("Alice Chen")
    fullName: string;

    @doc("The computer account name of the user.")
    @example("alice")
    linuxUsername: string;
  }

  model LoginMethod {
    @doc("The oauth provider of this login method.")
    @example("GOOGLE")
    provider: "GOOGLE" | "NYCU";

    @doc("The email of this oauth login method.")
    @example("alice@university.edu")
    email: string;
  }

  model SettingsResponse {
    @doc("The real name of the user.")
    @example("Alice Chen")
    fullName: string;

    @doc("The computer account name of the user.")
    @example("alice")
    linuxUsername: string;

    @doc("The login methods of the user.")
    @example(#[#{ provider: "GOOGLE", email: "alice@university.edu" }])
    boundLoginMethods: LoginMethod[];
  }

  model PublicKey {
    @doc("The public key id in UUID format.")
    @example("123e4567-e89b-12d3-a456-426614174300")
    id: string;

    @doc("The public key title set by the user.")
    @example("workstation-key")
    title: string;

    @doc("The public key of the user.")
    @example("ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3...")
    publicKey: string;
  }

  model AddPublicKeyRequest {
    @doc("The public key title set by the user.")
    @example("workstation-key")
    title: string;

    @doc("The public key of the user.")
    @example("ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3...")
    publicKey: string;
  }

  model DeletePublicKeyRequest {
    @doc("The public key id in UUID format.")
    @example("123e4567-e89b-12d3-a456-426614174300")
    id: string;
  }

  model OnboardingRequest {
    @doc("The real name of the user.")
    @example("Alice Chen")
    fullName: string;

    @doc("The computer account name of the user.")
    @example("alice")
    linuxUsername: string;
  }

  model githubLoginURL {
    @doc("redirect to frontend URL")
    @example("https://github.com/login/oauth/authorize?access_type=offline&client_id=xxx")
    redirctURL: string;
  }

  @error
  @doc("User already onboarded or field validation failed.")
  model OnboardingBadRequest {
    @statusCode
    statusCode: 400;
  }

  @route("/settings")
  @get
  op getUserSettings(): {
    @statusCode statusCode: 200;
    @body settings: SettingsResponse;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/settings")
  @put
  op updateSettings(@body body: Settings): {
    @statusCode statusCode: 200;
    @body newSettings: Settings;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @get
  op getPublicKey(
    @doc("Get 10 head characters of publickey as short public key in 'publickey' field.")
    @query
    @example(false)
    short?: boolean,
  ): {
    @statusCode statusCode: 200;
    @body publicKey: PublicKey[];
  } | {
    @statusCode statusCode: 404;
  };

  @route("/publickey")
  @post
  op addPublicKey(@body body: AddPublicKeyRequest): {
    @statusCode statusCode: 200;
    @body publicKey: PublicKey;
  } | Error.ValidationProblem;

  @route("/publickey")
  @delete
  op deletePublicKey(@body body: DeletePublicKeyRequest): {
    @statusCode statusCode: 200;
  } | {
    @statusCode statusCode: 404;
  } | Error.ValidationProblem;

  @route("/publickey/import")
  @get
  op importPublicKey(
    @doc("The redirect URL after login completed.")
    @query
    @example("http://localhost:8080/")
    r?: string,
  ): {
    @statusCode statusCode: 200;
    @body redirectURL: githubLoginURL;
  } | {
    @statusCode statusCode: 404;
  };

  @route("/onboarding")
  @post
  op onboardUser(@body body: OnboardingRequest): {
    @statusCode statusCode: 200;
  } | OnboardingBadRequest | {
    @statusCode statusCode: 403;
  };
}
