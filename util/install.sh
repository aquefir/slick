#!/bin/sh
# -*- coding: utf-8 -*-

. util/getcosmo.sh;
. util/mkibmpc.sh;

if test "$(id -u)" = '0'; then
	_sudo='';
else
	_sudo='sudo ';
fi

if test "${PREFIX}" = ''; then
	_prefix=/opt/aq/lib/slick;
else
	_prefix="${PREFIX}";
fi

echo -n 'Creating folder hierarchies...' >/dev/stderr;
${_sudo} mkdir -p "${_prefix}/cosmo";
${_sudo} mkdir -p "${_prefix}/ibmpc";
echo ' done.' >/dev/stderr;

echo -n 'Copying Cosmopolitan files...' >/dev/stderr;
${_sudo} cp build/cosmo/ape.lds "${_prefix}/cosmo/ape.lds";
${_sudo} cp build/cosmo/ape.o "${_prefix}/cosmo/ape.o";
${_sudo} cp build/cosmo/cosmopolitan.a "${_prefix}/cosmo/cosmopolitan.a";
${_sudo} cp build/cosmo/cosmopolitan.h "${_prefix}/cosmo/cosmopolitan.h";
${_sudo} cp build/cosmo/crt.o "${_prefix}/cosmo/crt.o";
echo ' done.' >/dev/stderr;

echo -n 'Copying IBM-PC files...' >/dev/stderr;
${_sudo} cp build/ibmpc/crt0.o "${_prefix}/ibmpc/crt0.o";
${_sudo} cp src/ibmpc/ibmpc.ld "${_prefix}/ibmpc/ibmpc.ld";
echo ' done.' >/dev/stderr;

echo -n 'Copying the Makefiles...' >/dev/stderr;
${_sudo} cp src/base.mk "${_prefix}/base.mk";
${_sudo} cp src/targets.mk "${_prefix}/targets.mk";
echo ' done.' >/dev/stderr;

[ ! -d /etc/profile.d ] || echo -n 'Copying profile script addenda...' \
	>/dev/stderr; ${_sudo} cp src/aquefir.sh /etc/profile.d/aquefir.sh && \
	echo ' done.' >/dev/stderr;

echo 'All done. Exiting...' >/dev/stderr;
