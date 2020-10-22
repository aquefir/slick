# -*- coding: utf-8 -*-
## This Makefile provides the bodies of a variety of build targets (or
## ‘recipes’) normally used in building native executables and libraries.
## These include: debug, release, sanity check, code coverage, and address
## sanitisation tunings. Using the conventional *FILES and *FLAGS Makefile
## variables, the toolchain program variables (like ‘$(CC)’), the $(PROJECT)
## variable, and some miscellaneous helpers, it will fill out all of the
## typical details for these targets automatically, just by including it in
## the main Makefile.
## This works with both C and C++ code, and is continuously tested on macOS
## Mojave and Arch Linux.
## Read <https://aquefir.co/slick/makefiles> for details.
## This file: version 1.0.2

## DEPRECATION: <https://github.com/aquefir/slick/issues/7>
ifdef HFILES
$(warning HFILES is deprecated. Please use PUBHFILES and PRVHFILES instead)
endif
ifdef HPPFILES
$(warning HPPFILES is deprecated. Please use PUBHFILES and PRVHFILES instead)
endif

ifdef TES_HFILES
$(warning TES_HFILES is deprecated. Please use PUBHFILES and PRVHFILES instead)
endif
ifdef TES_HPPFILES
$(warning TES_HPPFILES is deprecated. Please use PUBHFILES and PRVHFILES instead)
endif

##
## Additional variables
##

# 3rdparty dependencies
3PINCLUDES := $(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS))
3PLIBDIRS  := $(patsubst %,$(3PLIBDIR)/%lib,$(3PLIBS))

# Variable transformations for command invocation
LIB := $(patsubst %,-L%,$(LIBDIRS)) $(patsubst %,-l%,$(LIBS)) \
	$(patsubst %,-L%,$(3PLIBDIRS)) $(patsubst %,-l%,$(3PLIBS))
ifeq ($(CC),tcc)
INCLUDE := $(patsubst %,-I%,$(INCLUDES)) $(patsubst %,-I%,$(INCLUDEL)) \
	$(patsubst %,-I%,$(3PINCLUDES))
else
INCLUDE := $(patsubst %,-isystem %,$(INCLUDES)) \
	$(patsubst %,-iquote %,$(INCLUDEL)) $(patsubst %,-isystem %,$(3PINCLUDES))
endif
DEFINE    := $(patsubst %,-D%,$(DEFINES)) $(patsubst %,-U%,$(UNDEFINES))
FWORK     := $(patsubst %,-framework %,$(FWORKS))
ASINCLUDE := $(patsubst %,-I %,$(INCLUDES)) $(patsubst %,-I %,$(INCLUDEL)) \
	$(patsubst %,-I %,$(3PINCLUDES))
ASDEFINE  := $(patsubst %,--defsym %=1,$(DEFINES))

# For make install
PREFIX ?= /usr/local

# Populated below
TARGETS :=

# No test targets yet for the GBA
ifeq ($(strip $(TP)),GBA)
TESTARGETS :=
else
TESTARGETS := $(TES_CFILES:.tes.c=.c.tes) $(TES_CPPFILES:.tes.cpp=.cpp.tes)
endif

# specify all target filenames
GBATARGET := $(PROJECT).gba
EXETARGET := $(PROJECT)$(EXE)
SOTARGET  := lib$(PROJECT).$(SO)
DLLTARGET := lib$(PROJECT).dll # always used by make clean
ATARGET   := lib$(PROJECT).a

ifeq ($(strip $(TP)),GBA)
ifeq ($(strip $(EXEFILE)),1)
TARGETS += $(GBATARGET)
endif
else # TP != GBA
ifeq ($(strip $(EXEFILE)),1)
TARGETS += $(EXETARGET)
endif
ifeq ($(strip $(SOFILE)),1)
TARGETS += $(SOTARGET)
endif
endif
ifeq ($(strip $(AFILE)),1)
TARGETS += $(ATARGET)
endif

OFILES := $(CFILES:.c=.c.o) $(CPPFILES:.cpp=.cpp.o)
# HACK: Ignore assemblies on Darwin as LLVM will not recognise them
ifneq ($(TP),Darwin)
OFILES += $(SFILES:.s=.s.o)
endif
TES_OFILES := $(TES_CFILES:.c=.c.o) $(TES_CPPFILES:.cpp=.cpp.o)

# Use ?= so that this can be overridden. This is useful when some projects in
# a solution need $(CXX) linkage when the main project lacks any $(CPPFILES)
ifeq ($(strip $(CPPFILES)),)
CCLD ?= $(CC)
else
CCLD ?= $(CXX)
endif



##
## Targets
##

.PHONY: debug release check cov asan ubsan format clean

## Debug build
## useful for: normal testing, valgrind, LLDB
##
# ensure NDEBUG is undefined
debug: DEFINE += -UNDEBUG
ifneq ($(CC),tcc)
# tcc cannot take these additional options
debug: CFLAGS += $(CFLAGS.GCOMMON.DEBUG)
endif # tcc
debug: CXXFLAGS += $(CXXFLAGS.COMMON.DEBUG)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
debug: REALSTRIP := ':' ; # : is a no-op
debug: $(TARGETS)

## Release build
## useful for: deployment
##
# ensure NDEBUG is defined
release: DEFINE += -DNDEBUG=1
ifneq ($(CC),tcc)
# tcc cannot take these additional options
release: CFLAGS += $(CFLAGS.GCOMMON.RELEASE)
endif # tcc
release: CXXFLAGS += $(CXXFLAGS.COMMON.RELEASE)
release: REALSTRIP := $(STRIP)
release: $(TARGETS)

## Sanity check build
## useful for: pre-tool bug squashing
##
# ensure NDEBUG is undefined
check: DEFINE += -UNDEBUG
ifneq ($(CC),tcc)
# tcc cannot take these additional options
check: CFLAGS += $(CFLAGS.GCOMMON.CHECK)
endif # tcc
check: CXXFLAGS += $(CXXFLAGS.COMMON.CHECK)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
check: REALSTRIP := ':' ; # : is a no-op
check: $(TARGETS)

## Code coverage build
## useful for: checking coverage of test suite
##
ifeq ($(strip $(NO_TES),)
# ensure NDEBUG is undefined, add a #define for code coverage & TES
cov: DEFINE += -UNDEBUG -D_CODECOV -DTES_BUILD=1
ifneq ($(CC),tcc)
# tcc cannot take these additional options
cov: CFLAGS += $(CFLAGS.GCOMMON.COV)
endif # tcc
cov: CXXFLAGS += $(CXXFLAGS.COMMON.COV)
cov: LDFLAGS += $(LDFLAGS.COV)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
cov: REALSTRIP := ':' ; # : is a no-op
cov: DEFINE += -DTES_BUILD=1
cov: $(TESTARGETS)
endif # $(NO_TES)

## Address sanitised build
## useful for: squashing memory issues
##
ifeq ($(strip $(NO_TES)),)
# ensure NDEBUG is undefined, add a #define for address sanitisation & TES
asan: DEFINE += -UNDEBUG -D_ASAN=1 -DTES_BUILD=1
ifneq ($(CC),tcc)
# tcc cannot take these additional options
asan: CFLAGS += $(CFLAGS.GCOMMON.ASAN)
endif # tcc
asan: CXXFLAGS += $(CXXFLAGS.COMMON.ASAN)
asan: LDFLAGS += $(LDFLAGS.ASAN)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
asan: REALSTRIP := ':' ; # : is a no-op
asan: $(TESTARGETS)
endif # $(NO_TES)

## Undefined Behaviour sanitised build
## useful for: squashing UB :-)
##
ifeq ($(strip $(NO_TES)),)
# ensure NDEBUG is undefined, add a #define for UB sanitisation & TES
ubsan: DEFINE += -UNDEBUG -D_ASAN=1 -DTES_BUILD=1
ifneq ($(CC),tcc)
# tcc cannot take these additional options
ubsan: CFLAGS += $(CFLAGS.GCOMMON.ASAN)
endif # tcc
ubsan: CXXFLAGS += $(CXXFLAGS.COMMON.ASAN)
ubsan: LDFLAGS += $(LDFLAGS.ASAN)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
ubsan: REALSTRIP := ':' ; # : is a no-op
ubsan: $(TESTARGETS)
endif # $(NO_TES)

##
## Recipes
##

# Object file builds
%.cpp.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $(DEFINE) $(INCLUDE) $<

%.c.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $<

%.s.o: %.s
	$(AS) -o $@ $(ASFLAGS) $(ASDEFINE) $(ASINCLUDE) $<

%.tes.cpp.o: %.tes.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $(INCLUDE) $<

%.tes.c.o: %.tes.c
	$(CC) -c -o $@ $(CFLAGS) $(INCLUDE) $<

%.cpp.tes: %.tes.cpp.o
	$(CCLD) $(LDFLAGS) -o $@ $^ $(LIB)

%.c.tes: %.tes.c.o
	$(CCLD) $(LDFLAGS) -o $@ $^ $(LIB)
