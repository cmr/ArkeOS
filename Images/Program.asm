﻿ORIGIN 0x00
MOV 0x200 RSP
MOV {IDT} RIDT
MOV RIP S
JMP {Add}
PAU
MOV RIP S
JMP {AddressingTest}
HLT

LABEL Add
MOV 0d10 R0
ADD R0 R1 R1
SUB 0d1 R0 R0
JNZ R0 {Add}
MOV S RIP

LABEL AddressingTest
MOV 0d8 R0
MOV 0d3 R1
MOV 0d2 R2
MOV 0d1 R3
MOV 0xDEADBEEF [0d15]
MOV 0xFACEBEEF R5
MOV [[R0 + R1 * R2 + R3]] R4
MOV R5 [[R0 + R1 * R2 + R3]]
MOV [[R0 + R1 * R2 + R3]] R6
MOV 0d1 S
MOV 0d2 S
ADD S S S
MOV S R7
MOV S RIP

LABEL SystemTimer
ADD 0d1 R2 R2
EINT

ORIGIN 0x100
LABEL IDT
CONST:8 0x00
CONST:8 0x00
CONST:8 0x00
CONST:8 0x00
CONST:8 0x00
CONST:8 {SystemTimer}