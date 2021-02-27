#!/bin/sh
# -*- coding: utf-8 -*-

_root='build/ibmpc';

if [ "$(uname -s)" = 'Darwin' ]; then
	_as=gas;
else
	_as=as;
fi

# need GNU as for creating crt0.o
command -v "${_as}" >/dev/null 2>&1 || { \
	echo 'as was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }

if [ ! -d "${_root}" ] && [ ! -h "${_root}" ]; then
	if [ -f "${_root}" ]; then
		echo "Output folder \"${_root}\" is a regular file. Exiting..." \
			>/dev/stderr;
		exit 127;
	fi
	mkdir -p "${_root}"; # -p for when root is multiple levels deep
fi

if [ -f "${_root}/crt0.o" ]; then
	echo 'crt0 already assembled. Exiting...' >/dev/stderr;
	return 0;
fi

echo -n 'Assembling crt0...' >/dev/stderr;
as --32 -march=i386 -o "${_root}/crt0.o" src/ibmpc/crt0.s >/dev/null 2>&1;
_x=$?;

if [ "$_x" = '0' ]; then
	echo 'done.' >/dev/stderr;
else
	echo -e "failed!\nExit code was $_x. Exiting..." >/dev/stderr;
	exit 127;
fi

unset _root;
return 0;
