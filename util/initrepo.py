#!/usr/bin/env python3
# -*- coding: utf-8 -*-
## Copyright © 2020-2021 Aquefir.
## Released under BSD-2-Clause.

LICENCES = [ [
		'AGPL',
		'FDL',
		'GPL2',
		'LGPL21'
	], [
		'BSD-0C',
		'BSD-1C',
		'BSD-2C',
		'BSD-3C',
		'BSD-4C',
		'BSD-OG'
	], [
		'CC-BY-30',
		'CC-BY-40',
		'CC-BY-NC-30',
		'CC-BY-NC-40',
		'CC-BY-NC-ND-30',
		'CC-BY-NC-ND-40',
		'CC-BY-NC-SA-30',
		'CC-BY-NC-SA-40',
		'CC-BY-ND-30',
		'CC-BY-ND-40',
		'CC-BY-SA-30',
		'CC-BY-SA-40'
	], [
		'Apache2',
		'MPL2',
		'ASL',
		'CIRNO'
	]
]

LICENCE_NAMES = [ [
		'GNU Affero GPLv3',
		'GNU Free Documentation License',
		'GNU General Public License 2.0',
		'GNU Lesser General Public License 2.1'
	], [
		'BSD-0-Clause',
		'BSD-1-Clause',
		'BSD-2-Clause',
		'BSD-3-Clause',
		'BSD-4-Clause',
		'Old BSD License'
	], [
		'Creative Commons BY 3.0',
		'Creative Commons BY 4.0',
		'Creative Commons BY-NC 3.0',
		'Creative Commons BY-NC 4.0',
		'Creative Commons BY-NC-ND 3.0',
		'Creative Commons BY-NC-ND 4.0',
		'Creative Commons BY-NC-SA 3.0',
		'Creative Commons BY-NC-SA 4.0',
		'Creative Commons BY-ND 3.0',
		'Creative Commons BY-ND 4.0',
		'Creative Commons BY-SA 3.0',
		'Creative Commons BY-SA 4.0'
	], [
		'Apache 2.0',
		'Mozilla Public License 2.0',
		'Artisan Software Licence',
		'THE STRONGEST PUBLIC LICENSE'
	]
]

def print2(s: str):
	from sys import stderr
	s2 = s.rstrip('\r\n') + '\n'
	stderr.buffer.write(s2.encode('utf-8'))
	stderr.buffer.flush()

def ia_multi(question: str, num_choices: int):
	from sys import stdout, stdin
	s = question.rstrip('\r\n') + ' '
	stdout.buffer.write(s.encode('utf-8'))
	stdout.buffer.flush()
	r = int(stdin.read((num_choices // 10) + 1), 10)
	if r <= num_choices:
		return r
	else:
		print2('Choice %i is out of range (1-%i)' % (r, num_choices))
		return -1

def ia_yesno(question: str, default: str):
	from sys import stdout, stdin
	# this is the default value for the choice string
	# it is mutated for a default yes or no answer if none is given
	# it is also checked later to effect that end
	# lastly, it is interpolated into the question string to stdout
	choice = 'y/n'
	# for case-insensitive checking
	default = default.lower()
	if default == 'y':
		choice = 'Y/n'
	elif default == 'n':
		choice = 'y/N'
	# finalise the question string
	s = question.rstrip('\r\n') + ' [' + choice + '] '
	sb = s.encode('utf-8')
	stdout.buffer.write(sb)
	# say it right
	stdout.buffer.flush()
	# we need to loop in case invalid input is given, we ask again
	while True:
		r = stdin.readline()[:-1].lower()
		if r == '':
			if choice.startswith('Y'): return True
			elif choice.endswith('N'): return False
		elif r == 'y': return True
		elif r == 'n': return False
		s2 = 'Sorry, %s is not a valid answer.\n' % r
		stdout.buffer.write(s2.encode('utf-8'))
		stdout.buffer.write(sb)
		stdout.buffer.flush()


def ia_line(question: str):
	from sys import stdout, stdin
	s = question.rstrip('\r\n') + ' '
	stdout.buffer.write(s.encode('utf-8'))
	stdout.buffer.flush()
	r = stdin.readline()
	return r.rstrip('\r\n')

def ia_init():
	name_project = ia_line('Full name of the project:')
	name_author = ia_line('Personal or organisation name:')
	legacy = ia_yesno('Is this an existing codebase?', 'n')
	library = True if ia_multi('Is this for a library (1) or a ' +
		'standalone program (2)?', 2) == 1 else False
	usevcs = ia_yesno('Should there be a git repository if none exists?',
		'y')
	lic_i: tuple[int, int] = (None, None)
	if ia_yesno('Should a licence file be added?', 'y'):
		n = ia_multi('Select the licence group from which to choose: (1) GPL' +
			',\n (2) BSD, (3) Creative Commons, or (4) Others', 4)
		if n == 1:
			n2 = ia_multi('Select the licence to use: (1) AGPLv3, (2) FDL,\n' +
				'(3) GPLv2, or (4) LGPLv2.1', 4)
			lic_i = (n, n2)
		elif n == 2:
			pass
	# WIP unfinished
