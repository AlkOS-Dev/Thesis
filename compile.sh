#!/bin/bash

# Function to run the actual compilation logic (runs inside container)
do_compile() {
    mkdir -p output

    echo "Compiling Title Page..."
    
    cd src/title_page || exit
    
    # Compile the Title Page
    xelatex -output-directory=../../output -interaction=nonstopmode titlepage-bsc-en.tex

    if [ -f ../../output/titlepage-bsc-en.pdf ]; then
        echo "Title Page compiled successfully."
        cp ../../output/titlepage-bsc-en.pdf ../../output/titlepage-en.pdf
    else
        echo "Error: Title Page compilation failed."
        exit 1
    fi

    cd ../..

    # Compile the Main Thesis
    echo "Compiling Thesis..."
    cd src || exit

    # Clean previous fdb_latexmk to force re-evaluation if needed
    # We add ../output to TEXINPUTS so it finds titlepage-en.pdf
    export TEXINPUTS=.:../output/:$TEXINPUTS

    # Run latexmk
    # -g: Force processing
    latexmk -pdf -g -outdir=../output -interaction=nonstopmode thesis-en.tex
}

# Check if we are inside a docker container
# The /.dockerenv file is a standard way to check this
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    # We are inside the container, run the compilation
    echo "Running inside container..."
    do_compile
else
    # We are on the host, run the container wrapper
    echo "Running on host, launching Docker..."
    
    # Build the image if needed
    docker build -t latex-thesis .devcontainer

    # Run the container with the script itself as the command
    # We mount the current directory and run this same script inside
    docker run --rm -v "$(pwd):/workspace" latex-thesis ./compile.sh
fi
