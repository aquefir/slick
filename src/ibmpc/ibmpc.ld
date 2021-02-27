/****************************************************************************\
 *                                 IBMPC.ld                                 *
 *                                                                          *
 *                         Copyright © 2021 Aquefir                         *
 *                       Released under BSD-2-Clause.                       *
\****************************************************************************/

OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
	. = 0x100;

	.text :
	{
		*(.text);
		. = ALIGN(4);
	}

	.data :
	{
		*(.data);
		. = ALIGN(4);
		*(.bss);
		. = ALIGN(4);
		*(.rodata);
		. = ALIGN(4);
	}

	_heap = .;
}
