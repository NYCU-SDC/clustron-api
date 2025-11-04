[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/NYCU-SDC/clustron-api)
# Clustron API

This repository contains the TypeSpec API definitions for Clustron.

## API Documentation

- [Swagger UI](https://nycu-sdc.github.io/clustron-api/index.html)
- [Redocly](https://nycu-sdc.github.io/clustron-api/redocly.html)

## Prerequisites

- Node.js and npm
- TypeSpec compiler (`@typespec/compiler`)

## Installation

```bash
# Install TypeSpec compiler globally
npm install -g @typespec/compiler

# Install project dependencies
tsp install
```

## Build Commands

The project includes a Makefile with the following commands:

### Format Check
```bash
make format
```

### Compilation
```bash
make compile
```

### Cleanup
```bash
make clean
```

### Full Build
```bash
make
```

## Output

The compilation process generates OpenAPI specification in the `tsp-output/schema/openapi.yaml` file.

## GitHub Actions

This project includes GitHub Actions workflow that:
1. Checks TypeSpec formatting
2. Compiles TypeSpec to OpenAPI
3. Generates and deploys Swagger UI documentation to GitHub Pages
