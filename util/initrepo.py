#!/usr/bin/env python3
# -*- coding: utf-8 -*-

LICENCES = [
	'BSD-2C',
	'MPL2'
]

from sys import stdin, stdout
from os import getcwd, mkdir, path
from subprocess import call

slickdir = path.join(path.realpath(__file__), '..')
print(slickdir)

def pause():
	stdin.read(1)
	stdout.write('\n')

def yesno(msg):
	resp = 0
	firs = False
	while resp != 'y' and resp != 'n':
		if not firs:
			stdout.write('\nInvalid value \u2018' + resp + '\u2019\n')
		stdout.write(msg + ' ')
		resp = int(stdin.read(1))
		firs = True
	stdout.write('\n')
	return True if resp == 'y' else False

def multich(msg, opt_ct):
	num = 0
	firs = False
	while num > opt_ct or num == 0:
		if not firs:
			stdout.write('\nInvalid value \u2018' + num + '\u2019\n')
		stdout.write(msg + ' ')
		num = int(stdin.readline()[:-1])
		firs = True
	return num

def prompt(msg):
	stdout.write(msg + ' ')
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
		n = multich('Use BSD-2 (1) or MPL2 (2)?', 2)
		lic = path.join('etc', 'COPYING.' + LICENCES[n])
	stdout.write('Ready to commit. Press any key to continue. ')
	pause()
	stdout.write('\n')
	from shutil import copyfile
	copyfile(path.join(slickdir, 'src', makefile), path.join(cwd, 'Makefile'))
	if lic:
		copyfile(path.join(slickdir, 'etc', lic), path.join(cwd, 'COPYING'))
	copyfile(path.join(slickdir, 'etc', 'gitattributes'),
		path.join(cwd, '.gitattributes'))
	copyfile(path.join(slickdir, 'etc', 'gitignore'),
		path.join(cwd, '.gitignore'))
	mkdir(path.join(cwd, 'doc'))
	mkdir(path.join(cwd, 'etc'))
	mkdir(path.join(cwd, 'data'))
	mkdir(path.join(cwd, 'util'))
	mkdir(path.join(cwd, 'src'))
	mkdir(path.join(cwd, 'include'))
	copyfile(path.join(slickdir, 'src', 'base.mk'),
		path.join(cwd, 'etc', 'base.mk'))
	copyfile(path.join(slickdir, 'src', 'targets.mk'),
		path.join(cwd, 'etc', 'targets.mk'))
	if gitinit:
		call(['git', 'init'])
	print('All done. Exiting...')
	return 0

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
