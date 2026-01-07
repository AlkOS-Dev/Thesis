#!/bin/bash

mkdir -p output
cd src || exit
latexmk -pdf -outdir=../output -interaction=nonstopmode main.tex
