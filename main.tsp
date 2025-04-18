import "@typespec/http";

using Http;

@service(#{ title: "Pet Store" })
@server("https://example.com", "Single server endpoint")
namespace PetStore;

@doc("Represent a Pet available in the PetStore")
model Pet {
  id: int32;

  @minLength(1)
  name: string;

  @minValue(0)
  @maxValue(100)
  age: int32;

  kind: petType;
}

enum petType {
  dog: "dog",
  cat: "cat",
  fish: "fish",
  bird: "bird",
  reptile: "reptile",
}

@route("/pets")
namespace Pets {
  @get
  op listPets(@offset skip?: int32 = 0): {
    @pageItems pets: Pet[];
  };

  @get
  op getPet(@path petId: int32): {
    @statusCode statusCode: 200;
    @body pet: Pet;
    // highlight-start
  } | {
    @statusCode statusCode: 404;
    // highlight-end
  };

  @post
  op createPet(@body pet: Pet): {
    @statusCode statusCode: 201;
    @body newPet: Pet;
    // highlight-start
  } | {
    @statusCode statusCode: 202;
    @body acceptedPet: Pet;
    // highlight-end
  };

  @put
  op updatePet(@path petId: int32, @body pet: Pet): {
    @statusCode statusCode: 200;
    @body updatedPet: Pet;
    // highlight-start
  } | {
    @statusCode statusCode: 404;
    // highlight-end
  };

  @delete
  op deletePet(@path petId: int32): {
    @statusCode statusCode: 204;
  };
}
