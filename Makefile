GREEN = \033[0;32m
BLUE = \033[0;34m
RED = \033[0;31m
NC = \033[0m

.PHONY: all format compile clean

all: format compile
	@echo -e "==> $(BLUE)All tasks completed successfully$(NC)"

format:
	@echo -e ":: $(GREEN)Checking TypeSpec format...$(NC)"
	@npx -p @typespec/compiler tsp format "**/*.tsp" \
		&& echo -e "==> $(BLUE)Format check completed$(NC)" \
		|| (echo -e "==> $(RED)Format check failed$(NC)" && exit 1)

compile:
	@echo -e ":: $(GREEN)Compiling TypeSpec...$(NC)"
	@npx -p @typespec/compiler tsp compile . \
		&& echo -e "==> $(BLUE)Compilation completed$(NC)" \
		|| (echo -e "==> $(RED)Compilation failed$(NC)" && exit 1)

clean:
	@echo -e ":: $(GREEN)Cleaning build artifacts...$(NC)"
	@rm -rf tsp-output \
		&& echo -e "==> $(BLUE)Cleanup completed$(NC)" \
		|| (echo -e "==> $(RED)Cleanup failed$(NC)" && exit 1)

mock:
	@docker run --init --rm \
	    -v $(PWD):/api \
        -p 4010:4010 stoplight/prism:4 \
        mock -h 0.0.0.0 "/api/tsp-output/schema/openapi.1.0.0.yaml"