FROM texlive/texlive:latest

RUN apt-get update && apt-get install -y \
    git \
    make \
    inkscape \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
