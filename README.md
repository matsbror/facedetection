# facedetection
A face detection application and scaffolding necessary to dockerize it native and with WebAssembly

This benchmark was developed based on the following open-source projects:

1. libfacedetection
https://github.com/ShiqiYu/libfacedetection

2. stb
https://github.com/nothings/stb


# Building

## Pre-requisites

- [clang++](https://github.com/llvm/llvm-project) (tested with clang 18)
- [WASI SDK sysroot](https://github.com/WebAssembly/wasi-sdk) (tested with version 24)
- Docker 
- Containerd runtime capabile of running WebAssembly binaries:
    - [Docker desktop](https://docs.docker.com/desktop/features/wasm/) on desktops
    - [runwasi](https://github.com/containerd/runwasi) on other types of servers

Set environment variable `WASI_SYSROOT` to where the WASI SDK resides. 

## Build

```
make
```

will build the native application and a WebAssembly module which can be run with [Wasmtime](https://wasmtime.dev/) or some other wasm runtime. 

## Test

Run the program like:

```
# running native binary
./facedetection input.png
# running WebAssembly binary
wasmtime --dir . facedetection.wasm input.png
```


## Build docker images

The following commands will build a docker image for three difference architectures:

```bash
$ docker buildx build --platform linux/amd64 -f Dockerfile.native -t matsbror/fd-multiarch:1.1-amd64 --provenance false --output type=image,push=true .
$ docker buildx build --platform linux/arm64 -f Dockerfile.native -t matsbror/fd-multiarch:1.1-arm64 --provenance false --output type=image,push=true .
$ docker buildx build --platform linux/riscv64 -f Dockerfile.riscv -t matsbror/fd-multiarch:1.1-riscv64 --provenance false --output type=image,push=true .
$ docker manifest create matsbror/fd-multiarch:1.1 --amend matsbror/fd-multiarch:1.1-amd64 --amend matsbror/fd-multiarch:1.1-arm64 --amend matsbror/fd-multiarch:1.1-riscv64
$ docker manifest push matsbror/fd-multiarch:1.1

```

Replace `matsbror/fd-multiarch:1.1` with your own image name.

Note that the builds for arm64 and riscv64 will take longer than the amd64 build (if you are on a computer with an amd64 chip) since they are emulated using QEMU.

The following will build a docker image for a WebAssembly binary:

```bash
docker buildx build --platform wasm -f Dockerfile.wasm -t matsbror/fd-wasm:1.1 --provenance false --output type=image,push=true .
```

# Running

## Using docker

Run the native image like this:

```bash
docker run --platform linux/amd64 matsbror/fd-multiarch:1.1
```

Run the WebAssembly image like this:

```bash
docker run --platform wasm --runtime io.containerd.wasmtime.v1 matsbror/fd-wa
sm:1.1
```

## Using containerd directly

Run the native image like this:

```bash
sudo ctr image pull docker.io/matsbror/fd-multiarch:1.1
sudo ctr  run --rm docker.io/matsbror/fd-multiarch:1.1 ctr1
```

Run the WebAssembly image like this:

```bash
sudo ctr image pull docker.io/matsbror/fd-wasm:1.1
sudo ctr  run --rm --platform wasm --runtime io.containerd.wasmtime.v1 docker.io/matsbror/fd-wasm:1.1 ctr1
```

# Measure

The script `measure.sh` can be used to measure the pull times of the native and WebAssembly container images. It takes one argument: the number of times to run the command, and writes the results to a CSV file: `timing_results.csv`.

```bash
./measure.sh 10
```

