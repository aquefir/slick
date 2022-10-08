#!/bin/sh
# -*- coding: utf-8 -*-

if test "$1" != '--straight'; then
	. util/getcosmo.sh;
	. util/mkibmpc.sh;
fi

_echo='/bin/echo'; # ensure it is not a bashism

if test "$(id -u)" = '0'; then
	_sudo='';
else
	_sudo='sudo ';
fi

if test "${PREFIX}" = ''; then
	_prefix='';
else
	_prefix="${PREFIX}";
fi

${_echo} -n 'Creating folder hierarchies...' >/dev/stderr;
${_sudo} mkdir -p "${_prefix}/opt/aq/lib/slick/cosmo";
${_sudo} mkdir -p "${_prefix}/opt/aq/lib/slick/ibmpc";
${_sudo} mkdir -p "${_prefix}/opt/aq/bin";
${_echo} ' done.' >/dev/stderr;

if test "$1" != '--straight'; then
	${_echo} -n 'Copying Cosmopolitan files...' >/dev/stderr;
	${_sudo} cp build/cosmo/ape.lds "${_prefix}/opt/aq/lib/slick/cosmo/ape.lds";
	${_sudo} cp build/cosmo/ape.o "${_prefix}/opt/aq/lib/slick/cosmo/ape.o";
	${_sudo} cp build/cosmo/cosmopolitan.a \
		"${_prefix}/opt/aq/lib/slick/cosmo/cosmopolitan.a";
	${_sudo} cp build/cosmo/cosmopolitan.h \
		"${_prefix}/opt/aq/lib/slick/cosmo/cosmopolitan.h";
	${_sudo} cp build/cosmo/crt.o "${_prefix}/opt/aq/lib/slick/cosmo/crt.o";
	${_echo} ' done.' >/dev/stderr;

	${_echo} -n 'Copying IBM-PC files...' >/dev/stderr;
	${_sudo} cp build/ibmpc/crt0.o "${_prefix}/opt/aq/lib/slick/ibmpc/crt0.o";
	${_sudo} cp src/ibmpc/ibmpc.ld "${_prefix}/opt/aq/lib/slick/ibmpc/ibmpc.ld";
	${_echo} ' done.' >/dev/stderr;
fi

${_echo} -n 'Copying the Makefiles...' >/dev/stderr;
${_sudo} cp src/base.mk "${_prefix}/opt/aq/lib/slick/base.mk";
${_sudo} cp src/targets.mk "${_prefix}/opt/aq/lib/slick/targets.mk";
${_echo} ' done.' >/dev/stderr;

${_echo} -n 'Copying tools...' >/dev/stderr;
${_sudo} cp util/initrepo.py "${_prefix}/opt/aq/bin/initrepo";
${_echo} ' done.' >/dev/stderr;

${_echo} -n 'Copying tool assets...' >/dev/stderr;
${_sudo} cp -r share "${_prefix}/opt/aq/";
${_echo} ' done.' >/dev/stderr;

[ ! -d "${_prefix}/etc/profile.d" ] || { ${_echo} -n \
	'Copying profile script addenda...' >/dev/stderr; \
	${_sudo} cp src/aquefir.sh "${_prefix}/etc/profile.d/aquefir.sh" && \
	${_echo} ' done.' >/dev/stderr; }

${_echo} 'All done. Exiting...' >/dev/stderr;

unset _echo _sudo _prefix;
