#!/bin/sh
# -*- coding: utf-8 -*-

_root='build/ibmpc';
_echo='/bin/echo';

if [ "$(uname -s)" = 'Darwin' ]; then
	if [ ! -d '/usr/local/opt/x86_64-elf-binutils/bin' ]; then
		${_echo} 'as was not found on your system.\nRun' \
		'‘brew install x86_64-elf-binutils’ to fix this. Exiting...' \
		>/dev/stderr;
		exit 127;
	fi
	_as='/usr/local/opt/x86_64-elf-binutils/bin/x86_64-elf-as';
else
	_as=as;
fi

# need GNU as for creating crt0.o
command -v "${_as}" >/dev/null 2>&1 || { \
	${_echo} 'as was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }

if [ ! -d "${_root}" ] && [ ! -h "${_root}" ]; then
	if [ -f "${_root}" ]; then
		${_echo} "Output folder \"${_root}\" is a regular file. Exiting..." \
			>/dev/stderr;
		exit 127;
	fi
	mkdir -p "${_root}"; # -p for when root is multiple levels deep
fi

if [ -f "${_root}/crt0.o" ]; then
	${_echo} 'crt0 already assembled. Exiting...' >/dev/stderr;
	return 0;
fi

${_echo} -n 'Assembling crt0...' >/dev/stderr;
${_as} --32 -march=i386 -o "${_root}/crt0.o" src/ibmpc/crt0.s >/dev/null 2>&1;
_x=$?;

if [ "$_x" = '0' ]; then
	${_echo} 'done.' >/dev/stderr;
else
	${_echo} -e "failed!\nExit code was $_x. Exiting..." >/dev/stderr;
	exit 127;
fi

unset _root _x _echo;
