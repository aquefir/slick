#!/bin/sh
# -*- coding: utf-8 -*-

# sha256sum of cosmo.zip from the 0.2.0 release
_sum='27fc6e23898b8e0b5a7ca42b932c88ddfa0f2f7f306f72abe931128b72149c27';
# root folder to put outputs into
_root='build';
_echo='/bin/echo';

command -v curl >/dev/null 2>&1 || { \
	${_echo} 'curl was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }
command -v unzip >/dev/null 2>&1 || { \
	${_echo} 'unzip was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }
command -v sha256sum >/dev/null 2>&1 || {\
	${_echo} 'sha256sum was not found on your system. Exiting...' \
		>/dev/stderr; exit 127; }

if [ ! -d "${_root}" ] && [ ! -h "${_root}" ]; then
	if [ -f "${_root}" ]; then
		${_echo} "output folder \"${_root}\" is not a directory or a symbolic" \
			' link. Exiting...' >/dev/stderr;
		exit 127;
	fi
	mkdir -p "${_root}"; # -p for when root is multiple levels deep
fi

if [ -f "${_root}/cosmo.zip" ]; then
	${_echo} 'Cosmopolitan amalgamated binaries already downloaded.' \
	'Skipping...' >/dev/stderr;
else
	${_echo} -n 'Downloading the Cosmopolitan amalgamated binaries... ' \
	>/dev/stderr;
	curl -sD ${_root}/headers.tmp -o "${_root}/cosmo.zip" \
		https://justine.lol/cosmopolitan/cosmopolitan-amalgamation-0.2.zip;
	_x=$?;
	if [ ! -f "${_root}/headers.tmp" ]; then
		${_echo} -e "failed!\n${_root}/headers.tmp was not found on disk." \
		' Exiting...' >/dev/stderr;
		exit 127;
	elif [ "$(cat "${_root}/headers.tmp" | head -n 1 | awk '{print $2}')" \
	!= '200' ]; then
		${_echo} -e "failed!\nHTTP status code was $(cat \
		"${_root}/headers.tmp" | head -n 1 | awk '{print $2}'). Exiting..." \
		>/dev/stderr;
		exit 127;
	elif [ "$_x" != '0' ]; then
		${_echo} -e "failed!\nExit code was $_x. Exiting..." >/dev/stderr;
		exit 127;
	fi
	${_echo} 'done.' >/dev/stderr;
fi

${_echo} -n 'Verifying the integrity of the archive... ' >/dev/stderr;
if [ "$_sum" != \
"$(sha256sum "${_root}/cosmo.zip" | awk '{print $1}')" ]; then
	${_echo} -e 'failed!\nSHA2-256 checksums did not match. Exiting...' \
	>/dev/stderr;
	exit 127;
fi

${_echo} 'passed!' >/dev/stderr;

if [ -d "${_root}/cosmo" ]; then
	${_echo} 'Cosmopolitan extract directory already exists. Skipping...' \
	>/dev/stderr;
else
	${_echo} -n 'Making Cosmopolitan extract directory... ' >/dev/stderr;
	mkdir "${_root}/cosmo";
	_x=$?;
	if [ "$_x" != '0' ]; then
		${_echo} -e "failed!\nExit code was $_x. Exiting..." >/dev/stderr;
		exit 127;
	fi
	${_echo} 'done.' >/dev/stderr;
fi

${_echo} -n 'Extracting the binaries... ' >/dev/stderr;
unzip -qu "${_root}/cosmo.zip" -d "${_root}/cosmo";
_x=$?;

if [ "$_x" = '0' ]; then
	${_echo} 'done.' >/dev/stderr;
else
	${_echo} -e "failed!\nExit code was $_x. Exiting..." >/dev/stderr;
	exit 127;
fi

${_echo} -n 'Cleaning up... ' >/dev/stderr;
rm -f "${_root}/headers.tmp";
${_echo} 'done.' >/dev/stderr;

unset _x _sum _root _echo;
