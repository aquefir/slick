#!/usr/bin/make
# -*- coding: utf-8 -*-
## Copyright (C) 2020-2021 Aquefir.
## Released under BSD-2-Clause.
## This Makefile provides multi-platform build normalisation for the C and C++
## compilation toolchains. It is included at the top of the main Makefile.
## Read <https://aquefir.co/slick/makefiles> for details.
##

# Check Make version; we need at least GNU Make 3.82. Fortunately,
# 'undefine' directive has been introduced exactly in GNU Make 3.82.
ifeq ($(filter undefine,$(value .FEATURES)),)
$(error Unsupported Make version. \
The build system does not work properly with GNU Make $(MAKE_VERSION). \
Please use GNU Make 3.82 or later)
endif

## Slick environment variables.
# Here, base.mk normalises their values, so they are always defined to either
# 0 or 1 depending on if the user set them.

# SLICK_PRINT : If set, targets.mk will print out all of the variables as set
# during build.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin SLICK_PRINT),undefined)
.O_SLICK_PRINT := DEFAULT
else ifeq ($(origin SLICK_PRINT),default)
.O_SLICK_PRINT := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_SLICK_PRINT := CUSTOM
endif # $(origin SLICK_PRINT)

# Set the origin-dependent values of the new variable.
SLICK_PRINT.O_DEFAULT := 0
SLICK_PRINT.O_CUSTOM := 1

# Notify the user that SLICK_NOPRINT is deprecated and ineffectual.

ifdef SLICK_NOPRINT
$(warning SLICK_NOPRINT is deprecated. Please use SLICK_PRINT to see the \
build settings printout. This option has no effect.)
endif

# Finally, set the variable.
override SLICK_PRINT := $(SLICK_PRINT.O_$(.O_SLICK_PRINT))

# SLICK_OVERRIDE : If set, targets.mk will take user-set *FLAGS variables as
# the entirety of the flags, instead of appending them to the default *FLAGS,
# the default behaviour.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin SLICK_OVERRIDE),undefined)
.O_SLICK_OVERRIDE := DEFAULT
else ifeq ($(origin SLICK_OVERRIDE),default)
.O_SLICK_OVERRIDE := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_SLICK_OVERRIDE := CUSTOM
endif # $(origin SLICK_OVERRIDE)

# Set the origin-dependent values of the new variable.
SLICK_OVERRIDE.O_DEFAULT := 0
SLICK_OVERRIDE.O_CUSTOM := 1

# Finally, set the variable.
override SLICK_OVERRIDE := $(SLICK_OVERRIDE.O_$(.O_SLICK_OVERRIDE))

## Host platform.

# The ".K_" prefix denotes "[k]onstant" and is to prevent naming collisions.
# Capitalise the result text for use in variable interpolation later.
.K_UNAME := $(shell uname -s | tr 'a-z' 'A-Z')

## Target platform.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin TP),undefined)
.O_TP := DEFAULT
else ifeq ($(origin TP),default)
.O_TP := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_TP := CUSTOM
endif # $(origin TP)

# Set the origin-dependent values of the new variable.
TP.O_DEFAULT := $(.K_UNAME)
TP.O_CUSTOM := $(TP)

# Finally, set the variable.
override TP := $(TP.O_$(.O_TP))

## Toolchain.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin TC),undefined)
.O_TC := DEFAULT
else ifeq ($(origin TC),default)
.O_TC := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_TC := CUSTOM
endif # $(origin TC)

# Set the host/target dependent values of the new variable.
TC.DARWIN := LLVM
TC.LINUX  := GNU
TC.WIN32  := GNU
TC.WIN64  := GNU
TC.GBA    := GNU
TC.GBASP  := GNU
TC.IBMPC  := GNU
TC.APE    := GNU

# Set the origin-dependent values of the new variable.
TC.O_DEFAULT := $(TC.$(TP))
TC.O_CUSTOM := $(TC)

# Finally, set the variable.
override TC := $(TC.O_$(.O_TC))

## Target sysroot.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin TROOT),undefined)
.O_TROOT := DEFAULT
else ifeq ($(origin TROOT),default)
.O_TROOT := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_TROOT := CUSTOM
endif # $(origin TROOT)

# Set the host/target dependent values of the new variable.
TROOT.DARWIN.DARWIN := /usr/local
TROOT.DARWIN.WIN32  := /usr/local/i686-w64-mingw32
TROOT.DARWIN.WIN64  := /usr/local/x86_64-w64-mingw32
TROOT.DARWIN.GBA    := /usr/local/armv4t-agb-eabi
TROOT.DARWIN.GBASP  := /usr/local/armv4t-agb-nicho
TROOT.DARWIN.IBMPC  := /usr/local/i386-pc-dos
TROOT.DARWIN.APE    := /usr/local/x86_64-pc-ape
TROOT.LINUX.LINUX   := /usr
TROOT.LINUX.WIN32   := /usr/i686-w64-mingw32
TROOT.LINUX.WIN64   := /usr/x86_64-w64-mingw32
TROOT.LINUX.GBA     := /usr/armv4t-agb-eabi
TROOT.LINUX.GBASP   := /usr/armv4t-agb-nicho
TROOT.LINUX.IBMPC   := /usr/i386-pc-dos
TROOT.LINUX.APE     := /usr/x86_64-pc-ape

# Set the origin-dependent values of the new variable.
TROOT.O_DEFAULT := $(TROOT.$(.K_UNAME).$(TP))
TROOT.O_CUSTOM := $(TROOT)

# Finally, set the variable.
override TROOT := $(TROOT.O_$(.O_TROOT))

## Toolchain programs.

# Darwin host

# Native, LLVM
CC.DARWIN.DARWIN.LLVM    := /usr/local/opt/llvm/bin/clang # brew LLVM
CXX.DARWIN.DARWIN.LLVM   := /usr/local/opt/llvm/bin/clang++
AR.DARWIN.DARWIN.LLVM    := /usr/local/opt/llvm/bin/llvm-ar
OCPY.DARWIN.DARWIN.LLVM  := /usr/local/opt/llvm/bin/llvm-objcopy
STRIP.DARWIN.DARWIN.LLVM := /usr/local/opt/llvm/bin/llvm-strip
PROF.DARWIN.DARWIN.LLVM  := /usr/local/opt/llvm/bin/llvm-profdata
COV.DARWIN.DARWIN.LLVM   := /usr/local/opt/llvm/bin/llvm-cov

# Native, GNU
AS.DARWIN.DARWIN.GNU    := /usr/local/opt/binutils/bin/as
CC.DARWIN.DARWIN.GNU    := /usr/local/bin/gcc-9 # brew GCC
CXX.DARWIN.DARWIN.GNU   := /usr/local/bin/g++-9
AR.DARWIN.DARWIN.GNU    := /usr/local/opt/binutils/bin/ar
OCPY.DARWIN.DARWIN.GNU  := /usr/local/opt/binutils/bin/objcopy
STRIP.DARWIN.DARWIN.GNU := /usr/local/opt/binutils/bin/strip

# Native, Xcode
#AS.DARWIN.DARWIN.XCODE   := There is no assembler in Xcode
CC.DARWIN.DARWIN.XCODE    := /usr/bin/clang
CXX.DARWIN.DARWIN.XCODE   := /usr/bin/clang++
AR.DARWIN.DARWIN.XCODE    := /usr/bin/ar
#OCPY.DARWIN.DARWIN.XCODE := There is no objcopy in Xcode
STRIP.DARWIN.DARWIN.XCODE := /usr/bin/strip

# 32-bit Windows
AS.DARWIN.WIN32.GNU    := /usr/local/bin/i686-w64-mingw32-as
CC.DARWIN.WIN32.GNU    := /usr/local/bin/i686-w64-mingw32-gcc
CXX.DARWIN.WIN32.GNU   := /usr/local/bin/i686-w64-mingw32-g++
AR.DARWIN.WIN32.GNU    := /usr/local/bin/i686-w64-mingw32-ar
OCPY.DARWIN.WIN32.GNU  := /usr/local/bin/i686-w64-mingw32-objcopy
STRIP.DARWIN.WIN32.GNU := /usr/local/bin/i686-w64-mingw32-strip

# 64-bit Windows
AS.DARWIN.WIN64.GNU    := /usr/local/bin/x86_64-w64-mingw32-as
CC.DARWIN.WIN64.GNU    := /usr/local/bin/x86_64-w64-mingw32-gcc
CXX.DARWIN.WIN64.GNU   := /usr/local/bin/x86_64-w64-mingw32-g++
AR.DARWIN.WIN64.GNU    := /usr/local/bin/x86_64-w64-mingw32-ar
OCPY.DARWIN.WIN64.GNU  := /usr/local/bin/x86_64-w64-mingw32-objcopy
STRIP.DARWIN.WIN64.GNU := /usr/local/bin/x86_64-w64-mingw32-strip

# Game Boy Advance
AS.DARWIN.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.DARWIN.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.DARWIN.GBA.GNU   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.DARWIN.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.DARWIN.GBA.GNU  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.DARWIN.GBA.GNU := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# Game Boy Advance Sourcepatching
AS.DARWIN.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.DARWIN.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.DARWIN.GBASP.GNU   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.DARWIN.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.DARWIN.GBASP.GNU  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.DARWIN.GBASP.GNU := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# MS-DOS with DJGPP
# brew x86_64-elf-binutils
AS.DARWIN.IBMPC.GNU    := /usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-as
# brew GCC
CC.DARWIN.IBMPC.GNU    := /usr/local/opt/x86_64-elf-gcc/bin/x86_64-elf-gcc
CXX.DARWIN.IBMPC.GNU   := /usr/local/opt/x86_64-elf-gcc/bin/x86_64-elf-g++
AR.DARWIN.IBMPC.GNU    := /usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-ar
OCPY.DARWIN.IBMPC.GNU  := \
	/usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-objcopy
STRIP.DARWIN.IBMPC.GNU := \
	/usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-strip

# Actually Portable Executables
# brew x86_64-elf-binutils
AS.DARWIN.APE.GNU    := /usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-as
# brew GCC
CC.DARWIN.APE.GNU    := /usr/local/opt/x86_64-elf-gcc/bin/x86_64-elf-gcc
CXX.DARWIN.APE.GNU   := /usr/local/opt/x86_64-elf-gcc/bin/x86_64-elf-g++
AR.DARWIN.APE.GNU    := /usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-ar
OCPY.DARWIN.APE.GNU  := \
	/usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-objcopy
STRIP.DARWIN.APE.GNU := \
	/usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-strip

# Dev tools
PL.DARWIN      := /usr/local/bin/perl # brew perl
PY.DARWIN      := /usr/local/bin/python3
FMT.DARWIN     := /usr/local/bin/clang-format
LINT.DARWIN    := /usr/local/bin/cppcheck
INSTALL.DARWIN := /usr/local/opt/coreutils/bin/ginstall # GNU coreutils
ECHO.DARWIN    := /usr/local/opt/coreutils/bin/gecho
CP.DARWIN      := /usr/local/opt/coreutils/bin/gcp
BIN2ASM.DARWIN := /usr/local/bin/bin2asm
EGMAN.DARWIN   := /usr/local/bin/mangledeggs

# Linux host

# Native, GNU
AS.LINUX.LINUX.GNU    := /usr/bin/as
CC.LINUX.LINUX.GNU    := /usr/bin/gcc
CXX.LINUX.LINUX.GNU   := /usr/bin/g++
AR.LINUX.LINUX.GNU    := /usr/bin/ar
OCPY.LINUX.LINUX.GNU  := /usr/bin/objcopy
STRIP.LINUX.LINUX.GNU := /usr/bin/strip

# Native, LLVM
CC.LINUX.LINUX.LLVM    := /usr/bin/clang
CXX.LINUX.LINUX.LLVM   := /usr/bin/clang++
AR.LINUX.LINUX.LLVM    := /usr/bin/ar
OCPY.LINUX.LINUX.LLVM  := /usr/bin/llvm-objcopy
STRIP.LINUX.LINUX.LLVM := /usr/bin/llvm-strip
PROF.LINUX.LINUX.LLVM  := /usr/bin/llvm-profdata
COV.LINUX.LINUX.LLVM   := /usr/bin/llvm-cov

# 32-bit Windows
AS.LINUX.WIN32.GNU    := /usr/bin/i686-w64-mingw32-as
CC.LINUX.WIN32.GNU    := /usr/bin/i686-w64-mingw32-gcc
CXX.LINUX.WIN32.GNU   := /usr/bin/i686-w64-mingw32-g++
AR.LINUX.WIN32.GNU    := /usr/bin/i686-w64-mingw32-ar
OCPY.LINUX.WIN32.GNU  := /usr/bin/i686-w64-mingw32-objcopy
STRIP.LINUX.WIN32.GNU := /usr/bin/i686-w64-mingw32-strip

# 64-bit Windows
AS.LINUX.WIN64.GNU    := /usr/bin/x86_64-w64-mingw32-as
CC.LINUX.WIN64.GNU    := /usr/bin/x86_64-w64-mingw32-gcc
CXX.LINUX.WIN64.GNU   := /usr/bin/x86_64-w64-mingw32-g++
AR.LINUX.WIN64.GNU    := /usr/bin/x86_64-w64-mingw32-ar
OCPY.LINUX.WIN64.GNU  := /usr/bin/x86_64-w64-mingw32-objcopy
STRIP.LINUX.WIN64.GNU := /usr/bin/x86_64-w64-mingw32-strip

# Game Boy Advance
AS.LINUX.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.LINUX.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.LINUX.GBA.GNU   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.LINUX.GBA.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.LINUX.GBA.GNU  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.LINUX.GBA.GNU := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# Game Boy Advance Sourcepatching
AS.LINUX.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.LINUX.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.LINUX.GBASP.GNU   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.LINUX.GBASP.GNU    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.LINUX.GBASP.GNU  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.LINUX.GBASP.GNU := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# MS-DOS with DJGPP
AS.LINUX.IBMPC.GNU    := /usr/bin/as
CC.LINUX.IBMPC.GNU    := /usr/bin/gcc
CXX.LINUX.IBMPC.GNU   := /usr/bin/g++
AR.LINUX.IBMPC.GNU    := /usr/bin/ar
OCPY.LINUX.IBMPC.GNU  := /usr/bin/objcopy
STRIP.LINUX.IBMPC.GNU := /usr/bin/strip

# Actually Portable Executables
AS.LINUX.APE.GNU    := /usr/bin/as
CC.LINUX.APE.GNU    := /usr/bin/gcc
CXX.LINUX.APE.GNU   := /usr/bin/g++
AR.LINUX.APE.GNU    := /usr/bin/ar
OCPY.LINUX.APE.GNU  := /usr/bin/objcopy
STRIP.LINUX.APE.GNU := /usr/bin/strip

# Dev tools
PL.LINUX      := /usr/bin/perl
PY.LINUX      := /usr/bin/python3
FMT.LINUX     := /usr/bin/clang-format
LINT.LINUX    := /usr/bin/cppcheck
INSTALL.LINUX := /usr/bin/install
ECHO.LINUX    := /bin/echo # Not a bashism
CP.LINUX      := /bin/cp # Not a bashism
BIN2ASM.LINUX := /usr/bin/bin2asm
EGMAN.LINUX   := /usr/bin/mangledeggs

## Suffixes.

# Shared libraries.

SO.LINUX  := .so
SO.DARWIN := .dylib
SO.WIN32  := .dll
SO.WIN64  := .dll
#SO.GBA   := GBA does not have shared libraries.
#SO.GBASP := GBASP does not have shared libraries.
#SO.IBMPC := IBMPC does not have shared libraries.
#SO.APE   := APE does not have shared libraries.

# Executables.

EXE.LINUX  :=
EXE.DARWIN :=
EXE.WIN32  := .exe
EXE.WIN64  := .exe
EXE.GBA    := .elf
EXE.GBASP  := .elf
EXE.IBMPC  := .elf
EXE.APE    := .com.dbg

# Binary executables.

BIN.GBA   := .gba
BIN.GBASP := .bin
BIN.IBMPC := .com
BIN.APE   := .com

## Flags.

# Assembler flags.
# Form: ASFLAGS.<TARGET>.<TP>
# Only GNU toolchain is supported. Darwin cannot be targeted.

ASFLAGS.COMMON.LINUX := -march=x86-64
ASFLAGS.COMMON.WIN32 := -march=i386
ASFLAGS.COMMON.WIN64 := -march=x86-64
ASFLAGS.COMMON.GBA   := -march=armv4t -mcpu=arm7tdmi -mthumb-interwork -EL
ASFLAGS.COMMON.GBASP := -march=armv4t -mcpu=arm7tdmi -EL
ASFLAGS.COMMON.IBMPC := --32 -march=i386
ASFLAGS.COMMON.APE   := -march=x86-64

# C compiler flags.
# Form: CFLAGS.<TARGET>.<TP>.<TC>
# NOTE: $TC uses a modified set to include 3rd party C compiler support.
#       This includes CHIBI and TCC as additional values.

CFLAGS.COMMON.ALL.GNU      := -ansi -pipe -x c -frandom-seed=69420
CFLAGS.COMMON.ALL.LLVM     := -ansi -pipe -Wpedantic -x c -frandom-seed=69420
CFLAGS.COMMON.ALL.XCODE    := -ansi -pipe -Wpedantic -x c -frandom-seed=69420
CFLAGS.COMMON.ALL.TCC      := -std=c89 -Wpedantic
CFLAGS.COMMON.LINUX.GNU    := -Wpedantic -march=x86-64 -mtune=core-avx2 -fPIC
CFLAGS.COMMON.LINUX.LLVM   := -march=x86-64 -mtune=core-avx2 -fPIC
CFLAGS.COMMON.DARWIN.GNU   := -Wpedantic -march=ivybridge -mtune=core-avx2 \
	-fPIC
CFLAGS.COMMON.DARWIN.LLVM  := -march=ivybridge -mtune=core-avx2 -fPIC
CFLAGS.COMMON.DARWIN.XCODE := -march=ivybridge -mtune=core-avx2 -fPIC
CFLAGS.COMMON.WIN32.GNU    := -Wpedantic -march=i386 -mtune=core-avx2 -fPIC
CFLAGS.COMMON.WIN64.GNU    := -Wpedantic -march=x86-64 -mtune=core-avx2 -fPIC
CFLAGS.COMMON.GBA.GNU      := -Wpedantic -march=armv4t -mcpu=arm7tdmi \
	-mthumb-interwork -Wno-builtin-declaration-mismatch
CFLAGS.COMMON.GBASP.GNU    := -march=armv4t -mcpu=arm7tdmi
CFLAGS.COMMON.IBMPC.GNU    := -Wpedantic -m32 -march=i386 -nostdinc -fno-pie \
	-fno-leading-underscore -ffreestanding
CFLAGS.COMMON.APE.GNU      := -g -march=x86-64 -mtune=core-avx2 -fno-pie \
	-mno-red-zone -nostdinc

CFLAGS.DEBUG.ALL.GNU   := -O0 -g3 -Wall
CFLAGS.DEBUG.ALL.LLVM  := -O0 -g3 -Wall
CFLAGS.DEBUG.ALL.XCODE := -O0 -g3 -Wall
CFLAGS.DEBUG.ALL.TCC   := -g -Wall

CFLAGS.RELEASE.ALL.GNU   := -O3 -w
CFLAGS.RELEASE.ALL.LLVM  := -O3 -w
CFLAGS.RELEASE.ALL.XCODE := -O3 -w
CFLAGS.RELEASE.ALL.TCC   := -w

CFLAGS.CHECK.ALL.GNU   := -Wextra -Werror -Wno-unused-variable
CFLAGS.CHECK.ALL.LLVM  := -Wextra -Werror -Wno-unused-variable
CFLAGS.CHECK.ALL.XCODE := -Wextra -Werror -Wno-unused-variable
CFLAGS.CHECK.ALL.TCC   := -Wextra -Werror -Wno-unused-variable

CFLAGS.COV.ALL.GNU   := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CFLAGS.COV.ALL.LLVM  := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CFLAGS.COV.ALL.XCODE := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

CFLAGS.ASAN.ALL.GNU   := -O1 -g3 -fsanitize=address -fno-omit-frame-pointer \
	-fprofile-arcs -ftest-coverage -fprofile-instr-generate -fcoverage-mapping
CFLAGS.ASAN.ALL.LLVM  := -O1 -g3 -fsanitize=address -fno-omit-frame-pointer \
	-fprofile-arcs -ftest-coverage -fprofile-instr-generate -fcoverage-mapping
CFLAGS.ASAN.ALL.XCODE := -O1 -g3 -fsanitize=address -fno-omit-frame-pointer \
	-fprofile-arcs -ftest-coverage -fprofile-instr-generate -fcoverage-mapping

CFLAGS.UBSAN.ALL.GNU   := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CFLAGS.UBSAN.ALL.LLVM  := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CFLAGS.UBSAN.ALL.XCODE := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

# C++ compiler flags.
# Form: CXXFLAGS.<TARGET>.<TP>.<TC>

CXXFLAGS.COMMON.ALL.GNU      := -pipe -x c++ -frandom-seed=69420
CXXFLAGS.COMMON.ALL.LLVM     := -pipe -Wpedantic -x c++ -frandom-seed=69420
CXXFLAGS.COMMON.ALL.XCODE    := -pipe -Wpedantic -x c++ -frandom-seed=69420
CXXFLAGS.COMMON.LINUX.GNU    := -Wpedantic -march=x86-64 -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.LINUX.LLVM   := -march=x86-64 -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.DARWIN.GNU   := -Wpedantic -march=ivybridge -mtune=core-avx2 \
	-fPIC
CXXFLAGS.COMMON.DARWIN.LLVM  := -march=ivybridge -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.DARWIN.XCODE := -march=ivybridge -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.WIN32.GNU    := -Wpedantic -march=i386 -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.WIN64.GNU    := -Wpedantic -march=x86-64 -mtune=core-avx2 -fPIC
CXXFLAGS.COMMON.GBA.GNU      := -Wpedantic -march=armv4t -mcpu=arm7tdmi \
	-mthumb-interwork -Wno-builtin-declaration-mismatch
CXXFLAGS.COMMON.GBASP.GNU    := -march=armv4t -mcpu=arm7tdmi
CXXFLAGS.COMMON.IBMPC.GNU    := -Wpedantic -m32 -march=i386 -nostdinc \
	-fno-pie -fno-leading-underscore -ffreestanding
CXXFLAGS.COMMON.APE.GNU      := -g -march=x86-64 -mtune=core-avx2 -fno-pie \
	-mno-red-zone -nostdinc

CXXFLAGS.DEBUG.ALL.GNU   := -O0 -g3 -Wall
CXXFLAGS.DEBUG.ALL.LLVM  := -O0 -g3 -Wall
CXXFLAGS.DEBUG.ALL.XCODE := -O0 -g3 -Wall

CXXFLAGS.RELEASE.ALL.GNU   := -O3 -w
CXXFLAGS.RELEASE.ALL.LLVM  := -O3 -w
CXXFLAGS.RELEASE.ALL.XCODE := -O3 -w

CXXFLAGS.CHECK.ALL.GNU   := -Wextra -Werror -Wno-unused-variable
CXXFLAGS.CHECK.ALL.LLVM  := -Wextra -Werror -Wno-unused-variable
CXXFLAGS.CHECK.ALL.XCODE := -Wextra -Werror -Wno-unused-variable
CXXFLAGS.CHECK.ALL.TCC   := -Wextra -Werror -Wno-unused-variable

CXXFLAGS.COV.ALL.GNU   := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.COV.ALL.LLVM  := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.COV.ALL.XCODE := -O0 -g3 -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

CXXFLAGS.ASAN.ALL.GNU   := -O1 -g3 -fsanitize=address \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.ASAN.ALL.LLVM  := -O1 -g3 -fsanitize=address \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.ASAN.ALL.XCODE := -O1 -g3 -fsanitize=address \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

CXXFLAGS.UBSAN.ALL.GNU   := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.UBSAN.ALL.LLVM  := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
CXXFLAGS.UBSAN.ALL.XCODE := -O1 -g3 -fsanitize=undefined \
	-fno-omit-frame-pointer -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

# Archiver flags.
# Form: ARFLAGS.COMMON

ARFLAGS.COMMON := -rcs

# Linker flags.
# Form: LDFLAGS.<TARGET>.<TP>.<TC>

LDFLAGS.COMMON.LINUX.GNU    := -fPIE
LDFLAGS.COMMON.LINUX.LLVM   := -fPIE
LDFLAGS.COMMON.DARWIN.GNU   := -fPIE
LDFLAGS.COMMON.DARWIN.LLVM  := -fPIE -mlinker-version=305
LDFLAGS.COMMON.DARWIN.XCODE := -fPIE
LDFLAGS.COMMON.WIN32.GNU    := -fPIE
LDFLAGS.COMMON.WIN64.GNU    := -fPIE
LDFLAGS.COMMON.GBA.GNU      :=
LDFLAGS.COMMON.GBASP.GNU    := -nostdlib -T etc/gba.ld -T etc/emer.ld
LDFLAGS.COMMON.IBMPC.GNU    := -m32 -march=i386 -static -nostdlib -no-pie \
	-Wl,--as-needed -Wl,--build-id=none -Wl,--nmagic -ffreestanding
LDFLAGS.COMMON.APE.GNU      := -march=x86-64 -mtune=core-avx2 -fuse-ld=bfd \
	-static -nostdlib -no-pie -Wl,--as-needed -Wl,--build-id=none

LDFLAGS.COV.ALL.GNU      := -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
LDFLAGS.COV.ALL.LLVM     := -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping
LDFLAGS.COV.DARWIN.XCODE := -fprofile-arcs -ftest-coverage \
	-fprofile-instr-generate -fcoverage-mapping

LDFLAGS.ASAN.ALL.GNU      := -fsanitize=address -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping
LDFLAGS.ASAN.ALL.LLVM     := -fsanitize=address -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping
LDFLAGS.ASAN.DARWIN.XCODE := -fsanitize=address -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping

LDFLAGS.UBSAN.ALL.GNU      := -fsanitize=undefined -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping
LDFLAGS.UBSAN.ALL.LLVM     := -fsanitize=undefined -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping
LDFLAGS.UBSAN.DARWIN.XCODE := -fsanitize=undefined -fprofile-arcs \
	-ftest-coverage -fprofile-instr-generate -fcoverage-mapping

PROFFLAGS.COMMON.ALL.LLVM := merge -sparse
COVFLAGS.COMMON.ALL.LLVM  := report

# Synthetic definitions.
# Form: SYNDEFS.<TARGET>
# <TARGET> is one of $TP or $TARGET

SYNDEFS.DARWIN := DARWIN AMD64 LILENDIAN WORDSZ_64 HAVE_I32 HAVE_I64 HAVE_FP \
	FP_HARD FP_SOFT LONGSZ_64
SYNDEFS.LINUX  := LINUX AMD64 LILENDIAN WORDSZ_64 HAVE_I32 HAVE_I64 HAVE_FP \
	FP_HARD FP_SOFT LONGSZ_64
SYNDEFS.WIN32  := WINDOWS IA32 LILENDIAN WORDSZ_32 HAVE_I32 HAVE_I64 HAVE_FP \
	FP_HARD FP_SOFT LONGSZ_32 WIN32
SYNDEFS.WIN64  := WINDOWS IA32 LILENDIAN WORDSZ_64 HAVE_I32 HAVE_I64 HAVE_FP \
	FP_HARD FP_SOFT LONGSZ_32 WIN64
SYNDEFS.GBA    := GBA ARMV4T LILENDIAN WORDSZ_32 HAVE_I32 HAVE_FP FP_SOFT \
	LONGSZ_32
SYNDEFS.GBASP  := GBA SOURCEPATCH ARMV4T LILENDIAN WORDSZ_32 HAVE_I32 \
	LONGSZ_32
SYNDEFS.IBMPC  := IBMPC I86 LILENDIAN WORDSZ_16
SYNDEFS.APE    := APE AMD64 LILENDIAN WORDSZ_64 HAVE_I32 HAVE_I64 HAVE_FP \
	FP_HARD FP_SOFT LONGSZ_64

# Shared object file extension.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin SO),undefined)
.O_SO := DEFAULT
else ifeq ($(origin SO),default)
.O_SO := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_SO := CUSTOM
endif # $(origin SO)

# Set the origin-dependent values of the new variable.
SO.O_DEFAULT := $(SO.$(TP))
SO.O_CUSTOM := $(SO)

# Finally, set the variable.
override SO := $(SO.O_$(.O_SO))

# Executable file extension.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin EXE),undefined)
.O_EXE := DEFAULT
else ifeq ($(origin EXE),default)
.O_EXE := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_EXE := CUSTOM
endif # $(origin EXE)

# Set the origin-dependent values of the new variable.
EXE.O_DEFAULT := $(EXE.$(TP))
EXE.O_CUSTOM := $(EXE)

# Finally, set the variable.
override EXE := $(EXE.O_$(.O_EXE))

# Binary executable file extension.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin BIN),undefined)
.O_BIN := DEFAULT
else ifeq ($(origin BIN),default)
.O_BIN := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_BIN := CUSTOM
endif # $(origin BIN)

# Set the origin-dependent values of the new variable.
BIN.O_DEFAULT := $(BIN.$(TP))
BIN.O_CUSTOM := $(BIN)

# Finally, set the variable.
override BIN := $(BIN.O_$(.O_BIN))

# Assembler.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin AS),undefined)
.O_AS := DEFAULT
else ifeq ($(origin AS),default)
.O_AS := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_AS := CUSTOM
endif # $(origin AS)

# Set the origin-dependent values of the new variable.
AS.O_DEFAULT := $(AS.$(.K_UNAME).$(TP).$(TC))
AS.O_CUSTOM := $(AS)

# Finally, set the variable.
override AS := $(AS.O_$(.O_AS))

# C compiler.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin CC),undefined)
.O_CC := DEFAULT
else ifeq ($(origin CC),default)
.O_CC := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_CC := CUSTOM
endif # $(origin CC)

# Set the origin-dependent values of the new variable.
CC.O_DEFAULT := $(CC.$(.K_UNAME).$(TP).$(TC))
CC.O_CUSTOM := $(CC)

# Finally, set the variable.
override CC := $(CC.O_$(.O_CC))

# C++ compiler.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin CXX),undefined)
.O_CXX := DEFAULT
else ifeq ($(origin CXX),default)
.O_CXX := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_CXX := CUSTOM
endif # $(origin CXX)

# Set the origin-dependent values of the new variable.
CXX.O_DEFAULT := $(CXX.$(.K_UNAME).$(TP).$(TC))
CXX.O_CUSTOM := $(CXX)

# Finally, set the variable.
override CXX := $(CXX.O_$(.O_CXX))

# Static archiver.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin AR),undefined)
.O_AR := DEFAULT
else ifeq ($(origin AR),default)
.O_AR := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_AR := CUSTOM
endif # $(origin AR)

# Set the origin-dependent values of the new variable.
AR.O_DEFAULT := $(AR.$(.K_UNAME).$(TP).$(TC))
AR.O_CUSTOM := $(AR)

# Finally, set the variable.
override AR := $(AR.O_$(.O_AR))

# Object file copier.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin OCPY),undefined)
.O_OCPY := DEFAULT
else ifeq ($(origin OCPY),default)
.O_OCPY := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_OCPY := CUSTOM
endif # $(origin OCPY)

# Set the origin-dependent values of the new variable.
OCPY.O_DEFAULT := $(OCPY.$(.K_UNAME).$(TP).$(TC))
OCPY.O_CUSTOM := $(OCPY)

# Finally, set the variable.
override OCPY := $(OCPY.O_$(.O_OCPY))

# Stripper.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin STRIP),undefined)
.O_STRIP := DEFAULT
else ifeq ($(origin STRIP),default)
.O_STRIP := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_STRIP := CUSTOM
endif # $(origin STRIP)

# Set the origin-dependent values of the new variable.
STRIP.O_DEFAULT := $(STRIP.$(.K_UNAME).$(TP).$(TC))
STRIP.O_CUSTOM := $(STRIP)

# Finally, set the variable.
override STRIP := $(STRIP.O_$(.O_STRIP))

# Profile data tool.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin PROF),undefined)
.O_PROF := DEFAULT
else ifeq ($(origin PROF),default)
.O_PROF := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_PROF := CUSTOM
endif # $(origin PROF)

# Set the origin-dependent values of the new variable.
PROF.O_DEFAULT := $(PROF.$(.K_UNAME).$(TP).$(TC))
PROF.O_CUSTOM := $(PROF)

# Finally, set the variable.
override PROF := $(PROF.O_$(.O_PROF))

# Code coverage tool.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin COV),undefined)
.O_COV := DEFAULT
else ifeq ($(origin COV),default)
.O_COV := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_COV := CUSTOM
endif # $(origin COV)

# Set the origin-dependent values of the new variable.
COV.O_DEFAULT := $(COV.$(.K_UNAME).$(TP).$(TC))
COV.O_CUSTOM := $(COV)

# Finally, set the variable.
override COV := $(COV.O_$(.O_COV))

# Perl 5 interpreter.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin PL),undefined)
.O_PL := DEFAULT
else ifeq ($(origin PL),default)
.O_PL := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_PL := CUSTOM
endif # $(origin PL)

# Set the origin-dependent values of the new variable.
PL.O_DEFAULT := $(PL.$(.K_UNAME))
PL.O_CUSTOM := $(PL)

# Finally, set the variable.
override PL := $(PL.O_$(.O_PL))

# Python 3.4+ interpreter.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin PY),undefined)
.O_PY := DEFAULT
else ifeq ($(origin PY),default)
.O_PY := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_PY := CUSTOM
endif # $(origin PY)

# Set the origin-dependent values of the new variable.
PY.O_DEFAULT := $(PY.$(.K_UNAME))
PY.O_CUSTOM := $(PY)

# Finally, set the variable.
override PY := $(PY.O_$(.O_PY))

# Auto-formatter.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin FMT),undefined)
.O_FMT := DEFAULT
else ifeq ($(origin FMT),default)
.O_FMT := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_FMT := CUSTOM
endif # $(origin FMT)

# Set the origin-dependent values of the new variable.
FMT.O_DEFAULT := $(FMT.$(.K_UNAME))
FMT.O_CUSTOM := $(FMT)

# Finally, set the variable.
override FMT := $(FMT.O_$(.O_FMT))

# Linter.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin LINT),undefined)
.O_LINT := DEFAULT
else ifeq ($(origin LINT),default)
.O_LINT := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_LINT := CUSTOM
endif # $(origin LINT)

# Set the origin-dependent values of the new variable.
LINT.O_DEFAULT := $(LINT.$(.K_UNAME))
LINT.O_CUSTOM := $(LINT)

# Finally, set the variable.
override LINT := $(LINT.O_$(.O_LINT))

# Install command.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin INSTALL),undefined)
.O_INSTALL := DEFAULT
else ifeq ($(origin INSTALL),default)
.O_INSTALL := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_INSTALL := CUSTOM
endif # $(origin INSTALL)

# Set the origin-dependent values of the new variable.
INSTALL.O_DEFAULT := $(INSTALL.$(.K_UNAME))
INSTALL.O_CUSTOM := $(INSTALL)

# Finally, set the variable.
override INSTALL := $(INSTALL.O_$(.O_INSTALL))

# Echo command.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin ECHO),undefined)
.O_ECHO := DEFAULT
else ifeq ($(origin ECHO),default)
.O_ECHO := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_ECHO := CUSTOM
endif # $(origin ECHO)

# Set the origin-dependent values of the new variable.
ECHO.O_DEFAULT := $(ECHO.$(.K_UNAME))
ECHO.O_CUSTOM := $(ECHO)

# Finally, set the variable.
override ECHO := $(ECHO.O_$(.O_ECHO))

# Copy command ('cp').

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin CP),undefined)
.O_CP := DEFAULT
else ifeq ($(origin CP),default)
.O_CP := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_CP := CUSTOM
endif # $(origin CP)

# Set the origin-dependent values of the new variable.
CP.O_DEFAULT := $(CP.$(.K_UNAME))
CP.O_CUSTOM := $(CP)

# Finally, set the variable.
override CP := $(CP.O_$(.O_CP))

# Binary to assembly converter ('bin2asm').

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin BIN2ASM),undefined)
.O_BIN2ASM := DEFAULT
else ifeq ($(origin BIN2ASM),default)
.O_BIN2ASM := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_BIN2ASM := CUSTOM
endif # $(origin BIN2ASM)

# Set the origin-dependent values of the new variable.
BIN2ASM.O_DEFAULT := $(BIN2ASM.$(.K_UNAME))
BIN2ASM.O_CUSTOM := $(BIN2ASM)

# Finally, set the variable.
override BIN2ASM := $(BIN2ASM.O_$(.O_BIN2ASM))

# Mangler ('egman').

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The ".O_" prefix denotes "origin" and is to prevent naming collisions.
ifeq ($(origin EGMAN),undefined)
.O_EGMAN := DEFAULT
else ifeq ($(origin EGMAN),default)
.O_EGMAN := DEFAULT
else
# environment [override], file, command line, override, automatic
.O_EGMAN := CUSTOM
endif # $(origin EGMAN)

# Set the origin-dependent values of the new variable.
EGMAN.O_DEFAULT := $(EGMAN.$(.K_UNAME))
EGMAN.O_CUSTOM := $(EGMAN)

# Finally, set the variable.
override EGMAN := $(EGMAN.O_$(.O_EGMAN))

# Make builds deterministic when using LLVM or GNU C/C++ compilers.
# These are the environment variables necessary; see CFLAGS and CXXFLAGS for
# the command-line options that deterministic builds depend on.
override SOURCE_DATE_EPOCH := 0
override ZERO_AR_DATE      := 1
