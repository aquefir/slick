#!/usr/bin/make
# -*- coding: utf-8 -*-
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
.L_Soitem = $(call _Item,$(1),Shared library ext.)

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
.L_TPRINTOUT = $(call .L_PRINTOUT,.K_UNAME,TP,TC,TROOT,EXE,SO,FMT,AS,CC,CXX,
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
# environment [override], file, command line, override, automatic
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
# environment [override], file, command line, override, automatic
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
# environment [override], file, command line, override, automatic
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
# environment [override], file, command line, override, automatic
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
# environment [override], file, command line, override, automatic
# not empty
.L_LDFLAGS := $(LDFLAGS)
endif

endif

# Finally, set the variables.
override ASFLAGS  := $(.L_ASFLAGS)
override CFLAGS   := $(.L_CFLAGS)
override CXXFLAGS := $(.L_CXXFLAGS)
override ARFLAGS  := $(.L_ARFLAGS)
override LDFLAGS  := $(.L_LDFLAGS)
override SYNDEFS  := $(.L_SYNDEFS)

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
