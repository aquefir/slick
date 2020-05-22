#!/usr/bin/env python3
# -*- coding: utf-8 -*-
## Copyright © 2020 Aquefir.
## Released under BSD-2-Clause.

def validate(text):
	for b in text:
		if b > 0x7F or (b < 0x20 and b != 0xA and b != 0xD):
			return False
	return True

def main(args):
	files = args[1:]
	valid = False
	from sys import stdout
	if len(files) == 1 and files[0] == '-':
		# read from stdin instead
		from sys import stdin
		stdout.write('Validating standard input...')
		stdout.flush()
		text = stdin.buffer.read()
		if validate(text) == True:
			print(' passed.')
			return 0
		else:
			print(' failed!')
			return 1
	allpass = True
	for f in files:
		stdout.write('Validating %s ...' % f)
		stdout.flush()
		text = open(f, 'rb').read()
		if validate(text) == True:
			print(' passed.')
		else:
			print(' failed!')
			allpass = False
		stdout.flush()
	return 0 if allpass == True else 1

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
