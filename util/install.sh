#!/bin/sh
# -*- coding: utf-8 -*-

if [ "$1" = '' ]; then
	_prefix="$1";
else
	_prefix='/opt/aq';
fi

mkdir -p "${_prefix}/share/slick";
install -m644 -T 'src/base.mk' "${_prefix}/share/slick/base.mk";
install -m644 -T 'src/targets.mk' "${_prefix}/share/slick/targets.mk";
