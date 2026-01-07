#!/bin/bash

docker build -t latex-thesis .devcontainer

# Run the compilation inside the container
# -v $(pwd):/workspace: Mount current directory to /workspace
# --rm: Remove container after run
# latex-thesis: Image name
# ./compile.sh: Command to run inside container
docker run --rm -v "$(pwd):/workspace" latex-thesis ./compile.sh
