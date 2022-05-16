#!/usr/bin/env python3
# -*- coding: utf-8 -*-
## Copyright © 2020-2021 Aquefir.
## Released under BSD-2-Clause.

from os import path, getcwd

# This marks whether the licence text needs to be mutated with
# authorship and copyright information.
LICENCES_MUTATE = [
	[False] * 4,
	[True] * 6,
	[False] * 12,
	[
		False,
		False,
		True,
		False
	]
]

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
		' 1. GNU Affero GPLv3',
		' 2. GNU Free Documentation License',
		' 3. GNU General Public License 2.0',
		' 4. GNU Lesser General Public License 2.1'
	], [
		' 1. BSD-0-Clause',
		' 2. BSD-1-Clause',
		' 3. BSD-2-Clause',
		' 4. BSD-3-Clause',
		' 5. BSD-4-Clause',
		' 6. Old BSD License'
	], [
		' 1. Creative Commons BY 3.0',
		' 2. Creative Commons BY 4.0',
		' 3. Creative Commons BY-NC 3.0',
		' 4. Creative Commons BY-NC 4.0',
		' 5. Creative Commons BY-NC-ND 3.0',
		' 6. Creative Commons BY-NC-ND 4.0',
		' 7. Creative Commons BY-NC-SA 3.0',
		' 8. Creative Commons BY-NC-SA 4.0',
		' 9. Creative Commons BY-ND 3.0',
		'10. Creative Commons BY-ND 4.0',
		'11. Creative Commons BY-SA 3.0',
		'12. Creative Commons BY-SA 4.0'
	], [
		' 1. Apache 2.0',
		' 2. Mozilla Public License 2.0',
		' 3. Artisan Software Licence',
		' 4. THE STRONGEST PUBLIC LICENSE'
	]
]

LICENCE_GROUPS = [
	' 1. GPL variants',
	' 2. BSD variants',
	' 3. Creative Commons',
	' 4. Others'
]

MAKEFILES = ['program', 'library']

HELP_TEXT = r'''
Slick-compatible project init script

Created by Alexander Nicholi.
Copyright (C) 2020-2022 Aquefir.
Released under BSD-2-Clause.

Usage:
  initrepo can either be called interactively or non-interactively.
  If you wish to use it non-interactively, you must call it with ALL of
  the following parameters in this form:
  
  initrepo <projectname> <author> <copyrightyears> <licence> <licname>
    <islibrary>

  Syntax:
    projectname := string
    author := string
    copyrightyears := string
    licence := filename of the form "COPYING.<lic>" where it forms a valid
               file name inside the src/ directory of Slick. may also be the
               string "none", in which case no licence is applied and
               boilerplates will read "All rights reserved."
    licname := Human-readable name of the licence, e.g. "BSD-2-Clause".
    islibrary := boolean, "1" for true "0" for false.
'''

SLICKDIR = '/opt/aq'
CWD = getcwd()

FILE_MAPS = [
	['', 'etc/BOILERPLATE'],
	['', '.clang-format'],
	['', 'COPYING'],
	['', '.gitattributes'],
	['', '.gitignore'],
	['', 'Makefile']
]

def make_boilerplate(title: str, years: str, author: str, licence: str, shelly: bool):
	lhs = '##' if shelly else ' *'
	rhs = '##' if shelly else '*'
	ret = ('#' * 78) + '\n' if shelly else '/' + ('*' * 76) + '\\\n'
	# add the full text to the lines before we fill them out and return them
	cpyrite = 'Copyright (C) ' + years + ' ' + author
	licence = 'All rights reserved' if licence == None else \
		'Released under ' + licence[4:]
	# compute sizes and oddities ahead of time for fattening later
	title_sz = len(title)
	title_odd = title_sz % 2
	cpyrite_sz = len(cpyrite)
	cpyrite_odd = cpyrite_sz % 2
	licence_sz = len(licence)
	licence_odd = licence_sz % 2
	# prefill spacer line
	spacer_line = lhs + (' ' * 74) + rhs + '\n'
	# fatten the title line
	fat_sz = ((74 - (title_sz + title_odd)) // 2)
	fat = ' ' * fat_sz
	# add the title line to the retval
	ret += lhs + fat + title + ('.' if title_odd else '') + \
		fat + rhs + '\n'
	ret += spacer_line
	# fatten the cpyrite line
	fat_sz = ((74 - (cpyrite_sz + cpyrite_odd)) // 2)
	fat = ' ' * fat_sz
	# add the cpyrite line to the retval
	ret += lhs + fat + cpyrite + ('.' if cpyrite_odd else '') + \
		fat + rhs + '\n'
	# fatten the licence line
	fat_sz = ((74 - (licence_sz + licence_odd)) // 2)
	fat = ' ' * fat_sz
	# add the licence line to the retval
	ret += lhs + fat + licence + ('.' if licence_odd else '') + \
		fat + rhs + '\n'
	# close out the comment boilerplate boxing
	ret += ('#' * 78) if shelly else '\\' + ('*' * 76) + '/'
	return ret

def print2(s: str):
	from sys import stderr
	s2 = s.rstrip('\r\n') + '\n'
	stderr.buffer.write(s2.encode('utf-8'))
	stderr.buffer.flush()

def readtxt(fpath: str):
	f = open(fpath, 'rb')
	ret = f.read().decode('utf-8')
	f.close()
	return ret

def writetxt(fpath: str, text: str):
	f = open(fpath, 'wb')
	f.write(text.encode('utf-8'))
	f.flush()
	f.close()

def pause():
	input('\n')

def mkdir(p):
	from os import mkdir as mkdir_
	#from os import FileExistsError
	try:
		mkdir_(p)
	except FileExistsError as e:
		pass

def readres(question: str, type: str, sz: int):
	from sys import stdout, stdin
	s = question.rstrip('\r\n') + ' '
	stdout.buffer.write(s.encode('utf-8'))
	stdout.buffer.flush()
	a = ''
	first = stdin.read(1)
	if first != '\n':
		a = first + stdin.read(sz - 1)
	else:
		a = stdin.read(sz)
	try:
		if type == 'int':
			return int(a, 10)
		elif type == 'str':
			return a
		else:
			raise Exception('readres() argument "type" must be "int" or "str"')
	except ValueError as e:
		print2('Invalid response "%s", please try again.')
		return readres(type, sz)

def ia_multi(question: str, num_choices: int):
	r = readres(question, 'int', (num_choices // 10) + 1)
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
	s = question.rstrip('\r\n') + ' [' + choice + ']'
	sb = s.encode('utf-8')
	while True:
		r = readres(s, 'str', 1)
		if r == '\n':
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

def mutate(fpath, bplate_c, bplate_sh, years, author):
	text = readtxt(fpath)
	if fpath == SLICKDIR + '/share/BOILERPLATE' == 0:
		text = text.replace('@BOILERPLATE1@', bplate_c)
		text = text.replace('@BOILERPLATE2@', bplate_sh)
	elif fpath.startswith(SLICKDIR + '/share/COPYING.'):
		text = text.replace('@YEARS@', years).replace('@AUTHOR@', author)
	elif fpath.startswith(SLICKDIR + '/share/Makefile.'):
		text = text.replace('@BOILERPLATE@', bplate_sh)
	return text

def ia_init():
	name_project = ia_line('Full name of the project:')
	name_author = ia_line('Personal or organisational author name:')
	years = '2022'
	library = 1 if ia_multi('Is this for a library (1) or a ' +
		'standalone program (2)?', 2) == 1 else 0
	lic_i = None
	lic_j = None
	licensed = ia_yesno('Should a licence file be added?', 'y')
	if licensed:
		lic_i = ia_multi('Select the category you wish to choose from:\n' +
			'\n'.join(LICENCE_GROUPS) + '\nChoice:', len(LICENCE_GROUPS)) - 1
		names_list = LICENCE_NAMES[lic_i]
		lic_j = ia_multi('Select the licence to use:\n' +
			'\n'.join(names_list) + '\nChoice:', len(names_list)) - 1
	from sys import stdout
	stdout.write('Ready to commit. Press any key to continue. ')
	stdout.flush()
	pause()
	stdout.write('\n')
	stdout.flush()
	return (name_project, name_author, years, library,
		SLICKDIR + '/share/COPYING.' + LICENCES[lic_i][lic_j],
		LICENCE_NAMES[lic_i][lic_j])

def main(args: 'list[str]'):
	argc = len(args)
	goods = ()
	if '-h' in args or '--help' in args:
		print2(HELP_TEXT)
		return 0
	elif argc == 1:
		goods = ia_init()
	elif argc != 7:
		print2(HELP_TEXT)
		return 0
	else:
		if argc == 7 and args[6] != '0' and args[6] != '1':
			print2('Invalid value for <islibrary>.\n')
			print2(HELP_TEXT)
			return 127
		goods = (args[1], args[2], args[3], 0 if args[6] == '0' else 1,
			SLICKDIR + '/share/' + args[4], args[5])
	BPLATE_C = make_boilerplate(goods[0], goods[2], goods[1],
		goods[5], False)
	BPLATE_SH = make_boilerplate(goods[0], goods[2], goods[1],
		goods[5], True)
	# finalise the source-destination filename mapping
	FILE_MAPS[0][0] = SLICKDIR + '/share/BOILERPLATE'
	FILE_MAPS[1][0] = SLICKDIR + '/share/clang-format'
	FILE_MAPS[2][0] = goods[4]
	FILE_MAPS[3][0] = SLICKDIR + '/share/gitattributes'
	FILE_MAPS[4][0] = SLICKDIR + '/share/gitignore'
	FILE_MAPS[5][0] = SLICKDIR + '/share/Makefile.' + MAKEFILES[goods[3]]
	# mkdir the usual stock of subfolders
	mkdir('src')
	mkdir('doc')
	mkdir('data')
	mkdir('include')
	mkdir('etc')
	mkdir('util')
	# read all of the files, mutate them, and write them to disk
	i = 0
	while i < 6:
		writetxt(FILE_MAPS[i][1], mutate(FILE_MAPS[i][0],
			BPLATE_C, BPLATE_SH,
			goods[2], goods[1]))
		i += 1
	print2('All done.')
	if argc != 7:
		from sys import stdout
		stdout.write('Press any key to continue. ')
		stdout.flush()
		pause()
		stdout.flush()
	return 0

if __name__ == '__main__':
	from sys import argv, exit
	exit(main(argv))
