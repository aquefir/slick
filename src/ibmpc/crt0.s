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
	XOR     AX, AX
	MOV     DS, AX
	MOV     SS, AX
	/* 0x2000 past code start, 7.5kiB in size */
	MOV     SP, 0x9C00

	/* No interrupts */
	CLI
	/* Save real mode */
	PUSH    DS

	/* Load GDT register */
	LGDT    [Lgdtinfo]
	/* Switch to pmode by setting pmode bit */
	MOV     EAX, CR0
	OR      AL, 1
	MOV     CR0, EAX

	/* Tell i386/i486 to not crash */
	JMP     $ + 2

	/* Select descriptor 1 */
	MOV     BX, 0x8
	/* 0x8 = 0b1000 */
	MOV     DS, BX

	/* Back to real mode by toggling bit again */
	AND     AL, 0xFE
	MOV     CR0, EAX

	/* Get back old segment */
	POP     DS
	STI

	CALL    main
	MOV     AH, 0x4C
	INT     0x21

Lgdtinfo:
	/* Last byte in table */
	.hword Lgdt_end - Lgdt - 1
	/* Start of table */
	.word Lgdt

Lgdt:
	.word 0, 0
Lflatdesc:
	.byte 0xFF, 0xFF, 0, 0, 0, 0x92, 0xCF, 0

Lgdt_end:
	/* 510 - . == 444, recalculate and check with nm if changing */
	.space 444
	.hword 0xAA55
