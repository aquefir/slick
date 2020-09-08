#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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

from sys import stdin, stdout
from os import getcwd, path
from subprocess import call

def strlicq(lics):
	ret = 'Choose a licence:\n'
	i = 0
	lics_len = len(lics)
	while i < lics_len:
		ret += str(i + 1) if i < 9 else ' ' + str(i + 1)
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
	n = multich('Is this for a library (1) or program (2)?', 2)
	makefile = 'Makefile.library' if n == 1 else 'Makefile.program'
	gitinit = False
	lic = None
	cwd = getcwd()
	if not path.exists(path.join(cwd, '.git')):
		if yesno('Initialise a git repository?'):
			gitinit = True
	if yesno('Add a licence?'):
		n = multich(strlicq(LICENCES), len(LICENCES))
		lic = path.join('COPYING.' + LICENCES[n - 1])
	stdout.write('Ready to commit. Press any key to continue. ')
	pause()
	stdout.write('\n')
	from shutil import copyfile
	copyfile(path.join(slickdir, 'src', makefile), path.join(cwd, 'Makefile'))
	if lic:
		copyfile(path.join(slickdir, 'src', lic), path.join(cwd, 'COPYING'))
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
	if gitinit:
		call(['git', 'init'])
	print('All done. Exiting...')
	return 0

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
