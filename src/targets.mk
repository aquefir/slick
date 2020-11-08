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

ifdef SLICK_NOPRINT
$(warning SLICK_NOPRINT is deprecated. Please use SLICK_PRINT to see the build settings printout)
endif

ifndef SLICK_PRINT
PRINTOUT :=
else
TAG.DEFAULT := [default]
TAG.CUSTOM  := [custom!]
_Item = $(info $(TAG.$($(1)_ORIGIN)) $(2) :: $($(1)))
ifneq ($(strip $(TP)),GBA)
_Soitem = $(call _Item,$(1),Shared library ext.)
else
_Soitem :=
endif
PRINTOUT = \
	$(info =====) \
	$(info ===== BUILD SETTINGS PRINTOUT) \
	$(info =====) \
	$(info ) \
	$(info ----- ENVIRONMENT) \
	$(call _Item,$(1),Host machine) \
	$(call _Item,$(2),Target machine) \
	$(call _Item,$(3),Toolchain in use) \
	$(call _Item,$(4),Target sysroot) \
	$(call _Item,$(5),Executable ext.) \
	$(call _Soitem,$(6)) \
	$(info ----- TOOLS) \
	$(call _Item,$(7),Autoformatter) \
	$(call _Item,$(8),Assembler) \
	$(call _Item,$(9),C compiler) \
	$(call _Item,$(10),C++ compiler) \
	$(call _Item,$(11),Static archiver) \
	$(call _Item,$(12),Object copier) \
	$(call _Item,$(13),Object stripper) \
	$(info ----- FLAGS AND OPTIONS) \
	$(call _Item,$(14),Assembler flags) \
	$(call _Item,$(15),C compiler flags) \
	$(call _Item,$(16),C++ compiler flags) \
	$(call _Item,$(17),Static archiver flags) \
	$(call _Item,$(18),Linker flags) \
	$(call _Item,$(19),Defines) \
	$(call _Item,$(20),Undefines) \
	$(call _Item,$(21),Synthetics)
endif
TPRINTOUT = $(call PRINTOUT,UNAME,TP,TC,TROOT,EXE,SO,FMT,AS,CC,CXX,AR,OCPY,STRIP,$(1),$(2),$(3),ARFLAGS,$(4),$(5),$(6),CDEFS)

_File.C     := ---> \033[34mCompiling
_File.CXX   := ---> \033[33mCompiling
_File.S     := ---> \033[32mAssembling
_File.LD    := --> \033[31mLinking
_File.STRIP := -> \033[31mStripping
_File.OCPY  := -> \033[37mCopying binary of
_File.FIX   := -> \033[37mFixing
_File.FMT   := -> \033[37mFormatting
_File.MID   := ---> \033[35mProcessing
_File.PCM   := ---> \033[35mAssembling
_File.IMG   := ---> \033[33mTransmogrifying

_File = @$(ECHO) -e " $(_File.$(1))\033[0m \033[1m$(2)\033[0m ..."

##
## Additional variables
##

# 3rdparty dependencies
3PINCLUDES := $(patsubst %,$(3PLIBDIR)/%lib/include,$(3PLIBS))
3PLIBDIRS  := $(patsubst %,$(3PLIBDIR)/%lib,$(3PLIBS))

# Sysroot defaults
INCLUDES += $(TROOT)/include
LIBDIRS  += $(TROOT)/lib

# Variable transformations for command invocation
LIB := $(patsubst %,-L%,$(LIBDIRS)) $(patsubst %,-l%,$(LIBS)) \
	$(patsubst %,-L%,$(3PLIBDIRS)) $(patsubst %,-l%,$(3PLIBS))
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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

# Debug symbols
DSYMS := $(patsubst %,%.dSYM,$(TARGETS)) $(patsubst %,%.dSYM,$(TESTARGETS))

# Populated below
TARGETS :=

# No test targeting yet for the GBA
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

OFILES := $(SFILES:.s=.s.o) $(CFILES:.c=.c.o) $(CPPFILES:.cpp=.cpp.o) \
	$(PALFILES:.jasc=.jasc.o)
TES_OFILES := $(TES_SFILES:.s=.s.o) $(TES_CFILES:.c=.c.o) \
	$(TES_CPPFILES:.cpp=.cpp.o) $(TES_PALFILES:.jasc=.jasc.o)

# Add in target-specific sources
OFILES += $(SFILES.$(tsuf):.s=.s.o) $(CFILES.$(tsuf):.c=.c.o) \
	$(CPPFILES.$(tsuf):.cpp=.cpp.o) $(PALFILES.$(tsuf):.jasc=.jasc.o)
TES_OFILES += $(TES_SFILES.$(tsuf):.s=.s.o) $(TES_CFILES.$(tsuf):.c=.c.o) \
	$(TES_CPPFILES.$(tsuf):.cpp=.cpp.o) $(TES_PALFILES.$(tsuf):.jasc=.jasc.o)

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
debug: UNDEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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
release: ASDEFINE += --defsym NDEBUG=1
release: DEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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
check: UNDEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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
ifeq ($(strip $(NO_TES)),)
# ensure NDEBUG is undefined, add a #define for code coverage & TES
cov: DEFINE += -UNDEBUG -D_CODECOV=1 -DTES_BUILD=1
cov: ASDEFINE += --defsym _CODECOV=1 --defsym TES_BUILD=1
cov: DEFINES += _CODECOV=1 TES_BUILD=1
cov: UNDEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
# tcc cannot take these additional options
cov: CFLAGS += $(CFLAGS.GCOMMON.COV)
endif # tcc
cov: CXXFLAGS += $(CXXFLAGS.COMMON.COV)
cov: LDFLAGS += $(LDFLAGS.COV)
# nop out strip when not used, $(REALSTRIP) is called unconditionally
cov: REALSTRIP := ':' ; # : is a no-op
cov: $(TESTARGETS)
endif # $(NO_TES)

## Address sanitised build
## useful for: squashing memory issues
##
ifeq ($(strip $(NO_TES)),)
# ensure NDEBUG is undefined, add a #define for address sanitisation & TES
asan: DEFINE += -UNDEBUG -D_ASAN=1 -DTES_BUILD=1
asan: ASDEFINE += --defsym _ASAN=1 --defsym TES_BUILD=1
asan: DEFINES += _ASAN=1 TES_BUILD=1
asan: UNDEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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
ubsan: ASDEFINE += --defsym _ASAN=1 --defsym TES_BUILD=1
ubsan: DEFINES += _ASAN=1 TES_BUILD=1
ubsan: UNDEFINES += NDEBUG
# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
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

# Ofile recipes
%.cpp.o: %.cpp
	$(call _File,CXX,$@)
	@$(CXX) -c -o $@ $(CXXFLAGS) $(DEFINE) $(INCLUDE) $<

%.c.o: %.c
	$(call _File,C,$@)
	@$(CC) -c -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $<

%.s.o: %.s
	$(call _File,S,$@)
	@$(AS) -o $@ $(ASFLAGS) $(ASDEFINE) $(ASINCLUDE) $<

%.jasc.o: %.jasc
	$(call _File,GFX,$@)
	@$(JASC2GBA) $< | $(BIN2ASM) - $@

%.tes.cpp.o: %.tes.cpp
	$(call _File,CXX,$@)
	@$(CXX) -c -o $@ $(CXXFLAGS) $(INCLUDE) $<

%.tes.c.o: %.tes.c
	$(call _File,C,$@)
	@$(CC) -c -o $@ $(CFLAGS) $(INCLUDE) $<

%.cpp.tes: %.tes.cpp.o
	$(call _File,LD,$@)
	@$(CCLD) $(LDFLAGS) -o $@ $^ $(LIB)

%.c.tes: %.tes.c.o
	$(call _File,LD,$@)
	@$(CCLD) $(LDFLAGS) -o $@ $^ $(LIB)

# Static library recipe
$(ATARGET): $(OFILES)
ifneq ($(strip $(OFILES)),)
	$(call _File,AR,$@)
	$(call _File,STRIP,$@)
	@$(REALSTRIP) -s $^
	@$(AR) $(ARFLAGS) $@ $^
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# Shared library recipe
$(SOTARGET): $(OFILES)
ifneq ($(strip $(OFILES)),)
	$(call _File,LD,$@)
	@$(CCLD) $(LDFLAGS) -shared -o $@ $^ $(LIB)
	$(call _File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# Executable recipe
$(EXETARGET): $(OFILES)
ifneq ($(strip $(OFILES)),)
	$(call _File,LD,$@)
	@$(CCLD) $(LDFLAGS) -o $@ $^ $(LIB)
	$(call _File,STRIP,$@)
	@$(REALSTRIP) -s $@
	$(call TPRINTOUT,ASFLAGS,CFLAGS,CXXFLAGS,LDFLAGS,DEFINES,UNDEFINES)
endif

# GBA ROM recipe
$(GBATARGET): $(EXETARGET)
ifeq ($(strip $(TP)),GBA)
	$(call _File,OCPY,$@)
	@$(OCPY) -O binary $< $@
	$(call _File,FIX,$@)
	@$(FIX) $@ $(FIXFLAGS) 1>/dev/null
endif

##
## Phony targets
##

# clean up the source tree
clean:
	@$(ECHO) -e " -> \033[37mCleaning\033[0m the repository..."
	@$(RM) $(ATARGET)
	@$(RM) $(SOTARGET)
	@$(RM) $(EXETARGET)
	@$(RM) $(GBATARGET)
	@$(RM) $(DLLTARGET)
	@$(RM) $(TESTARGETS)
	@$(RM) -r $(DSYMS)
	@$(RM) $(SFILES:.s=.s.o) $(CFILES:.c=.c.o) $(CPPFILES:.cpp=.cpp.o)
	@$(RM) $(CFILES:.c=.c.gcno) $(CPPFILES:.cpp=.cpp.gcno)
	@$(RM) $(CFILES:.c=.c.gcda) $(CPPFILES:.cpp=.cpp.gcda)
	@$(RM) $(SFILES.LINUX:.s=.s.o)
	@$(RM) $(CFILES.LINUX:.c=.c.o)
	@$(RM) $(CPPFILES.LINUX:.cpp=.cpp.o)
	@$(RM) $(CFILES.LINUX:.c=.c.gcno) $(CPPFILES.LINUX:.cpp=.cpp.gcno)
	@$(RM) $(CFILES.LINUX:.c=.c.gcda) $(CPPFILES.LINUX:.cpp=.cpp.gcda)
	@$(RM) $(SFILES.DARWIN:.s=.s.o)
	@$(RM) $(CFILES.DARWIN:.c=.c.o)
	@$(RM) $(CPPFILES.DARWIN:.cpp=.cpp.o)
	@$(RM) $(CFILES.DARWIN:.c=.c.gcno) $(CPPFILES.DARWIN:.cpp=.cpp.gcno)
	@$(RM) $(CFILES.DARWIN:.c=.c.gcda) $(CPPFILES.DARWIN:.cpp=.cpp.gcda)
	@$(RM) $(SFILES.WIN32:.s=.s.o)
	@$(RM) $(CFILES.WIN32:.c=.c.o)
	@$(RM) $(CPPFILES.WIN32:.cpp=.cpp.o)
	@$(RM) $(CFILES.WIN32:.c=.c.gcno) $(CPPFILES.WIN32:.cpp=.cpp.gcno)
	@$(RM) $(CFILES.WIN32:.c=.c.gcda) $(CPPFILES.WIN32:.cpp=.cpp.gcda)
	@$(RM) $(SFILES.WIN64:.s=.s.o)
	@$(RM) $(CFILES.WIN64:.c=.c.o)
	@$(RM) $(CPPFILES.WIN64:.cpp=.cpp.o)
	@$(RM) $(CFILES.WIN64:.c=.c.gcno) $(CPPFILES.WIN64:.cpp=.cpp.gcno)
	@$(RM) $(CFILES.WIN64:.c=.c.gcda) $(CPPFILES.WIN64:.cpp=.cpp.gcda)
	@$(RM) $(SFILES.GBA:.s=.s.o)
	@$(RM) $(CFILES.GBA:.c=.c.o)
	@$(RM) $(CPPFILES.GBA:.cpp=.cpp.o)
	@$(RM) $(CFILES.GBA:.c=.c.gcno) $(CPPFILES.GBA:.cpp=.cpp.gcno)
	@$(RM) $(CFILES.GBA:.c=.c.gcda) $(CPPFILES.GBA:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES:.s=.s.o) $(TES_CFILES:.c=.c.o) \
		$(TES_CPPFILES:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES:.c=.c.gcno) $(TES_CPPFILES:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES:.c=.c.gcda) $(TES_CPPFILES:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES.LINUX:.s=.s.o)
	@$(RM) $(TES_CFILES.LINUX:.c=.c.o)
	@$(RM) $(TES_CPPFILES.LINUX:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES.LINUX:.c=.c.gcno) $(TES_CPPFILES.LINUX:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES.LINUX:.c=.c.gcda) $(TES_CPPFILES.LINUX:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES.DARWIN:.s=.s.o)
	@$(RM) $(TES_CFILES.DARWIN:.c=.c.o)
	@$(RM) $(TES_CPPFILES.DARWIN:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES.DARWIN:.c=.c.gcno) $(TES_CPPFILES.DARWIN:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES.DARWIN:.c=.c.gcda) $(TES_CPPFILES.DARWIN:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES.WIN32:.s=.s.o)
	@$(RM) $(TES_CFILES.WIN32:.c=.c.o)
	@$(RM) $(TES_CPPFILES.WIN32:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES.WIN32:.c=.c.gcno) $(TES_CPPFILES.WIN32:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES.WIN32:.c=.c.gcda) $(TES_CPPFILES.WIN32:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES.WIN64:.s=.s.o)
	@$(RM) $(TES_CFILES.WIN64:.c=.c.o)
	@$(RM) $(TES_CPPFILES.WIN64:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES.WIN64:.c=.c.gcno) $(TES_CPPFILES.WIN64:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES.WIN64:.c=.c.gcda) $(TES_CPPFILES.WIN64:.cpp=.cpp.gcda)
	@$(RM) $(TES_SFILES.GBA:.s=.s.o)
	@$(RM) $(TES_CFILES.GBA:.c=.c.o)
	@$(RM) $(TES_CPPFILES.GBA:.cpp=.cpp.o)
	@$(RM) $(TES_CFILES.GBA:.c=.c.gcno) $(TES_CPPFILES.GBA:.cpp=.cpp.gcno)
	@$(RM) $(TES_CFILES.GBA:.c=.c.gcda) $(TES_CPPFILES.GBA:.cpp=.cpp.gcda)

# run the auto-formatter
ifeq ($(strip $(NO_TES)),)
format: $(TES_CFILES) $(TES_CPPFILES) $(TES_HFILES) $(TES_HPPFILES) \
	$(TES_PUBHFILES) $(TES_PRVHFILES)
endif
format: $(CFILES) $(CPPFILES) $(HFILES) $(HPPFILES) $(PUBHFILES) $(PRVHFILES)
	for _file in $^; do \
		$(call _File,FMT,$$_file) \
		$(FMT) -i -style=file $$_file ; \
	done
	unset _file

# install the software into the system
install: $(TARGETS)
	-[ -n "$(EXEFILE)" ] && $(INSTALL) -Dm755 $(EXETARGET) $(PREFIX)/bin/$(EXETARGET)
	-[ -n "$(SOFILE)" ] && $(INSTALL) -Dm755 $(SOTARGET) $(PREFIX)/lib/$(SOTARGET)
	-[ -n "$(AFILE)" ] && $(INSTALL) -Dm644 $(ATARGET) $(PREFIX)/lib/$(ATARGET)
	for _file in $(PUBHFILES); do \
	$(CP) -rp --parents $$_file $(PREFIX)/; done
	unset _file
