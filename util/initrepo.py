#!/usr/bin/env python3
# -*- coding: utf-8 -*-
## Copyright © 2020-2021 Aquefir.
## Released under BSD-2-Clause.

LICENCES = [
	'AGPL',
	'Apache2',
	'BSD-0C',
	'BSD-1C',
	'BSD-2C',
	'BSD-3C',
	'BSD-4C',
	'BSD-OG',
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
	'CC-BY-SA-40',
	'FDL',
	'GPL2',
	'LGPL21',
	'MPL2'
]

LICENCE_NAMES = [
	'GNU Affero GPLv3',
	'Apache 2.0',
	'BSD-0-Clause',
	'BSD-1-Clause',
	'BSD-2-Clause',
	'BSD-3-Clause',
	'BSD-4-Clause',
	'Old BSD License',
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
	'Creative Commons BY-SA 4.0',
	'GNU Free Documentation License.',
	'GNU General Public License v2',
	'GNU Lesser GPL v2.1',
	'Mozilla Public License 2.0'
]

from sys import stdin, stdout
from os import getcwd, path
from subprocess import call

def mkbplate(title, copy_years, org, licnum, sh):
	lhs = ' *'
	rhs = '*'
	if sh:
		lhs = '##'
		rhs = '##'
	ret = ''
	if sh:
		ret += ('#' * 78) + '\n'
	else:
		ret += '/' + ('*' * 76) + '\\\n'
	title_len = len(title)
	if title_len % 2:
		title += '\u2122'
		title_len += 1
	spaces = ' ' * ((74 - title_len) // 2)
	ret += lhs + spaces + title + spaces + rhs + '\n'
	ret += lhs + (' ' * 74) + rhs + '\n'
	copy = 'Copyright © ' + copy_years + ' ' + org
	if len(copy_years) % 2:
		copy += '.'
	spaces = ' ' * ((74 - len(copy)) // 2)
	ret += lhs + spaces + copy + spaces + rhs + '\n'
	lic = 'Released under ' + LICENCE_NAMES[licnum - 1]
	if len(lic) % 2:
		lic += '.'
	spaces = ' ' * ((74 - len(lic)) // 2)
	ret += lhs + spaces + lic + spaces + rhs + '\n'
	if sh:
		ret += '#' * 78
	else:
		ret += '\\' + ('*' * 76) + '/'
	return ret

def printbplate(title, copy_years, org, licnum):
	return 'This file contains the project’s copypastable boilerplate comment headers.\n\nBoilerplate for C-like languages:\n\n' + \
		mkbplate(title, copy_years, org, licnum, False) + \
		'\n\nHash-based boilerplate (Python, POSIX shell, Makefile):\n\n' + \
		mkbplate(title, copy_years, org, licnum, True) + '\n'

def strlicq(lics):
	ret = 'Choose a licence:\n'
	i = 0
	lics_len = len(lics)
	while i < lics_len:
		ret += str(i + 1) if i >= 9 else ' ' + str(i + 1)
		ret += '. ' + lics[i] + '\n'
		i += 1
	return ret

def mkdir(p):
	from os import mkdir as mkdir_
	#from os import FileExistsError
	try:
		mkdir_(p)
	except FileExistsError as e:
		pass

slickdir = path.join(path.dirname(path.realpath(__file__)), '..')

def pause():
	input('\n')

def yesno(msg):
	resp = 0
	firs = True
	while resp != 'y' and resp != 'n':
		if not firs:
			stdout.write('\nInvalid value \u2018' + resp + '\u2019\n')
		stdout.write(msg + ' ')
		stdout.flush()
		resp = stdin.read(1)
		firs = False
	stdout.write('\n')
	return True if resp == 'y' else False

def multich(msg, opt_ct):
	num = 0
	firs = True
	while num > opt_ct or num == 0:
		if not firs:
			stdout.write('\nInvalid value \u2018' + str(num) + '\u2019\n')
		stdout.write(msg + ' ')
		stdout.flush()
		num = int(input())
		firs = False
	return num

def prompt(msg):
	stdout.write(msg + ' ')
	stdout.flush()
	return stdin.readline()

def main(args):
	# get information from user
	title = prompt('What is the name of the project?')[:-1]
	org = prompt('Who is the author or organisation?')[:-1]
	n = multich('Is this for a library (1) or program (2)?', 2)
	makefile = 'Makefile.library' if n == 1 else 'Makefile.program'
	gitinit = False
	licnum = None
	cwd = getcwd()
	if not path.exists(path.join(cwd, '.git')):
		if yesno('Initialise a git repository?'):
			gitinit = True
	if yesno('Add a licence?'):
		licnum = multich(strlicq(LICENCES), len(LICENCES))
		lic = path.join('COPYING.' + LICENCES[licnum - 1])
	stdout.write('Ready to commit. Press any key to continue. ')
	pause()
	stdout.write('\n')
	from shutil import copyfile
	copyfile(path.join(slickdir, 'src', makefile), path.join(cwd, 'Makefile'))
	f = open(path.join(cwd, 'Makefile'), 'r')
	tmp = f.read()
	f.close()
	tmp = tmp.replace('@BOILERPLATE@',
		mkbplate(title, str(2020), org, licnum, True))
	tmp = tmp.replace('@TITLE@', title)
	print('=====')
	print(tmp)
	print('=====')
	f = open(path.join(cwd, 'Makefile'), 'w')
	f.write(tmp)
	f.flush()
	f.close()
	if lic:
		copyfile(path.join(slickdir, 'src', 'COPYING.' + LICENCES[licnum - 1]),
		path.join(cwd, 'COPYING'))
	copyfile(path.join(slickdir, 'src', 'gitattributes'),
		path.join(cwd, '.gitattributes'))
	copyfile(path.join(slickdir, 'src', 'gitignore'),
		path.join(cwd, '.gitignore'))
	mkdir(path.join(cwd, 'doc'))
	mkdir(path.join(cwd, 'etc'))
	mkdir(path.join(cwd, 'data'))
	mkdir(path.join(cwd, 'util'))
	mkdir(path.join(cwd, 'src'))
	mkdir(path.join(cwd, 'include'))
	f = open(path.join(cwd, 'etc', 'BOILERPLATE'), 'w')
	f.write(printbplate(title, str(2020), org, licnum))
	f.flush()
	f.close()
	if gitinit:
		call(['git', 'init'])
	print('All done. Exiting...')
	return 0

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
