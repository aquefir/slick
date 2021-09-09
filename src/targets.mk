#!/usr/bin/make
# -*- coding: utf-8 -*-
## Copyright (C) 2020-2021 Aquefir.
## Released under BSD-2-Clause.
## This Makefile provides the bodies of a variety of build targets (or
## 'recipes') normally used in building native executables and libraries.
## These include: debug, release, sanity check, code coverage, and address
## sanitisation tunings. Using the conventional *FILES and *FLAGS Makefile
## variables, the toolchain program variables (like '$(CC)'), the $(PROJECT)
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

## DEPRECATION: <https://github.com/aquefir/slick/issues/13>
ifdef APE_LDSCR
$(warning APE_LDSCR is deprecated. Cosmopolitan ships with Slick now.)
endif
ifdef APE_AFILE
$(warning APE_AFILE is deprecated. Cosmopolitan ships with Slick now.)
endif
ifdef APE_HFILE
$(warning APE_HFILE is deprecated. Cosmopolitan ships with Slick now.)
endif
ifdef APE_APEO
$(warning APE_APEO is deprecated. Cosmopolitan ships with Slick now.)
endif
ifdef APE_CRTO
$(warning APE_CRTO is deprecated. Cosmopolitan ships with Slick now.)
endif

## Variable printout function code.

ifeq ($(SLICK_PRINT),0)
.L_PRINTOUT :=
else
.L_TAG.DEFAULT := [default]
.L_TAG.CUSTOM  := [custom!]
.L_Item = $(info $(.L_TAG.$(.O_$(1))) $(2) :: $($(1)))

.L_PRINTOUT = \
	$(info =====) \
	$(info ===== BUILD SETTINGS PRINTOUT) \
	$(info =====) \
	$(info ) \
	$(info ----- ENVIRONMENT) \
	$(call .L_Item,$(1),UNAME) \
	$(call .L_Item,$(2),TP) \
	$(call .L_Item,$(3),TC) \
	$(call .L_Item,$(4),TROOT) \
	$(call .L_Item,$(5),EXE) \
	$(call .L_Item,$(6),SO) \
	$(info ----- TOOLS) \
	$(call .L_Item,$(7),FMT) \
	$(call .L_Item,$(8),AS) \
	$(call .L_Item,$(9),CC) \
	$(call .L_Item,$(10),CXX) \
	$(call .L_Item,$(11),AR) \
	$(call .L_Item,$(12),OCPY) \
	$(call .L_Item,$(13),STRIP) \
	$(info ----- FLAGS AND OPTIONS) \
	$(call .L_Item,$(14),ASFLAGS) \
	$(call .L_Item,$(15),CFLAGS) \
	$(call .L_Item,$(16),CXXFLAGS) \
	$(call .L_Item,$(17),ARFLAGS) \
	$(call .L_Item,$(18),LDFLAGS) \
	$(call .L_Item,$(19),DEFINES) \
	$(call .L_Item,$(20),UNDEFINES) \
	$(call .L_Item,$(21),SYNDEFS) \
	$(call .L_Item,$(22),LIBS) \
	$(call .L_Item,$(23),LIBDIRS)
endif
.L_TPRINTOUT = $(call .L_PRINTOUT,.K_UNAME,TP,TC,TROOT,EXE,SO,FMT,AS,CC,CXX,\
	AR,OCPY,STRIP,$(1),$(2),$(3),ARFLAGS,$(4),$(5),$(6),SYNDEFS,$(7),$(8),)

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
.L_File.BIN   := ---> \033[32mProcessing

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

# PROFFLAGS
.L_PROFFLAGS := \
	$(PROFFLAGS.COMMON.ALL.$(TC)) \
	$(PROFFLAGS.COMMON.$(TP).$(TC))
ifeq ($(origin PROFFLAGS),undefined)
# nop
else ifeq ($(origin PROFFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_PROFFLAGS += $(PROFFLAGS)
endif

# COVFLAGS
.L_COVFLAGS := \
	$(COVFLAGS.COMMON.ALL.$(TC)) \
	$(COVFLAGS.COMMON.$(TP).$(TC))
ifeq ($(origin COVFLAGS),undefined)
# nop
else ifeq ($(origin COVFLAGS),default)
# nop
else
# environment [override], file, command line, override, automatic
.L_COVFLAGS += $(COVFLAGS)
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

ifeq ($(origin PROFFLAGS),undefined)
# nop
else ifeq ($(origin PROFFLAGS),default)
# nop
else ifeq ($(origin PROFFLAGS),command line)
# nop
else ifeq ($(strip $(PROFFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_PROFFLAGS := $(PROFFLAGS)
endif

ifeq ($(origin COVFLAGS),undefined)
# nop
else ifeq ($(origin COVFLAGS),default)
# nop
else ifeq ($(origin COVFLAGS),command line)
# nop
else ifeq ($(strip $(COVFLAGS)),)
# nop
else
# environment [override], file, override, automatic
# not empty
.L_COVFLAGS := $(COVFLAGS)
endif

endif

# Finally, set the variables.
ASFLAGS   := $(.L_ASFLAGS)
CFLAGS    := $(.L_CFLAGS)
CXXFLAGS  := $(.L_CXXFLAGS)
ARFLAGS   := $(.L_ARFLAGS)
LDFLAGS   := $(.L_LDFLAGS)
PROFFLAGS := $(.L_PROFFLAGS)
COVFLAGS  := $(.L_COVFLAGS)
SYNDEFS   := $(.L_SYNDEFS)

# Add the appropriate APE files as present.
ifeq ($(TP),APE)
LDFLAGS += -Wl,-T,$(AQ)/lib/slick/cosmo/ape.lds
ASFLAGS += -include $(AQ)/lib/slick/cosmo/cosmopolitan.h
CFLAGS += -include $(AQ)/lib/slick/cosmo/cosmopolitan.h
CXXFLAGS += -include $(AQ)/lib/slick/cosmo/cosmopolitan.h
else ifeq ($(TP),IBMPC)
LDFLAGS += -Wl,-T,$(AQ)/lib/slick/ibmpc/ibmpc.ld
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

.K_LIB := -L$(TROOT)/lib \
	$(patsubst %,-L%,$(LIBDIRS)) \
	$(patsubst %,-L%,$(patsubst %,$(3PLIBDIR)/%lib,$(3PLIBS))) \
	$(patsubst %,-l%,$(LIBS)) \
	$(patsubst %,-l%,$(3PLIBS))
ifeq ($(TP),APE)
.K_LIB += $(AQ)/lib/slick/cosmo/crt.o
.K_LIB += $(AQ)/lib/slick/cosmo/ape.o
.K_LIB += $(AQ)/lib/slick/cosmo/cosmopolitan.a
else ifeq ($(TP),IBMPC)
.K_LIB += $(AQ)/lib/slick/ibmpc/crt0.o
endif

# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(CC)),tcc)
.K_INCLUDE := -I$(TROOT)/include \
	$(patsubst %,-I%,$(INCLUDES)) \
	$(patsubst %,-I%,$(INCLUDEL)) \
	$(patsubst %,-I%,$(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS)))
else
.K_INCLUDE := -isystem $(TROOT)/include \
	$(patsubst %,-isystem %,$(INCLUDES)) \
	$(patsubst %,-iquote %,$(INCLUDEL)) \
	$(patsubst %,-isystem %,$(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS)))
endif

.K_ASINCLUDE := -I$(TROOT)/include \
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
.L_BINTARGET  := $(PROJECT)$(BIN)
.L_EXETARGET  := $(PROJECT)$(EXE)
.L_SOTARGET   := lib$(PROJECT)$(SO)
.L_ATARGET    := lib$(PROJECT).a

ifeq ($(TP),GBA)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_BINTARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
else ifeq ($(TP),GBASP)
.L_TARGETS += $(.L_BINTARGET)
else ifeq ($(TP),IBMPC)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_BINTARGET)
endif
ifeq ($(.L_AFILE),1)
.L_TARGETS += $(.L_ATARGET)
endif
else ifeq ($(TP),APE)
ifeq ($(.L_EXEFILE),1)
.L_TARGETS += $(.L_BINTARGET)
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
	$(PROJECT)$(BIN.LINUX) \
	$(PROJECT)$(BIN.GBA) \
	$(PROJECT)$(BIN.IBMPC) \
	$(PROJECT)$(EXE.LINUX) \
	$(PROJECT)$(EXE.WIN32) \
	$(PROJECT)$(EXE.GBA) \
	$(PROJECT)$(EXE.GBASP) \
	$(PROJECT)$(EXE.APE)

## Define the OFILES.

.L_OFILES.COMMON := \
	$(SFILES:.s=.s.o) \
	$(CFILES:.c=.c.o) \
	$(CPPFILES:.cpp=.cpp.o) \
	$(SNIPFILES:.snip=.snip.o) \
	$(MAPFILES:.map=.map.o) \
	$(MAPBFILES:.mapb=.mapb.o) \
	$(BSAFILES:.bsa=.bsa.o) \
	$(BSETFILES:.bset=.bset.o) \
	$(JASCFILES:.jasc=.jasc.o) \
	$(IMGFILES:.png=.png.o)

.L_OFILES.LINUX := \
	$(SFILES.LINUX:.s=.s.o) \
	$(CFILES.LINUX:.c=.c.o) \
	$(CPPFILES.LINUX:.cpp=.cpp.o)

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
	$(CPPFILES.GBA:.cpp=.cpp.o) \
	$(SNIPFILES.GBASP:.snip=.snip.o)

.L_OFILES.GBASP := \
	$(SFILES.GBASP:.s=.s.o) \
	$(CFILES.GBASP:.c=.c.o) \
	$(CPPFILES.GBASP:.cpp=.cpp.o) \
	$(SNIPFILES.GBASP:.snip=.snip.o) \
	$(MAPFILES.GBASP:.map=.map.o) \
	$(MAPBFILES.GBASP:.mapb=.mapb.o) \
	$(BSAFILES.GBASP:.bsa=.bsa.o) \
	$(BSETFILES.GBASP:.bset=.bset.o) \
	$(JASCFILES.GBASP:.jasc=.jasc.o) \
	$(IMGFILES.GBASP:.png=.png.o)

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
	$(CPPFILES:.cpp=.cpp.gcno) \
	$(TES_CFILES:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.LINUX := \
	$(CFILES.LINUX:.c=.c.gcno) \
	$(CPPFILES.LINUX:.cpp=.cpp.gcno) \
	$(TES_CFILES.LINUX:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.LINUX:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.DARWIN := \
	$(CFILES.DARWIN:.c=.c.gcno) \
	$(CPPFILES.DARWIN:.cpp=.cpp.gcno) \
	$(TES_CFILES.DARWIN:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.DARWIN:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.WIN32 := \
	$(CFILES.WIN32:.c=.c.gcno) \
	$(CPPFILES.WIN32:.cpp=.cpp.gcno) \
	$(TES_CFILES.WIN32:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.WIN32:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.WIN64 := \
	$(CFILES.WIN64:.c=.c.gcno) \
	$(CPPFILES.WIN64:.cpp=.cpp.gcno) \
	$(TES_CFILES.WIN64:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.WIN64:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.GBA := \
	$(CFILES.GBA:.c=.c.gcno) \
	$(CPPFILES.GBA:.cpp=.cpp.gcno) \
	$(TES_CFILES.GBA:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.GBA:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.GBASP := \
	$(CFILES.GBASP:.c=.c.gcno) \
	$(CPPFILES.GBASP:.cpp=.cpp.gcno) \
	$(TES_CFILES.GBASP:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.GBASP:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.IBMPC := \
	$(CFILES.IBMPC:.c=.c.gcno) \
	$(CPPFILES.IBMPC:.cpp=.cpp.gcno) \
	$(TES_CFILES.IBMPC:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.IBMPC:.tes.cpp=.tes.cpp.gcno)

.L_GCNOFILES.APE := \
	$(CFILES.APE:.c=.c.gcno) \
	$(CPPFILES.APE:.cpp=.cpp.gcno) \
	$(TES_CFILES.APE:.tes.c=.tes.c.gcno) \
	$(TES_CPPFILES.APE:.tes.cpp=.tes.cpp.gcno)

.L_GCDAFILES.COMMON := \
	$(CFILES:.c=.c.gcda) \
	$(CPPFILES:.cpp=.cpp.gcda) \
	$(TES_CFILES:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.LINUX := \
	$(CFILES.LINUX:.c=.c.gcda) \
	$(CPPFILES.LINUX:.cpp=.cpp.gcda) \
	$(TES_CFILES.LINUX:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.LINUX:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.DARWIN := \
	$(CFILES.DARWIN:.c=.c.gcda) \
	$(CPPFILES.DARWIN:.cpp=.cpp.gcda) \
	$(TES_CFILES.DARWIN:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.DARWIN:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.WIN32 := \
	$(CFILES.WIN32:.c=.c.gcda) \
	$(CPPFILES.WIN32:.cpp=.cpp.gcda) \
	$(TES_CFILES.WIN32:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.WIN32:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.WIN64 := \
	$(CFILES.WIN64:.c=.c.gcda) \
	$(CPPFILES.WIN64:.cpp=.cpp.gcda) \
	$(TES_CFILES.WIN64:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.WIN64:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.GBA := \
	$(CFILES.GBA:.c=.c.gcda) \
	$(CPPFILES.GBA:.cpp=.cpp.gcda) \
	$(TES_CFILES.GBA:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.GBA:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.GBASP := \
	$(CFILES.GBASP:.c=.c.gcda) \
	$(CPPFILES.GBASP:.cpp=.cpp.gcda) \
	$(TES_CFILES.GBASP:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.GBASP:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.IBMPC := \
	$(CFILES.IBMPC:.c=.c.gcda) \
	$(CPPFILES.IBMPC:.cpp=.cpp.gcda) \
	$(TES_CFILES.IBMPC:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.IBMPC:.tes.cpp=.tes.cpp.gcda)

.L_GCDAFILES.APE := \
	$(CFILES.APE:.c=.c.gcda) \
	$(CPPFILES.APE:.cpp=.cpp.gcda) \
	$(TES_CFILES.APE:.tes.c=.tes.c.gcda) \
	$(TES_CPPFILES.APE:.tes.cpp=.tes.cpp.gcda)

## Define the TES battery target files.

.L_TESFILES.COMMON := \
	$(TES_SFILES:.tes.s=.s.tes) \
	$(TES_CFILES:.tes.c=.c.tes) \
	$(TES_CPPFILES:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES:.tes.cst=.cst.tes)

.L_TESFILES.LINUX := \
	$(TES_SFILES.LINUX:.tes.s=.s.tes) \
	$(TES_CFILES.LINUX:.tes.c=.c.tes) \
	$(TES_CPPFILES.LINUX:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.LINUX:.tes.cst=.cst.tes)

.L_TESFILES.DARWIN := \
	$(TES_SFILES.DARWIN:.tes.s=.s.tes) \
	$(TES_CFILES.DARWIN:.tes.c=.c.tes) \
	$(TES_CPPFILES.DARWIN:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.DARWIN:.tes.cst=.cst.tes)

.L_TESFILES.WIN32 := \
	$(TES_SFILES.WIN32:.tes.s=.s.tes) \
	$(TES_CFILES.WIN32:.tes.c=.c.tes) \
	$(TES_CPPFILES.WIN32:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.WIN32:.tes.cst=.cst.tes)

.L_TESFILES.WIN64 := \
	$(TES_SFILES.WIN64:.tes.s=.s.tes) \
	$(TES_CFILES.WIN64:.tes.c=.c.tes) \
	$(TES_CPPFILES.WIN64:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.WIN64:.tes.cst=.cst.tes)

.L_TESFILES.GBA := \
	$(TES_SFILES.GBA:.tes.s=.s.tes) \
	$(TES_CFILES.GBA:.tes.c=.c.tes) \
	$(TES_CPPFILES.GBA:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.GBA:.tes.cst=.cst.tes)

.L_TESFILES.IBMPC := \
	$(TES_SFILES.IBMPC:.tes.s=.s.tes) \
	$(TES_CFILES.IBMPC:.tes.c=.c.tes) \
	$(TES_CPPFILES.IBMPC:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.IBMPC:.tes.cst=.cst.tes)

.L_TESFILES.APE := \
	$(TES_SFILES.APE:.tes.s=.s.tes) \
	$(TES_CFILES.APE:.tes.c=.c.tes) \
	$(TES_CPPFILES.APE:.tes.cpp=.cpp.tes) \
	$(TES_CSTFILES.APE:.tes.cst=.cst.tes)

.L_TES_OFILES.COMMON := \
	$(TES_SFILES:.tes.s=.tes.s.o) \
	$(TES_CFILES:.tes.c=.tes.c.o) \
	$(TES_CPPFILES:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES:.tes.cst=.tes.cst.o)

.L_TES_OFILES.LINUX := \
	$(TES_SFILES.LINUX:.tes.s=.tes.s.o) \
	$(TES_CFILES.LINUX:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.LINUX:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.LINUX:.tes.cst=.tes.cst.o)

.L_TES_OFILES.DARWIN := \
	$(TES_SFILES.DARWIN:.tes.s=.tes.s.o) \
	$(TES_CFILES.DARWIN:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.DARWIN:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.DARWIN:.tes.cst=.tes.cst.o)

.L_TES_OFILES.WIN32 := \
	$(TES_SFILES.WIN32:.tes.s=.tes.s.o) \
	$(TES_CFILES.WIN32:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.WIN32:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.WIN32:.tes.cst=.tes.cst.o)

.L_TES_OFILES.WIN64 := \
	$(TES_SFILES.WIN64:.tes.s=.tes.s.o) \
	$(TES_CFILES.WIN64:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.WIN64:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.WIN64:.tes.cst=.tes.cst.o)

.L_TES_OFILES.GBA := \
	$(TES_SFILES.GBA:.tes.s=.tes.s.o) \
	$(TES_CFILES.GBA:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.GBA:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.GBA:.tes.cst=.tes.cst.o)

.L_TES_OFILES.IBMPC := \
	$(TES_SFILES.IBMPC:.tes.s=.tes.s.o) \
	$(TES_CFILES.IBMPC:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.IBMPC:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.IBMPC:.tes.cst=.tes.cst.o)

.L_TES_OFILES.APE := \
	$(TES_SFILES.APE:.tes.s=.tes.s.o) \
	$(TES_CFILES.APE:.tes.c=.tes.c.o) \
	$(TES_CPPFILES.APE:.tes.cpp=.tes.cpp.o) \
	$(TES_CSTFILES.APE:.tes.cst=.tes.cst.o)

.L_TESFILES := $(.L_TESFILES.COMMON) $(.L_TESFILES.$(TP))

## Define the target recipes.

.PHONY: debug release check cov asan ubsan report clean format install
# Remove all default implicit rules by emptying the suffixes builtin
# This causes false circular dependencies with multi-dotted file extensions
#   if we don't do this
.SUFFIXES:

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
ifneq ($(strip $(NO_TES)),)
cov: $(.L_EXETARGET)
else
ifeq ($(.L_EXEFILE),1)
cov: $(.L_EXETARGET)
else
cov: $(.L_TESFILES)
endif # $(.L_TESFILES)
endif # $(NO_TES)

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
ifneq ($(strip $(NO_TES)),)
asan: $(.L_EXETARGET)
else
ifeq ($(.L_EXEFILE),1)
asan: $(.L_EXETARGET)
else
asan: $(.L_TESFILES)
endif # $(.L_TESFILES)
endif # $(NO_TES)

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
ifneq ($(strip $(NO_TES)),)
ubsan: $(.L_EXETARGET)
else
ifeq ($(.L_EXEFILE),1)
ubsan: $(.L_EXETARGET)
else
ubsan: $(.L_TESFILES)
endif # $(.L_TESFILES)
endif # $(NO_TES)

## Define recipes.

# Ofile recipes.

# C*
%.cst.o: %.cst
	$(call .L_File,CST,$@)
	@$(CST) -c -o $@ $(CSTFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

# C++
%.cpp.o: %.cpp
	$(call .L_File,CXX,$@)
	@$(CXX) -c -o $@ $(CXXFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

# C
%.c.o: %.c
	$(call .L_File,C,$@)
	@$(CC) -c -o $@ $(CFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

# Assembly
%.s.o: %.s
	$(call .L_File,S,$@)
	@$(AS) -o $@ $(ASFLAGS) $(.K_ASDEFINE) $(.K_ASINCLUDE) $<

# Blockset data
%.bset.o: %.bset
	$(call .L_File,BIN,$@)
	@$(BIN2ASM) -s `$(EGMAN) -i $<` $< | $(AS) $(ASFLAGS) -o $@ -

# Blockset attributes
%.bsa.o: %.bsa
	$(call .L_File,BIN,$@)
	@$(BIN2ASM) -s `$(EGMAN) -i $<` $< | $(AS) $(ASFLAGS) -o $@ -

# Map files
%.map.o: %.map
	$(call .L_File,BIN,$@)
	@$(BIN2ASM) -s `$(EGMAN) -i $<` $< | $(AS) $(ASFLAGS) -o $@ -

# Map border files
%.mapb.o: %.mapb
	$(call .L_File,BIN,$@)
	@$(BIN2ASM) -s `$(EGMAN) -i $<` $< | $(AS) $(ASFLAGS) -o $@ -

# Palettes
%.jasc.o: %.jasc
	$(call .L_File,IMG,$@)
	@$(JASC2BIN) $< | $(BIN2ASM) -s `$(EGMAN) -i $<` - | \
		$(AS) $(ASFLAGS) -o $@ -

# Text snips
%.snip.o: %.snip
	$(call .L_File,BIN,$@)
	@$(SNIP2BIN) $< | $(BIN2ASM) -s `$(EGMAN) -i $<` - | \
		$(AS) $(ASFLAGS) -o $@ -

# Scrips
%.scrip.o: %.scrip
	$(call .L_File,BIN,$@)
	@$(SCRIP2O) $< $@

# Image data
%.png.o: %.png
	$(call .L_File,IMG,$@)
	@$(GFX2O) $< $@

# TESfile recipes.

.L_LDFLAGS.TES := -L$(AQ)/lib -ltes

%.cst.tes: %.tes.cst.o #$(.L_OFILES)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -o $@ $< $(.K_LIB) $(.L_LDFLAGS.TES) $(.L_OFILES)

%.cpp.tes: %.tes.cpp.o #$(.L_OFILES)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -o $@ $< $(.K_LIB) $(.L_LDFLAGS.TES) $(.L_OFILES)

%.c.tes: %.tes.c.o #$(.L_OFILES)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -o $@ $< $(.K_LIB) $(.L_LDFLAGS.TES) $(.L_OFILES)

# TES ofile recipes.

%.tes.cst.o: %.tes.cst
	$(call .L_File,CST,$@)
	@$(CST) -c -o $@ $(CSTFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

%.tes.cpp.o: %.tes.cpp
	$(call .L_File,CXX,$@)
	@$(CXX) -c -o $@ $(CXXFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

%.tes.c.o: %.tes.c
	$(call .L_File,C,$@)
	@$(CC) -c -o $@ $(CFLAGS) $(.K_DEFINE) $(.K_INCLUDE) $<

# Profile data recipes.

%.profdata: %.profraw
	$(call .L_File,PROF,$@)
	@$(PROF) $(PROFFLAGS) -o $@ $<

# Static library recipe.

$(.L_ATARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,AR,$@)
	@$(AR) $(ARFLAGS) $@ $^
	$(call .L_TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES,\
	LIBS,LIBDIRS)
endif

# Shared library recipe.

$(.L_SOTARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,LD,$@)
	@$(LD) $(LDFLAGS) -shared -o $@ $^ $(.K_LIB)
	$(call .L_File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call .L_TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES,\
	LIBS,LIBDIRS)
endif

# Executable recipe.

$(.L_EXETARGET): $(.L_OFILES)
ifneq ($(strip $(.L_OFILES)),)
	$(call .L_File,LD,$@)
#	@$(ECHO) $^
	@$(LD) $(LDFLAGS) -o $@ $^ $(.K_LIB)
	$(call .L_File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call .L_TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES,\
	LIBS,LIBDIRS)
endif

# GBA ROM, APE polyglot, or DOS COMfile recipe.

ifneq ($(.L_EXETARGET),$(.L_BINTARGET))
$(.L_BINTARGET): $(.L_EXETARGET)
	$(call .L_File,OCPY,$@)
	@$(OCPY) -O binary $(PROJECT).elf $(PROJECT).bin
ifeq ($(TP),GBA)
	$(call .L_File,FIX,$@)
	@$(FIX) $@ $(FIXFLAGS) 1>/dev/null
endif
ifeq ($(TP),GBASP)
	$(call .L_File,FIX,$@)
	@$(INSERT) $(HOOKSFILE) $(ROMFILE) \
		$(PROJECT).bin $(PROJECT).elf $(PROJECT).gba
endif
endif

## Additional .PHONY targets.

# Generate code coverage reports.

report: default.profdata
	@$(ECHO) -e " -> \033[37mGenerating\033[0m code coverage reports..."
	@$(COV) $(COVFLAGS) -instr-profile="$<" $(FILE)

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
	@$(RM) $(.L_TESFILES.COMMON)
	@$(RM) $(.L_TESFILES.LINUX)
	@$(RM) $(.L_TESFILES.DARWIN)
	@$(RM) $(.L_TESFILES.WIN32)
	@$(RM) $(.L_TESFILES.WIN64)
	@$(RM) $(.L_TESFILES.GBA)
	@$(RM) $(.L_TESFILES.IBMPC)
	@$(RM) $(.L_TESFILES.APE)
	@$(RM) default.profraw default.profdata

# Auto-format the sources.

format: $(CFILES) $(CPPFILES) $(HFILES) $(HPPFILES) $(PUBHFILES) \
$(PRVHFILES) $(CFILES.LINUX) $(CPPFILES.LINUX) \
$(CFILES.DARWIN) $(CPPFILES.DARWIN) \
$(CFILES.WIN32) $(CPPFILES.WIN32) \
$(CFILES.WIN64) $(CPPFILES.WIN64) \
$(CFILES.GBA) $(CPPFILES.GBA) \
$(CFILES.GBASP) $(CPPFILES.GBASP) \
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

install: $(.L_TARGETS)
	-[ -n "$(EXEFILE)" ] && $(INSTALL) -Dm755 $(.L_EXETARGET) \
		$(PREFIX)/bin/$(.L_EXETARGET)
	-[ -n "$(SOFILE)" ] && $(INSTALL) -Dm755 $(.L_SOTARGET) \
		$(PREFIX)/lib/$(.L_SOTARGET)
	-[ -n "$(AFILE)" ] && $(INSTALL) -Dm644 $(.L_ATARGET) \
		$(PREFIX)/lib/$(.L_ATARGET)
	for _file in $(PUBHFILES); do \
	$(CP) -rp --parents $$_file $(PREFIX)/; done
	unset _file

# EOF
