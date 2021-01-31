# -*- coding: utf-8 -*-
## This Makefile provides multi-platform build normalisation for the C and C++
## compilation toolchains. It is included at the top of the main Makefile.
## Read <https://aquefir.co/slick/makefiles> for details.
##

# Check Make version (we need at least GNU Make 3.82). Fortunately,
# ‘undefine’ directive has been introduced exactly in GNU Make 3.82.
ifeq ($(filter undefine,$(value .FEATURES)),)
$(error Unsupported Make version. \
The build system does not work properly with GNU Make $(MAKE_VERSION), \
please use GNU Make 3.82 or above)
endif

# Host
UNAME := $(shell uname -s)

# Target platform (overridable)
# User can specify TP={Win32,Win64,GBA} at the command line
TP ?= $(UNAME)

## Toolchain
# This must be resolved before the rest, as all the other environment
# variables depend on its value
TC.DARWIN := llvm
TC.LINUX  := gnu
TC.WIN32  := mingw32
TC.WIN64  := mingw32
TC.GBA    := dkarm

## Resolve the correct host-target suffixes
##

ifeq ($(strip $(UNAME)),Darwin)
hsuf := DARWIN
ifeq ($(strip $(TP)),Darwin)
suf := DARWIN
tsuf := DARWIN
else ifeq ($(strip $(TP)),Win32)
suf := DARWIN.WIN32
tsuf := WIN32
else ifeq ($(strip $(TP)),Win64)
suf := DARWIN.WIN64
tsuf := WIN64
else ifeq ($(strip $(TP)),GBA)
suf := DARWIN.GBA
tsuf := GBA
else ifeq ($(strip $(TP)),Linux)
$(error Cross-compilation to Linux is not supported on macOS)
else
$(error Unknown target platform "$(TP)")
endif # $(TP)
else ifeq ($(strip $(UNAME)),Linux)
hsuf := LINUX
ifeq ($(strip $(TP)),Linux)
suf := LINUX
tsuf := LINUX
else ifeq ($(strip $(TP)),Win32)
suf := LINUX.WIN32
tsuf := WIN32
else ifeq ($(strip $(TP)),Win64)
suf := LINUX.WIN64
tsuf := WIN64
else ifeq ($(strip $(TP)),GBA)
suf := DARWIN.GBA
tsuf := GBA
else ifeq ($(strip $(TP)),Darwin)
$(error Cross-compilation to macOS is not supported on Linux)
else
$(error Unknown target platform "$(TP)")
endif # $(TP)
else
$(error Unsupported host platform "$(UNAME)")
endif # $(UNAME)

# Toolchain (overridable)
TC ?= $(TC.$(tsuf))

##
## Toolchain programs
##

ifeq ($(strip $(TC)),llvm)
CC.DARWIN    := /usr/local/opt/llvm/bin/clang # brew LLVM
AS.DARWIN    := /usr/local/opt/llvm/bin/llvm-as
CXX.DARWIN   := /usr/local/opt/llvm/bin/clang++
AR.DARWIN    := /usr/local/opt/llvm/bin/llvm-ar
OCPY.DARWIN  := /usr/local/opt/llvm/bin/llvm-objcopy
STRIP.DARWIN := /usr/local/opt/llvm/bin/llvm-strip
else
CC.DARWIN    := /usr/bin/clang # Xcode
AS.DARWIN    := /usr/bin/as
CXX.DARWIN   := /usr/bin/clang++
AR.DARWIN    := /usr/bin/ar
OCPY.DARWIN  := /usr/bin/objcopy
STRIP.DARWIN := /usr/bin/strip
endif
ifeq ($(strip $(TC)),gnu)
CC.LINUX    := /usr/bin/gcc
AS.LINUX    := /usr/bin/as
CXX.LINUX   := /usr/bin/g++
else
CC.LINUX    := /usr/bin/clang
AS.LINUX    := /usr/bin/llvm-as
CXX.LINUX   := /usr/bin/clang++
endif
CC.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-gcc
CC.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-gcc
CC.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-gcc
CC.LINUX.WIN64  := /usr/bin/i686-w64-mingw32-gcc
CC.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CC.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc

AS.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-as
AS.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-as
AS.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-as
AS.LINUX.WIN64  := /usr/bin/i686-w64-mingw32-as
AS.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
AS.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as

CXX.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-g++
CXX.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-g++
CXX.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-g++
CXX.LINUX.WIN64  := /usr/bin/x86_64-w64-mingw32-g++
CXX.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
CXX.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++

AR.LINUX        := /usr/bin/ar
AR.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-ar
AR.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-ar
AR.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-ar
AR.LINUX.WIN64  := /usr/bin/x86_64-w64-mingw32-ar
AR.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
AR.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar

OCPY.LINUX        := /usr/bin/objcopy
OCPY.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-objcopy
OCPY.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-objcopy
OCPY.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-objcopy
OCPY.LINUX.WIN64  := /usr/bin/x86_64-w64-mingw32-objcopy
OCPY.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
OCPY.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy

STRIP.LINUX        := /usr/bin/strip
STRIP.DARWIN.WIN32 := /usr/local/bin/i686-w64-mingw32-strip
STRIP.LINUX.WIN32  := /usr/bin/i686-w64-mingw32-strip
STRIP.DARWIN.WIN64 := /usr/local/bin/x86_64-w64-mingw32-strip
STRIP.LINUX.WIN64  := /usr/bin/x86_64-w64-mingw32-strip
STRIP.DARWIN.GBA   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip
STRIP.LINUX.GBA    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

INSTALL.LINUX  := /usr/bin/install
INSTALL.DARWIN := /usr/local/bin/ginstall

ECHO.LINUX  := /bin/echo
ECHO.DARWIN := /usr/local/bin/gecho

CP.LINUX  := /usr/bin/cp
CP.DARWIN := /usr/local/bin/gcp

BIN2ASM  := bin2asm
JASC2GBA := jasc2gba
EGMAN    := mangledeggs
FIX      := gbafix
FMT      := clang-format

##
## File suffixes
##

SO.DARWIN := .dylib
SO.LINUX  := .so
SO.WIN32  := .dll
SO.WIN64  := .dll
SO.GBA    := .nosharedlibsforgba # deliberate. check urself

EXE.DARWIN :=
EXE.LINUX  :=
EXE.WIN32  := .exe
EXE.WIN64  := .exe
EXE.GBA    := .elf

##
## Toolchain flags
##

# C compiler flags
CFLAGS.COMMON          := -pipe
CFLAGS.GCOMMON         := -fPIC -ansi -Wpedantic -x c -frandom-seed=69420
CFLAGS.GCOMMON.DEBUG   := -O0 -g3 -Wall -Wpedantic
CFLAGS.GCOMMON.RELEASE := -O3 -w
CFLAGS.GCOMMON.CHECK   := -Wextra -Werror -Wno-unused-variable
CFLAGS.GCOMMON.COV     := -O0 -g3 -fprofile-arcs -ftest-coverage
CFLAGS.GCOMMON.ASAN    := -O1 -g3 -fsanitize=address -fno-omit-frame-pointer
CFLAGS.GCOMMON.UBSAN   := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer
CFLAGS.DARWIN := -march=ivybridge -mtune=skylake
CFLAGS.LINUX  := -march=sandybridge -mtune=skylake
CFLAGS.WIN32  := -march=sandybridge -mtune=skylake
CFLAGS.WIN64  := -march=sandybridge -mtune=skylake
CFLAGS.GBA    := -march=armv4t -mcpu=arm7tdmi -mthumb-interwork \
	-Wno-builtin-declaration-mismatch

# Assembler flags
ASFLAGS.COMMON :=
ASFLAGS.DARWIN :=
ASFLAGS.LINUX  :=
ASFLAGS.WIN32  :=
ASFLAGS.WIN64  :=
ASFLAGS.GBA    := -march=armv4t -mcpu=arm7tdmi -mthumb-interwork -EL

# C++ compiler flags
CXXFLAGS.COMMON := -pipe -fPIC -std=c++11 -x c++ -frandom-seed=69420
CXXFLAGS.COMMON.DEBUG   := -O0 -g3 -Wall -Wpedantic
CXXFLAGS.COMMON.RELEASE := -O3 -w
CXXFLAGS.COMMON.CHECK   := -Wextra -Werror -Wno-unused-variable
CXXFLAGS.COMMON.COV     := -O0 -g3 -fprofile-arcs -ftest-coverage
CXXFLAGS.COMMON.ASAN    := -O1 -g3 -fsanitize=address -fno-omit-frame-pointer
CXXFLAGS.COMMON.UBSAN   := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer
CXXFLAGS.DARWIN := -march=ivybridge -mtune=skylake
CXXFLAGS.LINUX  := -march=sandybridge -mtune=skylake
CXXFLAGS.WIN32  := -march=sandybridge -mtune=skylake
CXXFLAGS.WIN64  := -march=sandybridge -mtune=skylake
CXXFLAGS.GBA    := -march=armv4t -mcpu=arm7tdmi -mthumb-interwork \
	-Wno-builtin-declaration-mismatch

# Linker flags
LDFLAGS.COMMON := -fPIE
LDFLAGS.COV    := -fprofile-arcs -ftest-coverage
LDFLAGS.ASAN   := -fsanitize=address -fno-omit-frame-pointer
LDFLAGS.UBSAN  := -fsanitize=undefined

##
## Other variables
##

# Target sysroot
TROOT.DARWIN.WIN32 := /usr/local/i686-w64-mingw32
TROOT.DARWIN.WIN64 := /usr/local/x86_64-w64-mingw32
TROOT.DARWIN.GBA   := /usr/local/armv4t-agb-eabi
TROOT.DARWIN       := /usr/local
TROOT.LINUX.WIN32  := /usr/i686-w64-mingw32
TROOT.LINUX.WIN64  := /usr/x86_64-w64-mingw32
TROOT.LINUX.GBA    := /usr/armv4t-agb-eabi
TROOT.LINUX        := /usr

# These are config.h synthetics to tell code about its particularities
CDEFS.DARWIN := DARWIN LILENDIAN AMD64 WORDSZ_64 HAS_LONG LONGSZ_64 HAS_I32 \
	HAS_I64
CDEFS.LINUX  := LINUX LILENDIAN
ifneq ($(strip $(shell uname -a | grep x86_64)),)
CDEFS.LINUX += AMD64 WORDSZ_64 HAS_LONG LONGSZ_64 HAS_I32 HAS_I64
else ifneq ($(strip $(shell uname -a | grep i386)),)
CDEFS.LINUX += IA32 WORDSZ_32 HAS_LONG LONGSZ_32 HAS_I32 HAS_I64
else
$(error Linux is not supported outside of x86.)
endif
CDEFS.IBMPC := IBMPC LILENDIAN I86 WORDSZ_16
CDEFS.WIN32 := WINDOWS WIN32 LILENDIAN IA32 WORDSZ_32 HAS_LONG LONGSZ_32 \
	HAS_I32 HAS_I64
CDEFS.WIN64 := WINDOWS WIN64 LILENDIAN AMD64 WORDSZ_64 HAS_LONG LONGSZ_32 \
	HAS_I32 HAS_I64
CDEFS.GBA   := GBA ARMV4T LILENDIAN WORDSZ_32 HAS_I32 HAS_LONG LONGSZ_32 \
	HAS_I32

##
## Resolved variable definitions
##

SO.DEFAULT  := $(SO.$(tsuf))
SO.CUSTOM   := $(SO)
EXE.DEFAULT := $(EXE.$(tsuf))
EXE.CUSTOM  := $(EXE)

AS.DEFAULT := $(AS.$(suf))
AS.CUSTOM := $(AS)
CC.DEFAULT := $(CC.$(suf))
CC.CUSTOM := $(CC)
CXX.DEFAULT := $(CXX.$(suf))
CXX.CUSTOM := $(CXX)
AR.DEFAULT := $(AR.$(suf))
AR.CUSTOM := $(AR)
OCPY.DEFAULT := $(OCPY.$(suf))
OCPY.CUSTOM := $(OCPY)
STRIP.DEFAULT := $(STRIP.$(suf))
STRIP.CUSTOM := $(STRIP)
INSTALL.DEFAULT := $(INSTALL.$(hsuf))
INSTALL.CUSTOM := $(INSTALL)
ECHO.DEFAULT := $(ECHO.$(hsuf))
ECHO.CUSTOM := $(ECHO)
CP.DEFAULT := $(CP.$(hsuf))
CP.CUSTOM := $(CP)

# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
CFLAGS.DEFAULT := $(CFLAGS.COMMON) -std=c89
else
CFLAGS.DEFAULT := $(CFLAGS.GCOMMON) $(CFLAGS.$(tsuf))
endif # $(CC.CUSTOM)
CFLAGS.CUSTOM    := $(CFLAGS)
ASFLAGS.DEFAULT  := $(ASFLAGS.COMMON) $(ASFLAGS.$(tsuf))
ASFLAGS.CUSTOM   := $(ASFLAGS)
CXXFLAGS.DEFAULT := $(CXXFLAGS.COMMON) $(CXXFLAGS.$(tsuf))
CXXFLAGS.CUSTOM  := $(CXXFLAGS)
LDFLAGS.DEFAULT  := $(LDFLAGS.COMMON)
LDFLAGS.CUSTOM   := $(LDFLAGS)
ARFLAGS.DEFAULT  := -rcs
ARFLAGS.CUSTOM   := $(ARFLAGS)
CDEFS.DEFAULT    := $(CDEFS.$(tsuf))
CDEFS.CUSTOM     := $(CDEFS)

TROOT.DEFAULT := $(TROOT.$(suf))
TROOT.CUSTOM  := $(TROOT)

# Make builds deterministic
ifeq ($(strip $(TC)),$(filter $(strip $(TC)),gnu mingw32 dkarm))
CFLAGS.DEFAULT   += -ffile-prefix-map=OLD=NEW
CXXFLAGS.DEFAULT += -ffile-prefix-map=OLD=NEW
endif

FIXFLAGS.DEFAULT := -p -t'POKENICHRUBY' -cCXVE -m01 -r10
FIXFLAGS.CUSTOM  := $(FIXFLAGS)
FMTFLAGS.DEFAULT := -i -style=file
FMTFLAGS.CUSTOM  := $(FMTFLAGS)

ifeq ($(origin SO),undefined)
SO_ORIGIN := DEFAULT
else ifeq ($(origin SO),default)
SO_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
SO_ORIGIN := CUSTOM
endif # $(origin SO)

ifeq ($(origin EXE),undefined)
EXE_ORIGIN := DEFAULT
else ifeq ($(origin EXE),default)
EXE_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
EXE_ORIGIN := CUSTOM
endif # $(origin EXE)

ifeq ($(origin AS),undefined)
AS_ORIGIN := DEFAULT
else ifeq ($(origin AS),default)
AS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
AS_ORIGIN := CUSTOM
endif # $(origin AS)

ifeq ($(origin CC),undefined)
CC_ORIGIN := DEFAULT
else ifeq ($(origin CC),default)
CC_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CC_ORIGIN := CUSTOM
endif # $(origin CC)

ifeq ($(origin CXX),undefined)
CXX_ORIGIN := DEFAULT
else ifeq ($(origin CXX),default)
CXX_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CXX_ORIGIN := CUSTOM
endif # $(origin CXX)

ifeq ($(origin AR),undefined)
AR_ORIGIN := DEFAULT
else ifeq ($(origin AR),default)
AR_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
AR_ORIGIN := CUSTOM
endif # $(origin AR)

ifeq ($(origin OCPY),undefined)
OCPY_ORIGIN := DEFAULT
else ifeq ($(origin OCPY),default)
OCPY_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
OCPY_ORIGIN := CUSTOM
endif # $(origin OCPY)

ifeq ($(origin STRIP),undefined)
STRIP_ORIGIN := DEFAULT
else ifeq ($(origin STRIP),default)
STRIP_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
STRIP_ORIGIN := CUSTOM
endif # $(origin STRIP)

ifeq ($(origin INSTALL),undefined)
INSTALL_ORIGIN := DEFAULT
else ifeq ($(origin INSTALL),default)
INSTALL_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
INSTALL_ORIGIN := CUSTOM
endif # $(origin INSTALL)

ifeq ($(origin ECHO),undefined)
ECHO_ORIGIN := DEFAULT
else ifeq ($(origin ECHO),default)
ECHO_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
ECHO_ORIGIN := CUSTOM
endif # $(origin ECHO)

ifeq ($(origin CP),undefined)
CP_ORIGIN := DEFAULT
else ifeq ($(origin CP),default)
CP_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CP_ORIGIN := CUSTOM
endif # $(origin CP)

ifeq ($(origin ASFLAGS),undefined)
ASFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin ASFLAGS),default)
ASFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
ASFLAGS_ORIGIN := CUSTOM
endif # $(origin ASFLAGS)

ifeq ($(origin CFLAGS),undefined)
CFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin CFLAGS),default)
CFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CFLAGS_ORIGIN := CUSTOM
endif # $(origin CFLAGS)

ifeq ($(origin CXXFLAGS),undefined)
CXXFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin CXXFLAGS),default)
CXXFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CXXFLAGS_ORIGIN := CUSTOM
endif # $(origin CXXFLAGS)

ifeq ($(origin LDFLAGS),undefined)
LDFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin LDFLAGS),default)
LDFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
LDFLAGS_ORIGIN := CUSTOM
endif # $(origin LDFLAGS)

ifeq ($(origin ARFLAGS),undefined)
ARFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin ARFLAGS),default)
ARFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
ARFLAGS_ORIGIN := CUSTOM
endif # $(origin ARFLAGS)

ifeq ($(origin CDEFS),undefined)
CDEFS_ORIGIN := DEFAULT
else ifeq ($(origin CDEFS),default)
CDEFS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
CDEFS_ORIGIN := CUSTOM
endif # $(origin CDEFS)

ifeq ($(origin FIXFLAGS),undefined)
FIXFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin FIXFLAGS),default)
FIXFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
FIXFLAGS_ORIGIN := CUSTOM
endif # $(origin FIXFLAGS)

ifeq ($(origin FMTFLAGS),undefined)
FMTFLAGS_ORIGIN := DEFAULT
else ifeq ($(origin FMTFLAGS),default)
FMTFLAGS_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
FMTFLAGS_ORIGIN := CUSTOM
endif # $(origin FMTFLAGS)

ifeq ($(origin TROOT),undefined)
TROOT_ORIGIN := DEFAULT
else ifeq ($(origin TROOT),default)
TROOT_ORIGIN := DEFAULT
else
# environment [override], file, command line, override, automatic
TROOT_ORIGIN := CUSTOM
endif # $(origin TROOT)

SO := $(SO.$(SO_ORIGIN))
EXE := $(EXE.$(EXE_ORIGIN))
AS := $(AS.$(AS_ORIGIN))
CC := $(CC.$(CC_ORIGIN))
CXX := $(CXX.$(CXX_ORIGIN))
AR := $(AR.$(AR_ORIGIN))
OCPY := $(OCPY.$(OCPY_ORIGIN))
STRIP := $(STRIP.$(STRIP_ORIGIN))
INSTALL := $(INSTALL.$(INSTALL_ORIGIN))
ECHO := $(ECHO.$(ECHO_ORIGIN))
CP := $(CP.$(CP_ORIGIN))
ASFLAGS := $(ASFLAGS.$(ASFLAGS_ORIGIN))
CFLAGS := $(CFLAGS.$(CFLAGS_ORIGIN))
CXXFLAGS := $(CXXFLAGS.$(CXXFLAGS_ORIGIN))
LDFLAGS := $(LDFLAGS.$(LDFLAGS_ORIGIN))
ARFLAGS := $(ARFLAGS.$(ARFLAGS_ORIGIN))
CDEFS := $(CDEFS.$(CDEFS_ORIGIN))
FIXFLAGS := $(FIXFLAGS.$(FIXFLAGS_ORIGIN))
FMTFLAGS := $(FMTFLAGS.$(FMTFLAGS_ORIGIN))
TROOT := $(TROOT.$(TROOT_ORIGIN))

##
## Miscellaneous
##

# Deterministic build flags, for both clang and GCC
SOURCE_DATE_EPOCH := 0
ZERO_AR_DATE      := 1

DEFINES.DEFAULT   :=
UNDEFINES.DEFAULT :=

# TODO: check for TCC by command output instead of name
ifeq ($(notdir $(strip $(CC.CUSTOM))),tcc)
DEFINES.DEFAULT += SDL_DISABLE_IMMINTRIN_H=1
endif

export INSTALL
export ECHO
export CP
