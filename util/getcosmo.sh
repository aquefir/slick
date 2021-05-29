#!/bin/sh
# -*- coding: utf-8 -*-

# sha256sum of cosmo.zip from the 1.0 release
_sum='d6a11ec4cf85d79d172aacb84e2894c8d09e115ab1acec36e322708559a711cb';
# root folder to put outputs into
_root='build';
_echo='/bin/echo';

command -v curl >/dev/null 2>&1 || { \
	${_echo} 'curl was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }
command -v unzip >/dev/null 2>&1 || { \
	${_echo} 'unzip was not found on your system. Exiting...' >/dev/stderr; \
	exit 127; }
if test "$(uname -s)" = 'Darwin'; then
	command -v shasum >/dev/null 2>&1 || {\
		${_echo} 'shasum was not found on your system. Exiting...' \
			>/dev/stderr; exit 127; }
	_sha256='shasum -a 256'
else
	command -v sha256sum >/dev/null 2>&1 || {\
		${_echo} 'sha256sum was not found on your system. Exiting...' \
			>/dev/stderr; exit 127; }
	_sha256=sha256sum
fi

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
		https://justine.lol/cosmopolitan/cosmopolitan-amalgamation-1.0.zip;
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
"$(${_sha256} "${_root}/cosmo.zip" | awk '{print $1}')" ]; then
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
