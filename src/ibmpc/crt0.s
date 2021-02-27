/****************************************************************************\
 *                                 IBMPC.ld                                 *
 *                                                                          *
 *                         Copyright © 2021 Aquefir                         *
 *                       Released under BSD-2-Clause.                       *
\****************************************************************************/

.intel_syntax noprefix

.code16gcc
.globl _start

_start:
	CALL    main
	MOV     AH, 0x4C
	INT     0x21
