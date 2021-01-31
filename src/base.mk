#!/usr/bin/make
# -*- coding: utf-8 -*-
## This Makefile provides multi-platform build normalisation for the C and C++
## compilation toolchains. It is included at the top of the main Makefile.
## Read <https://aquefir.co/slick/makefiles> for details.
##

# Check Make version; we need at least GNU Make 3.82. Fortunately,
# ‘undefine’ directive has been introduced exactly in GNU Make 3.82.
ifeq ($(filter undefine,$(value .FEATURES)),)
$(error Unsupported Make version. \
The build system does not work properly with GNU Make $(MAKE_VERSION). \
Please use GNU Make 3.82 or later)
endif

## Host platform.

# The “.K_” prefix denotes “[k]onstant” and is to prevent naming collisions.
.K_UNAME := $(shell uname -s | tr 'a-z' 'A-Z')

## Target platform.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The “.O_” prefix denotes “origin” and is to prevent naming collisions.
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
# The “.O_” prefix denotes “origin” and is to prevent naming collisions.
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
TC.WIN32  := MINGW32
TC.WIN64  := MINGW32
TC.GBA    := DKARM
TC.IBMPC  := DJGPP

# Set the origin-dependent values of the new variable.
TC.O_DEFAULT := $(TC.$(TP))
TC.O_CUSTOM := $(TC)

# Finally, set the variable.
override TC := $(TC.O_$(.O_TC))

## Target sysroot.

# Inspect the origin of the new variable.
# If it is undefined or set by default, say so. Otherwise it was customised.
# The “.O_” prefix denotes “origin” and is to prevent naming collisions.
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
TROOT.DARWIN.IBMPC  := /usr/local/i586-pc-msdosdjgpp
TROOT.LINUX.LINUX   := /usr
TROOT.LINUX.WIN32   := /usr/i686-w64-mingw32
TROOT.LINUX.WIN64   := /usr/x86_64-w64-mingw32
TROOT.LINUX.GBA     := /usr/armv4t-agb-eabi
TROOT.LINUX.IBMPC   := /usr/i586-pc-msdosdjgpp

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

# Native, Xcode
AS.DARWIN.DARWIN.XCODE    := /usr/bin/as      # Xcode
CC.DARWIN.DARWIN.XCODE    := /usr/bin/clang
CXX.DARWIN.DARWIN.XCODE   := /usr/bin/clang++
AR.DARWIN.DARWIN.XCODE    := /usr/bin/ar
OCPY.DARWIN.DARWIN.XCODE  := /usr/bin/objcopy
STRIP.DARWIN.DARWIN.XCODE := /usr/bin/strip

# 32-bit Windows
AS.DARWIN.WIN32.MINGW32    := /usr/local/bin/i686-w64-mingw32-as
CC.DARWIN.WIN32.MINGW32    := /usr/local/bin/i686-w64-mingw32-gcc
CXX.DARWIN.WIN32.MINGW32   := /usr/local/bin/i686-w64-mingw32-g++
AR.DARWIN.WIN32.MINGW32    := /usr/local/bin/i686-w64-mingw32-ar
OCPY.DARWIN.WIN32.MINGW32  := /usr/local/bin/i686-w64-mingw32-objcopy
STRIP.DARWIN.WIN32.MINGW32 := /usr/local/bin/i686-w64-mingw32-strip

# 64-bit Windows
AS.DARWIN.WIN64.MINGW32    := /usr/local/bin/x86_64-w64-mingw32-as
CC.DARWIN.WIN64.MINGW32    := /usr/local/bin/x86_64-w64-mingw32-gcc
CXX.DARWIN.WIN64.MINGW32   := /usr/local/bin/x86_64-w64-mingw32-g++
AR.DARWIN.WIN64.MINGW32    := /usr/local/bin/x86_64-w64-mingw32-ar
OCPY.DARWIN.WIN64.MINGW32  := /usr/local/bin/x86_64-w64-mingw32-objcopy
STRIP.DARWIN.WIN64.MINGW32 := /usr/local/bin/x86_64-w64-mingw32-strip

# Game Boy Advance
AS.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.DARWIN.GBA.DKARM   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.DARWIN.GBA.DKARM  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.DARWIN.GBA.DKARM := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# Dev tools
INSTALL.DARWIN := /usr/local/bin/ginstall
ECHO.DARWIN := /usr/local/bin/gecho
CP.DARWIN := /usr/local/bin/gcp

# Linux host

# Native, GNU
AS.LINUX.LINUX.GNU  := /usr/bin/as
CC.LINUX.LINUX.GNU  := /usr/bin/gcc
CXX.LINUX.LINUX.GNU := /usr/bin/g++
AR.LINUX.LINUX.GNU  := /usr/bin/ar

# Native, LLVM
CC.LINUX.LINUX.LLVM  := /usr/bin/clang
CXX.LINUX.LINUX.LLVM := /usr/bin/clang++
AR.LINUX.LINUX.LLVM  := /usr/bin/ar

# 32-bit Windows
AS.LINUX.WIN32.MINGW32    := /usr/bin/i686-w64-mingw32-as
CC.LINUX.WIN32.MINGW32    := /usr/bin/i686-w64-mingw32-gcc
CXX.LINUX.WIN32.MINGW32   := /usr/bin/i686-w64-mingw32-g++
AR.LINUX.WIN32.MINGW32    := /usr/bin/i686-w64-mingw32-ar
OCPY.LINUX.WIN32.MINGW32  := /usr/bin/i686-w64-mingw32-objcopy
STRIP.LINUX.WIN32.MINGW32 := /usr/bin/i686-w64-mingw32-strip

# 64-bit Windows
AS.LINUX.WIN64.MINGW32    := /usr/bin/x86_64-w64-mingw32-as
CC.LINUX.WIN64.MINGW32    := /usr/bin/x86_64-w64-mingw32-gcc
CXX.LINUX.WIN64.MINGW32   := /usr/bin/x86_64-w64-mingw32-g++
AR.LINUX.WIN64.MINGW32    := /usr/bin/x86_64-w64-mingw32-ar
OCPY.LINUX.WIN64.MINGW32  := /usr/bin/x86_64-w64-mingw32-objcopy
STRIP.LINUX.WIN64.MINGW32 := /usr/bin/x86_64-w64-mingw32-strip

# Game Boy Advance
AS.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-as
CC.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc
CXX.DARWIN.GBA.DKARM   := /opt/devkitpro/devkitARM/bin/arm-none-eabi-g++
AR.DARWIN.GBA.DKARM    := /opt/devkitpro/devkitARM/bin/arm-none-eabi-ar
OCPY.DARWIN.GBA.DKARM  := /opt/devkitpro/devkitARM/bin/arm-none-eabi-objcopy
STRIP.DARWIN.GBA.DKARM := /opt/devkitpro/devkitARM/bin/arm-none-eabi-strip

# Dev tools
INSTALL.LINUX  := /usr/bin/install
ECHO.LINUX  := /bin/echo
CP.LINUX  := /usr/bin/cp
