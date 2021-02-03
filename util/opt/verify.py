#!/usr/bin/env python3
# -*- coding: utf-8 -*-
## Copyright © 2020-2021 Aquefir.
## Released under BSD-2-Clause.
#
# This module validates files as ASCII compatible.

def validate(text):
	for b in text:
		if b > 0x7F:
			return False
	return True

def main(args):
	files = args[1:]
	valid = True
	from sys import stdout
	for file in files:
		text = None
		if file == '-':
			from sys import stdin
			text = stdin.buffer.read()
		else:
			text = open(file, 'rb').read()
		if not validate(text):
			valid = False
			break
	print('' if valid else 'invalid')
	return 0 if valid else 1

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
