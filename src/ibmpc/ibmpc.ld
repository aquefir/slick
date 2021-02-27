/****************************************************************************\
 *                                 IBMPC.ld                                 *
 *                                                                          *
 *                         Copyright © 2021 Aquefir                         *
 *                       Released under BSD-2-Clause.                       *
\****************************************************************************/

OUTPUT_FORMAT(binary)

SECTIONS
{
	. = 0x100;

	.crt0 :
	{
		KEEP (*(.crt0));
		. = ALIGN(4);
	}

	.text :
	{
		*(.text);
	}

	.data :
	{
		*(.data);
		*(.bss);
		*(.rodata);
	}

	. = ALIGN(4);
	_heap = .;
}
