#!/usr/bin/make
# -*- coding: utf-8 -*-
## Copyright © 2020-2021 Aquefir.
## Released under BSD-2-Clause.
## This Makefile provides the bodies of a variety of build targets (or
## ‘recipes’) normally used in building native executables and libraries.
## These include: debug, release, sanity check, code coverage, and address
## sanitisation tunings. Using the conventional *FILES and *FLAGS Makefile
## variables, the toolchain program variables (like ‘$(CC)’), the $(PROJECT)
## variable, and some miscellaneous helpers, it will fill out all of the
## typical details for these targets automatically, just by including it in
## the main Makefile.
## This works with C, C++, C* and assembly code, and is continuously tested on
## macOS Mojave and Arch Linux.
## Read <https://aquefir.co/slick/makefiles> for details.
## This file: version 1.3.0

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

## Variable printout function code.

ifeq ($(SLICK_PRINT),0)
.L_PRINTOUT :=
else
.L_TAG.DEFAULT := [default]
.L_TAG.CUSTOM  := [custom!]
.L_Item = $(info $(.L_TAG.$($(1)_ORIGIN)) $(2) :: $($(1)))

.L_PRINTOUT = \
	$(info =====) \
	$(info ===== BUILD SETTINGS PRINTOUT) \
	$(info =====) \
	$(info ) \
	$(info ----- ENVIRONMENT) \
	$(call .L_Item,$(1),Host machine) \
	$(call .L_Item,$(2),Target machine) \
	$(call .L_Item,$(3),Toolchain in use) \
	$(call .L_Item,$(4),Target sysroot) \
	$(call .L_Item,$(5),Executable ext.) \
	$(call .L_Item,$(6),Shared library ext.) \
	$(info ----- TOOLS) \
	$(call .L_Item,$(7),Autoformatter) \
	$(call .L_Item,$(8),Assembler) \
	$(call .L_Item,$(9),C compiler) \
	$(call .L_Item,$(10),C++ compiler) \
	$(call .L_Item,$(11),Static archiver) \
	$(call .L_Item,$(12),Object copier) \
	$(call .L_Item,$(13),Object stripper) \
	$(info ----- FLAGS AND OPTIONS) \
	$(call .L_Item,$(14),Assembler flags) \
	$(call .L_Item,$(15),C compiler flags) \
	$(call .L_Item,$(16),C++ compiler flags) \
	$(call .L_Item,$(17),Static archiver flags) \
	$(call .L_Item,$(18),Linker flags) \
	$(call .L_Item,$(19),Defines) \
	$(call .L_Item,$(20),Undefines) \
	$(call .L_Item,$(21),Synthetics)
endif
.L_TPRINTOUT = $(call .L_PRINTOUT,.K_UNAME,TP,TC,TROOT,EXE,SO,FMT,AS,CC,CXX,\
	AR,OCPY,STRIP,$(1),$(2),$(3),ARFLAGS,$(4),$(5),$(6),SYNDEFS)

.L_File.C     := ---> \033[34mCompiling
.L_File.CXX   := ---> \033[33mCompiling
.L_File.CST   := ---> \033[32mCompiling
.L_File.S     := ---> \033[32mAssembling
.L_File.LD    := --> \033[31mLinking
.L_File.STRIP := -> \033[31mStripping
.L_File.OCPY  := -> \033[37mCopying binary of
.L_File.FMT   := -> \033[37mFormatting
.L_File.MID   := ---> \033[35mProcessing
.L_File.PCM   := ---> \033[35mAssembling
.L_File.IMG   := ---> \033[33mTransmogrifying

.L_File = @$(ECHO) -e " $(.L_File.$(1))\033[0m \033[1m$(2)\033[0m ..."
.L_FileNoAt = $(ECHO) -e " $(.L_File.$(1))\033[0m \033[1m$(2)\033[0m ..."

## Construct the *FLAGS variables normally.

# ASFLAGS
.L_ASFLAGS := \
	$(ASFLAGS.COMMON.ALL) \
	$(ASFLAGS.COMMON.$(TP))
ifeq ($(origin ASFLAGS),undefined)
# nop
else ifeq ($(origin ASFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_ASFLAGS += $(ASFLAGS)
endif

# CFLAGS
.L_CFLAGS := \
	$(CFLAGS.COMMON.ALL.$(TC)) \
	$(CFLAGS.COMMON.$(TP).$(TC))
ifeq ($(origin CFLAGS),undefined)
# nop
else ifeq ($(origin CFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_CFLAGS += $(CFLAGS)
endif

# CXXFLAGS
.L_CXXFLAGS := \
	$(CXXFLAGS.COMMON.ALL.$(TC)) \
	$(CXXFLAGS.COMMON.$(TP).$(TC))
ifeq ($(origin CXXFLAGS),undefined)
# nop
else ifeq ($(origin CXXFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_CXXFLAGS += $(CXXFLAGS)
endif

# ARFLAGS
.L_ARFLAGS := $(ARFLAGS.COMMON)
ifeq ($(origin ARFLAGS),undefined)
# nop
else ifeq ($(origin ARFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_ARFLAGS += $(ARFLAGS)
endif

# LDFLAGS
.L_LDFLAGS := \
	$(LDFLAGS.COMMON.ALL.$(TC)) \
	$(LDFLAGS.COMMON.$(TP).$(TC))
ifeq ($(origin LDFLAGS),undefined)
# nop
else ifeq ($(origin LDFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_LDFLAGS += $(LDFLAGS)
endif

# SYNDEFS
.L_SYNDEFS := \
	$(SYNDEFS.ALL) \
	$(SYNDEFS.$(TP))
ifeq ($(origin SYNDEFS),undefined)
# nop
else ifeq ($(origin SYNDEFS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_SYNDEFS += $(SYNDEFS)
endif

## Override the *FLAGS variables if requested and such *FLAGS are nonempty

ifeq ($(SLICK_OVERRIDE),1)

ifeq ($(origin ASFLAGS),undefined)
# nop
else ifeq ($(origin ASFLAGS),default)
# nop
else ifeq ($(origin ASFLAGS),command line)
# nop
else ifeq ($(strip $(ASFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_ASFLAGS := $(ASFLAGS)
endif

ifeq ($(origin CFLAGS),undefined)
# nop
else ifeq ($(origin CFLAGS),default)
# nop
else ifeq ($(origin CFLAGS),command line)
# nop
else ifeq ($(strip $(CFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_CFLAGS := $(CFLAGS)
endif

ifeq ($(origin CXXFLAGS),undefined)
# nop
else ifeq ($(origin CXXFLAGS),default)
# nop
else ifeq ($(origin CXXFLAGS),command line)
# nop
else ifeq ($(strip $(CXXFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_CXXFLAGS := $(CXXFLAGS)
endif

ifeq ($(origin ARFLAGS),undefined)
# nop
else ifeq ($(origin ARFLAGS),default)
# nop
else ifeq ($(origin ARFLAGS),command line)
# nop
else ifeq ($(strip $(ARFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_ARFLAGS := $(ARFLAGS)
endif

ifeq ($(origin LDFLAGS),undefined)
# nop
else ifeq ($(origin LDFLAGS),default)
# nop
else ifeq ($(origin LDFLAGS),command line)
# nop
else ifeq ($(strip $(LDFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_LDFLAGS := $(LDFLAGS)
endif

endif

# Finally, set the variables.
ASFLAGS  := $(.L_ASFLAGS)
CFLAGS   := $(.L_CFLAGS)
CXXFLAGS := $(.L_CXXFLAGS)
ARFLAGS  := $(.L_ARFLAGS)
LDFLAGS  := $(.L_LDFLAGS)
SYNDEFS  := $(.L_SYNDEFS)

# Add the appropriate APE files as present.
ifeq ($(TP),APE)
ifneq ($(origin APE_LDSCR),undefined)
LDFLAGS += -T $(APE_LDSCR)
endif
ifneq ($(origin APE_AFILE),undefined)
LDFLAGS += $(APE_AFILE)
endif
ifneq ($(origin APE_HFILE),undefined)
ASFLAGS += -include $(APE_HFILE)
CFLAGS += -include $(APE_HFILE)
CXXFLAGS += -include $(APE_HFILE)
endif
ifneq ($(origin APE_APEO),undefined)
LDFLAGS += $(APE_APEO)
endif
ifneq ($(origin APE_CRTO),undefined)
LDFLAGS += $(APE_CRTO)
endif
endif

## Set the LD program.

ifeq ($(origin LD),undefined)
.O_LD := DEFAULT
else ifeq ($(origin LD),default)
.O_LD := DEFAULT
else
# environment [override], file, override, automatic
.O_LD := CUSTOM
endif

# Set the target and file dependent values of the new variable.
ifeq ($(strip $(CPPFILES))$(strip $(CPPFILES.$(TP))),)
LD.O_DEFAULT := $(CC)
else
LD.O_DEFAULT := $(CXX)
endif
LD.O_CUSTOM := $(LD)

# Finally, set the variable.
override LD := $(LD.O_$(.O_LD))

## Finalise flags and quasi-flags into their invocation-ready form.

.K_LIB := \
	$(patsubst %,-L%,$(LIBDIRS)) \
	$(patsubst %,-L%,$(patsubst %,$(3PLIBDIR)/%lib,$(3PLIBS))) \
	$(patsubst %,-l%,$(LIBS)) \
	$(patsubst %,-l%,$(3PLIBS))

# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(CC)),tcc)
.K_INCLUDE := \
	$(patsubst %,-I%,$(INCLUDES)) \
	$(patsubst %,-I%,$(INCLUDEL)) \
	$(patsubst %,-I%,$(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS)))
else
.K_INCLUDE := \
	$(patsubst %,-isystem %,$(INCLUDES)) \
	$(patsubst %,-iquote %,$(INCLUDEL)) \
	$(patsubst %,-isystem %,$(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS)))
endif

.K_ASINCLUDE := \
	$(patsubst %,-I%,$(INCLUDES)) \
	$(patsubst %,-I%,$(INCLUDEL)) \
	$(patsubst %,-I%,$(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS)))

.K_DEFINE := \
	$(patsubst %,-D%,$(DEFINES)) \
	$(patsubst %,-U%,$(UNDEFINES)) \
	$(patsubst %,-DCFG_%,$(SYNDEFS))

.K_ASDEFINE := \
	$(patsubst %,--defsym %=1,$(DEFINES)) \
	$(patsubst %,--defsym CFG_%=1,$(SYNDEFS))

## Name the targets.

# Normalise the desired targets first.

.L_EXEFILE := 0
ifeq ($(origin EXEFILE),undefined)
# nop
else ifeq ($(origin EXEFILE),default)
# nop
else ifeq ($(origin EXEFILE),command line)
# nop
else ifeq ($(strip $(EXEFILE)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_EXEFILE := 1
endif

.L_SOFILE := 0
ifeq ($(origin SOFILE),undefined)
# nop
else ifeq ($(origin SOFILE),default)
# nop
else ifeq ($(origin SOFILE),command line)
# nop
else ifeq ($(strip $(SOFILE)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_SOFILE := 1
endif

.L_AFILE := 0
ifeq ($(origin AFILE),undefined)
# nop
else ifeq ($(origin AFILE),default)
# nop
else ifeq ($(origin AFILE),command line)
# nop
else ifeq ($(strip $(AFILE)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_AFILE := 1
endif

# Populated below.
.L_TARGETS :=

# specify all target filenames
.L_GBATARGET  := $(PROJECT).gba
.L_EXETARGET  := $(PROJECT)$(EXE)
.L_SOTARGET   := lib$(PROJECT)$(SO)
.L_ATARGET    := lib$(PROJECT).a

ifeq ($(TP),GBA)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_GBATARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
else ifeq ($(TP),IBMPC)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_EXETARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
else ifeq ($(TP),APE)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_EXETARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
else
# Platforms with shared library support
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_EXETARGET)
endif
ifeq ($(.L_SOFILE),1)
.L_TARGETS += $(.L_SOTARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
endif

# always used by make clean
.L_ALLTARGETS := \
	lib$(PROJECT)$(SO.LINUX) \
	lib$(PROJECT)$(SO.DARWIN) \
	lib$(PROJECT)$(SO.WIN32) \
	lib$(PROJECT).a \
	$(PROJECT).gba \
	$(PROJECT)$(EXE.LINUX) \
	$(PROJECT)$(EXE.WIN32) \
	$(PROJECT)$(EXE.GBA) \
	$(PROJECT)$(EXE.IBMPC)

## Define the OFILES.

.L_OFILES.COMMON := \
	$(SFILES:.s=.s.o) \
	$(CFILES:.c=.c.o) \
	$(CPPFILES:.cpp=.cpp.o)

.L_OFILES.LINUX := \
	$(SFILES.:.s=.s.o) \
	$(CFILES.:.c=.c.o) \
	$(CPPFILES.:.cpp=.cpp.o)

.L_OFILES.DARWIN := \
	$(SFILES.DARWIN:.s=.s.o) \
	$(CFILES.DARWIN:.c=.c.o) \
	$(CPPFILES.DARWIN:.cpp=.cpp.o)

.L_OFILES.WIN32 := \
	$(SFILES.WIN32:.s=.s.o) \
	$(CFILES.WIN32:.c=.c.o) \
	$(CPPFILES.WIN32:.cpp=.cpp.o)

.L_OFILES.WIN64 := \
	$(SFILES.WIN64:.s=.s.o) \
	$(CFILES.WIN64:.c=.c.o) \
	$(CPPFILES.WIN64:.cpp=.cpp.o)

.L_OFILES.GBA := \
	$(SFILES.GBA:.s=.s.o) \
	$(CFILES.GBA:.c=.c.o) \
	$(CPPFILES.GBA:.cpp=.cpp.o)

.L_OFILES.IBMPC := \
	$(SFILES.IBMPC:.s=.s.o) \
	$(CFILES.IBMPC:.c=.c.o) \
	$(CPPFILES.IBMPC:.cpp=.cpp.o)

.L_OFILES.APE := \
	$(SFILES.APE:.s=.s.o) \
	$(CFILES.APE:.c=.c.o) \
	$(CPPFILES.APE:.cpp=.cpp.o)

.L_OFILES := $(.L_OFILES.COMMON) $(.L_OFILES.$(TP))

## Define the GCNOFILES and GCDAFILES.

.L_GCNOFILES.COMMON := \
	$(CFILES:.c=.c.gcno) \
	$(CPPFILES:.cpp=.cpp.gcno)

.L_GCNOFILES.LINUX := \
	$(CFILES.:.c=.c.gcno) \
	$(CPPFILES.:.cpp=.cpp.gcno)

.L_GCNOFILES.DARWIN := \
	$(CFILES.DARWIN:.c=.c.gcno) \
	$(CPPFILES.DARWIN:.cpp=.cpp.gcno)

.L_GCNOFILES.WIN32 := \
	$(CFILES.WIN32:.c=.c.gcno) \
	$(CPPFILES.WIN32:.cpp=.cpp.gcno)

.L_GCNOFILES.WIN64 := \
	$(CFILES.WIN64:.c=.c.gcno) \
	$(CPPFILES.WIN64:.cpp=.cpp.gcno)

.L_GCNOFILES.GBA := \
	$(CFILES.GBA:.c=.c.gcno) \
	$(CPPFILES.GBA:.cpp=.cpp.gcno)

.L_GCNOFILES.IBMPC := \
	$(CFILES.IBMPC:.c=.c.gcno) \
	$(CPPFILES.IBMPC:.cpp=.cpp.gcno)

.L_GCNOFILES.APE := \
	$(CFILES.APE:.c=.c.gcno) \
	$(CPPFILES.APE:.cpp=.cpp.gcno)

.L_GCDAFILES.COMMON := \
	$(CFILES:.c=.c.gcda) \
	$(CPPFILES:.cpp=.cpp.gcda)

.L_GCDAFILES.LINUX := \
	$(CFILES.:.c=.c.gcda) \
	$(CPPFILES.:.cpp=.cpp.gcda)

.L_GCDAFILES.DARWIN := \
	$(CFILES.DARWIN:.c=.c.gcda) \
	$(CPPFILES.DARWIN:.cpp=.cpp.gcda)

.L_GCDAFILES.WIN32 := \
	$(CFILES.WIN32:.c=.c.gcda) \
	$(CPPFILES.WIN32:.cpp=.cpp.gcda)

.L_GCDAFILES.WIN64 := \
	$(CFILES.WIN64:.c=.c.gcda) \
	$(CPPFILES.WIN64:.cpp=.cpp.gcda)

.L_GCDAFILES.GBA := \
	$(CFILES.GBA:.c=.c.gcda) \
	$(CPPFILES.GBA:.cpp=.cpp.gcda)

.L_GCDAFILES.IBMPC := \
	$(CFILES.IBMPC:.c=.c.gcda) \
	$(CPPFILES.IBMPC:.cpp=.cpp.gcda)

.L_GCDAFILES.APE := \
	$(CFILES.APE:.c=.c.gcda) \
	$(CPPFILES.APE:.cpp=.cpp.gcda)

## Define the target recipes.

.PHONY: debug release check cov asan ubsan format clean

## Debug build
## useful for: normal testing, valgrind, LLDB
##
# ensure NDEBUG is undefined
debug: .L_DEFINE += -UNDEBUG
debug: UNDEFINES += NDEBUG
debug: ASFLAGS += $(ASFLAGS.DEBUG.ALL.$(TC)) $(ASFLAGS.DEBUG.$(TP).$(TC))
debug: CFLAGS += $(CFLAGS.DEBUG.ALL.$(TC)) $(CFLAGS.DEBUG.$(TP).$(TC))
debug: CXXFLAGS += $(CXXFLAGS.DEBUG.ALL.$(TC)) $(CXXFLAGS.DEBUG.$(TP).$(TC))
debug: LDFLAGS += $(LDFLAGS.DEBUG.ALL.$(TC)) $(LDFLAGS.DEBUG.$(TP).$(TC))
# nop out strip when not used, as $(REALSTRIP) is called unconditionally
debug: REALSTRIP := ':' ; # : is a no-op
debug: $(.L_TARGETS)

## Release build
## useful for: deployment
##
# ensure NDEBUG is defined
release: .L_DEFINE += -DNDEBUG=1
release: .L_ASDEFINE += --defsym NDEBUG=1
release: DEFINES += NDEBUG
release: ASFLAGS += $(ASFLAGS.RELEASE.ALL.$(TC)) \
	$(ASFLAGS.RELEASE.$(TP).$(TC))
release: CFLAGS += $(CFLAGS.RELEASE.ALL.$(TC)) \
	$(CFLAGS.RELEASE.$(TP).$(TC))
release: CXXFLAGS += $(CXXFLAGS.RELEASE.ALL.$(TC)) \
	$(CXXFLAGS.RELEASE.$(TP).$(TC))
release: LDFLAGS += $(LDFLAGS.RELEASE.ALL.$(TC)) \
	$(LDFLAGS.RELEASE.$(TP).$(TC))
release: REALSTRIP := $(STRIP)
release: $(.L_TARGETS)

## Sanity check build
## useful for: pre-tool bug squashing
##
# ensure NDEBUG is undefined
check: .L_DEFINE += -UNDEBUG
check: UNDEFINES += NDEBUG
check: ASFLAGS += $(ASFLAGS.CHECK.ALL.$(TC)) $(ASFLAGS.CHECK.$(TP).$(TC))
check: CFLAGS += $(CFLAGS.CHECK.ALL.$(TC)) $(CFLAGS.CHECK.$(TP).$(TC))
check: CXXFLAGS += $(CXXFLAGS.CHECK.ALL.$(TC)) $(CXXFLAGS.CHECK.$(TP).$(TC))
check: LDFLAGS += $(LDFLAGS.CHECK.ALL.$(TC)) $(LDFLAGS.CHECK.$(TP).$(TC))
# nop out strip when not used, as $(REALSTRIP) is called unconditionally
check: REALSTRIP := ':' ; # : is a no-op
check: $(.L_TARGETS)

## Code coverage build
## useful for: checking coverage of test suite
##
# ensure NDEBUG is undefined, add a #define for code coverage & TES
cov: .L_DEFINE += -UNDEBUG -D_CODECOV=1
cov: .L_ASDEFINE += --defsym _CODECOV=1
cov: DEFINES += _CODECOV=1
cov: UNDEFINES += NDEBUG
cov: ASFLAGS += $(ASFLAGS.COV.ALL.$(TC)) $(ASFLAGS.COV.$(TP).$(TC))
cov: CFLAGS += $(CFLAGS.COV.ALL.$(TC)) $(CFLAGS.COV.$(TP).$(TC))
cov: CXXFLAGS += $(CXXFLAGS.COV.ALL.$(TC)) $(CXXFLAGS.COV.$(TP).$(TC))
cov: LDFLAGS += $(LDFLAGS.COV.ALL.$(TC)) $(LDFLAGS.COV.$(TP).$(TC))
# nop out strip when not used, as $(REALSTRIP) is called unconditionally
cov: REALSTRIP := ':' ; # : is a no-op
cov: $(.L_EXETARGET)

## Address sanitised build
## useful for: squashing memory issues
##
# ensure NDEBUG is undefined, add a #define for address sanitisation & TES
asan: .L_DEFINE += -UNDEBUG -D_ASAN=1
asan: .L_ASDEFINE += --defsym _ASAN=1
asan: DEFINES += _ASAN=1
asan: UNDEFINES += NDEBUG
asan: ASFLAGS += $(ASFLAGS.ASAN.ALL.$(TC)) $(ASFLAGS.ASAN.$(TP).$(TC))
asan: CFLAGS += $(CFLAGS.ASAN.ALL.$(TC)) $(CFLAGS.ASAN.$(TP).$(TC))
asan: CXXFLAGS += $(CXXFLAGS.ASAN.ALL.$(TC)) $(CXXFLAGS.ASAN.$(TP).$(TC))
asan: LDFLAGS += $(LDFLAGS.ASAN.ALL.$(TC)) $(LDFLAGS.ASAN.$(TP).$(TC))
# nop out strip when not used, as $(REALSTRIP) is called unconditionally
asan: REALSTRIP := ':' ; # : is a no-op
asan: $(.L_EXETARGET)

## Undefined Behaviour sanitised build
## useful for: squashing UB :-)
##
# ensure NDEBUG is undefined, add a #define for UB sanitisation & TES
ubsan: .L_DEFINE += -UNDEBUG -D_UBSAN=1
ubsan: .L_ASDEFINE += --defsym _UBSAN=1
ubsan: DEFINES += _UBSAN=1
ubsan: UNDEFINES += NDEBUG
ubsan: ASFLAGS += $(ASFLAGS.UBSAN.ALL.$(TC)) $(ASFLAGS.UBSAN.$(TP).$(TC))
ubsan: CFLAGS += $(CFLAGS.UBSAN.ALL.$(TC)) $(CFLAGS.UBSAN.$(TP).$(TC))
ubsan: CXXFLAGS += $(CXXFLAGS.UBSAN.ALL.$(TC)) $(CXXFLAGS.UBSAN.$(TP).$(TC))
ubsan: LDFLAGS += $(LDFLAGS.UBSAN.ALL.$(TC)) $(LDFLAGS.UBSAN.$(TP).$(TC))
# nop out strip when not used, as $(REALSTRIP) is called unconditionally
ubsan: REALSTRIP := ':' ; # : is a no-op
ubsan: $(.L_EXETARGET)

## Define recipes.

# Ofile recipes.

%.cst.o: %.cst
	$(call .L_File,CST,$@)
	@$(CST) -c -o $@ $(CSTFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

%.cpp.o: %.cpp
	$(call .L_File,CXX,$@)
	@$(CXX) -c -o $@ $(CXXFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

%.c.o: %.c
	$(call .L_File,C,$@)
	@$(CC) -c -o $@ $(CFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

%.s.o: %.s
	$(call .L_File,S,$@)
	@$(AS) -o $@ $(ASFLAGS) $(.K_ASDEFINE) $(.K_ASINCLUDE) $<

# Static library recipe.

$(.L_ATARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,AR,$@)
	@$(AR) $(ARFLAGS) $@ $^
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# Shared library recipe.

$(.L_SOTARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -shared -o $@ $^ $(LIB)
	$(call .L_File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# Executable recipe.

$(.L_EXETARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -o $@ $^ $(LIB)
	$(call .L_File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# GBA ROM recipe.

$(GBATARGET): $(EXETARGET)
ifeq ($(strip $(TP)),GBA)
	$(call .L_File,OCPY,$@)
	@$(OCPY) -O binary $< $@
	$(call .L_File,FIX,$@)
	@$(FIX) $@ $(FIXFLAGS) 1>/dev/null
endif

## Additional .PHONY targets.

# Clean the repository.

clean:
	@$(ECHO) -e " -> \033[37mCleaning\033[0m the repository..."
	@$(RM) $(.L_ALLTARGETS)
	@$(RM) $(.L_OFILES.COMMON)
	@$(RM) $(.L_OFILES.LINUX)
	@$(RM) $(.L_OFILES.DARWIN)
	@$(RM) $(.L_OFILES.WIN32)
	@$(RM) $(.L_OFILES.WIN64)
	@$(RM) $(.L_OFILES.GBA)
	@$(RM) $(.L_OFILES.IBMPC)
	@$(RM) $(.L_OFILES.APE)
	@$(RM) $(.L_GCNOFILES.COMMON)
	@$(RM) $(.L_GCNOFILES.LINUX)
	@$(RM) $(.L_GCNOFILES.DARWIN)
	@$(RM) $(.L_GCNOFILES.WIN32)
	@$(RM) $(.L_GCNOFILES.WIN64)
	@$(RM) $(.L_GCNOFILES.GBA)
	@$(RM) $(.L_GCNOFILES.IBMPC)
	@$(RM) $(.L_GCNOFILES.APE)
	@$(RM) $(.L_GCDAFILES.COMMON)
	@$(RM) $(.L_GCDAFILES.LINUX)
	@$(RM) $(.L_GCDAFILES.DARWIN)
	@$(RM) $(.L_GCDAFILES.WIN32)
	@$(RM) $(.L_GCDAFILES.WIN64)
	@$(RM) $(.L_GCDAFILES.GBA)
	@$(RM) $(.L_GCDAFILES.IBMPC)
	@$(RM) $(.L_GCDAFILES.APE)

# Auto-format the sources.

format: $(CFILES) $(CPPFILES) $(HFILES) $(HPPFILES) $(PUBHFILES) \
$(PRVHFILES) $(CFILES.LINUX) $(CPPFILES.LINUX) \
$(CFILES.DARWIN) $(CPPFILES.DARWIN) \
$(CFILES.WIN32) $(CPPFILES.WIN32) \
$(CFILES.WIN64) $(CPPFILES.WIN64) \
$(CFILES.GBA) $(CPPFILES.GBA) \
$(CFILES.IBMPC) $(CPPFILES.IBMPC) \
$(CFILES.APE) $(CPPFILES.APE)
	@for _file in $^; do \
		$(call .L_FileNoAt,FMT,$$_file) ; \
		$(FMT) -i -style=file $$_file ; \
	done
	@unset _file

# Install the software into the system.

# temporary fix
PREFIX ?= /usr

install: $(TARGETS)
	-[ -n "$(EXEFILE)" ] && $(INSTALL) -Dm755 $(EXETARGET) $(PREFIX)/bin/$(EXETARGET)
	-[ -n "$(SOFILE)" ] && $(INSTALL) -Dm755 $(SOTARGET) $(PREFIX)/lib/$(SOTARGET)
	-[ -n "$(AFILE)" ] && $(INSTALL) -Dm644 $(ATARGET) $(PREFIX)/lib/$(ATARGET)
	for _file in $(PUBHFILES); do \
	$(CP) -rp --parents $$_file $(PREFIX)/; done
	unset _file

# EOF
