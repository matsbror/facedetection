Benchmark = facedetection

SRCDIR = ./src
SRCSUFFIX = cpp

CFLAGS = -fno-exceptions
CINCLUDE = -I./src 
OPT = -O3
LDFLAGS =

Native = ${Benchmark}
WASM = ${Benchmark}.wasm

SRC = $(wildcard ${SRCDIR}/*.${SRCSUFFIX})
OBJ = $(SRC:.${SRCSUFFIX}=.o)


CLANG=clang

ifeq (${SRCSUFFIX}, $(filter ${SRCSUFFIX}, cc cpp))
    CLANG=clang++
endif

CC=${CLANG}

WASMCC=${CLANG} --target=wasm32-wasi --sysroot=${WASI_SYSROOT}

all: ${Native} ${WASM}

%.o: %.${SRCSUFFIX}
	${CC} ${CFLAGS} ${OPT} ${CINCLUDE} -c $< -o $@

${Native}: ${OBJ}
	${CC} ${CFLAGS} ${OPT} $^ ${LDFLAGS} -o $@

${WASM}: ${SRC}
	${WASMCC} ${CFLAGS} ${OPT} ${CINCLUDE} ${WASM_LDFLAGS} $^ -o $@
	wasm-opt -O3 --strip-debug $@ -o $@

clean:
	@echo "Cleaning up..."
	rm -rf ${OBJ} ${Native} ${WASM} ${TEMPFILE} *.cwasm output_*
