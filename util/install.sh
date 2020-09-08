#!/bin/sh
# -*- coding: utf-8 -*-

if [ "$1" != '' ]; then
	_prefix="$1";
else
	_prefix='/opt/aq';
fi

mkdir -p "${_prefix}/lib/slick";
install -m644 -T 'src/base.mk' "${_prefix}/lib/slick/base.mk";
install -m644 -T 'src/targets.mk' "${_prefix}/lib/slick/targets.mk";
