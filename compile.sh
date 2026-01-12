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
        
        latexmk -pdf -pdflatex="pdflatex --shell-escape %O %S" -pvc -view=none -outdir=../output -interaction=nonstopmode thesis-en.tex
    else
        latexmk -pdf -pdflatex="pdflatex --shell-escape %O %S" -g -outdir=../output -interaction=nonstopmode thesis-en.tex
    fi
}

if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    echo "Running inside container..."
    do_compile
else
    echo "Running on host..."
    
    IMAGE_NAME="${IMAGE_NAME:-latex-thesis}"
    if [ "$SKIP_BUILD" != "true" ]; then
        docker build -t "$IMAGE_NAME" .devcontainer
    fi
    if [ -t 0 ]; then
        docker run --rm -it -v "$(pwd):/workspace" "$IMAGE_NAME" ./compile.sh "$@"
    else
        docker run --rm -i  -v "$(pwd):/workspace" "$IMAGE_NAME" ./compile.sh "$@"
    fi
fi
