#!/bin/sh
# -*- coding: utf-8 -*-

_root='build/ibmpc';

# need GNU as for creating crt0.o
command -v as >/dev/null 2>&1 || { \
	echo 'as was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }

if [ ! -d "${_root}" ] && [ ! -h "${_root}" ]; then
	if [ -f "${_root}" ]; then
		echo "output folder \"${_root}\" is a regular file. Exiting..." \
			>/dev/stderr;
		exit 127;
	fi
	mkdir -p "${_root}"; # -p for when root is multiple levels deep
fi

as --32 -march=i386 -o "${_root}/crt0.o" src/ibmpc/crt0.s;
