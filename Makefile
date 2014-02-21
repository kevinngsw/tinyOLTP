CFLAGS=-g -O2 -Wall -Wextra -Isrc -rdynamic -NDEBUG $(OPTFLAGS)
LIBS=-ldl $(OPTFLAGS)
PREFIX?=/usr/local

BIN_SRC_ROOT=src/bin
BIN_ROOT=bin
BUILD_ROOT=build
TEST_SRC_ROOT=src/test

TESTS_SRC=$(wildcard tests/*_tests.c)
TESTS_BIN=$(patsubst %.c,%,$(TEST_SRC))


## Libraries ##

# Paged File Layer
PF_ROOT=src/pf
PF_SRC=$(wildcard $(PF_ROOT)/*.c $(PF_ROOT)/**/*.c)
PF_OBJ=$(patsubst %.c,%.o,$(PF_SRC))
PF_LIB=$(BUILD_ROOT)/libpf.a

# Heap File Layer
HF_ROOT=src/hf
HF_SRC=$(wildcard $(HF_ROOT)/*.c $(HF_ROOT)/**/*.c)
HF_OBJ=$(patsubst %.c,%.o,$(HF_SRC))
HF_LIB=$(BUILD_ROOT)/libhf.a

# Access Method Layer
AM_ROOT=src/am
AM_SRC=$(wildcard $(AM_ROOT)/*.c $(AM_ROOT)/**/*.c)
AM_OBJ=$(patsubst %.c,%.o,$(AM_SRC))
AM_LIB=$(BUILD_ROOT)/libam.a

# Front End Layer
FE_ROOT=src/fe
FE_SRC=$(wildcard $(FE_ROOT)/*.c $(FE_ROOT)/**/*.c)
FE_OBJ=$(patsubst %.c,%.o,$(FE_SRC))
FE_LIB=$(BUILD_ROOT)/libfe.a

ALL_LIB=$(PF_LIB) $(HF_LIB) $(AM_LIB) $(FE_LIB)

## Binaries (Executable) ##

DBCREATE_SRC=$(BIN_SRC_ROOT)/dbcreate.c
DBCREATE=$(BIN_ROOT)/dbcreate
DBDESTROY_SRC=$(BIN_SRC_ROOT)/dbdestroy.c
DBDESTROY=$(BIN_ROOT)/dbdestroy
MINIREL_SRC=$(BIN_SRC_ROOT)/minirel.c
MINIREL=$(BIN_ROOT)/minirel

all: tests

$(DBCREATE): $(DBCREATE_SRC) $(ALL_LIB)
	$(CC) -o $@ $(ALL_LIB)

$(DBDESTROY): $(DBDESTROY_SRC) $(ALL_LIB)
	$(CC) -o $@ $(ALL_LIB)

$(MINIREL): $(MINIREL_SRC) $(ALL_LIB)
	$(CC) -o $@ $(ALL_LIB)

# Tests
.PHONY: tests
tests: CFLAGS += $(PF_LIB)
	# $(HF_LIB) $(AM_LIB) $(FE_LIB)
tests: $(TESTS_BIN)
	sh ./$(TEST_SRC_ROOT)/runtests.sh

valgrind:
	VALGRIND="valgrind --log-file=/tmp/valgrind-%p.log" $(MAKE)

# Libraries
$(PF_LIB): $(PF_OBJ)
	ar rcs $@ $(PF_OBJ)
	ranlib $@

$(HF_LIB): $(HF_OBJ)
	ar rcs $@ $(HF_OBJ)
	ranlib $@

$(AM_LIB): $(AM_OBJ)
	ar rcs $@ $(AM_OBJ)
	ranlib $@

$(FE_LIB): $(FE_OBJ)
	ar rcs $@ $(FE_OBJ)
	ranlib $@

# Clean
.PHONY: clean
clean:
	rm -rf build/*
	rm -rf bin/*
	rm -rf $(
	rm -rf $(TESTS_BIN)
	find . -name "*.gc*" -exec rm {} \;
	rm -rf 'find . -name "*.dSYM" -print'