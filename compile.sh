#!/bin/bash

# Ensure output directory exists
mkdir -p output

# Move to src directory for thesis compilation, but we need to handle title page differently
# to ensure relative paths work correctly.

# 1. Compile the Title Page
echo "Compiling Title Page..."

# We cd into title_page so that `arial.ttf` and `img/` are found relatively as expected by the tex file.
cd src/title_page || exit
# Compile to a temporary location or directly to output
# We use -output-directory to put the pdf in the project output folder
# But we need to use absolute path or relative from where we are.
# From src/title_page, ../../output is the output dir.
xelatex -output-directory=../../output -interaction=nonstopmode titlepage-bsc-en.tex

# Check if successful
if [ -f ../../output/titlepage-bsc-en.pdf ]; then
    echo "Title Page compiled successfully."
    # Rename/copy it to what the main thesis expects
    cp ../../output/titlepage-bsc-en.pdf ../../output/titlepage-en.pdf
else
    echo "Error: Title Page compilation failed."
    exit 1
fi

# Go back to project root
cd ../..

# 2. Compile the Main Thesis
echo "Compiling Thesis..."
cd src || exit

# Clean previous fdb_latexmk to force re-evaluation if needed, though latexmk is good at this.
# We add ../output to TEXINPUTS so it finds titlepage-en.pdf
export TEXINPUTS=.:../output/:$TEXINPUTS

# Run latexmk
# -g: Force processing
latexmk -pdf -g -outdir=../output -interaction=nonstopmode thesis-en.tex
