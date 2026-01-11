#!/bin/bash

WATCH_MODE=false
for arg in "$@"
do
    if [ "$arg" == "--watch" ]; then
        WATCH_MODE=true
    fi
done

do_compile() {
    mkdir -p output

    echo "Compiling Title Page..."
    cd src/title_page || exit
    xelatex -output-directory=../../output -interaction=nonstopmode titlepage-bsc-en.tex > /dev/null

    if [ -f ../../output/titlepage-bsc-en.pdf ]; then
        echo "Title Page compiled successfully."
        cp ../../output/titlepage-bsc-en.pdf ../../output/titlepage-en.pdf
    else
        echo "Error: Title Page compilation failed."
        exit 1
    fi
    cd ../..

    echo "Compiling Thesis..."
    cd src || exit
    
    export TEXINPUTS=.:../output/:$TEXINPUTS

    if [ "$WATCH_MODE" = true ]; then
        echo ">>> STARTING WATCH MODE (Hot-Reload) <<<"
        echo "Modify your .tex files and save them. The PDF will update automatically."
        echo "Press Ctrl+C to stop."
        
        latexmk -pdf -pvc -view=none -outdir=../output -interaction=nonstopmode thesis-en.tex
    else
        latexmk -pdf -g -outdir=../output -interaction=nonstopmode thesis-en.tex
    fi
}

if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    echo "Running inside container..."
    do_compile
else
    echo "Running on host..."
    
    docker build -t latex-thesis .devcontainer
    docker run --rm -it -v "$(pwd):/workspace" latex-thesis ./compile.sh "$@"
fi
