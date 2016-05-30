﻿DEFINE InterruptControllerDeviceType 0d3
DEFINE KeyboardDeviceType 0d6
DEFINE DisplayDeviceType 0d7

DEFINE InterruptControllerDeviceWaitingOffset 0x4

DEFINE DisplayColumnsOffset 0d0
DEFINE DisplayRowsOffset 0d1
DEFINE DisplayWidthOffset 0d2
DEFINE DisplayHeightOffset 0d3
DEFINE DisplayCharacterWidthOffset 0d4
DEFINE DisplayCharacterHeightOffset 0d5
DEFINE DisplayCharacterOffset 0x100000
DEFINE BackspaceScanCode 0x0D
DEFINE EnterScanCode 0x28
DEFINE LeftShiftScanCode 0x29
DEFINE RightShiftScanCode 0x34
DEFINE SpaceUtf8 0x20

CONST 0x0000004E49564544

CPY RZERO $SOF ($EOF + -$SOF)
SET RIP RZERO

LABEL SOF

SET RSP 0x10000

SET R0 $InterruptControllerDeviceType
CALL $FindDevice

SET [(R0 + $InterruptControllerDeviceWaitingOffset)] $DeviceWaiting

SET R0 $KeyboardDeviceType
CALL $FindDevice
SET R5 R0

SET R0 $DisplayDeviceType
CALL $FindDevice

SET R6 [(R0 + $DisplayRowsOffset)]
SET R7 [(R0 + $DisplayColumnsOffset)]
SET R8 [(R0 + $DisplayHeightOffset)]
SET R9 [(R0 + $DisplayWidthOffset)]
SET R10 [(R0 + $DisplayCharacterHeightOffset)]
SET R11 [(R0 + $DisplayCharacterWidthOffset)]

ADD R0 R0 $DisplayCharacterOffset
SET R1 RZERO
SET R2 RZERO
INTE
HLT

LABEL DeviceWaiting
EQ RI0 RINT1 R5
IFZ RI0 EINT

SL RI1 RONE 0d63
AND RI0 RI1 RINT2
SUB RI1 RI1 RONE
AND RINT2 RINT2 RI1

LABEL Pressed
EQ RI1 RINT2 $LeftShiftScanCode
EQ RI2 RINT2 $RightShiftScanCode
OR RI1 RI1 RI2
IFZ RI1 SET RIP $NotShift
IFNZ RI0 SET RI0 RMAX
NOT RI0 RI0
SET [$ShiftPressed] RI0
EINT
 
LABEL NotShift
IFZ RI0 EINT
EQ RI0 RINT2 $BackspaceScanCode 
IFZ RI0 SET RIP $CheckNewLine
IFZ R2 EINT
SUB R2 R2 RONE
SET [(R0 + R1 * R7 + R2)] $SpaceUtf8 
EINT

LABEL CheckNewLine
EQ RI0 RINT2 $EnterScanCode 
IFZ RI0 SET RIP $PrintCharacter
SET R2 RZERO
ADD R1 R1 RONE
SET RIP $CheckScroll

LABEL PrintCharacter
SET [$ToProcess] RINT2
CALL $ConvertScanCodeToUtf8
SET [(R0 + R1 * R7 + R2)] [$ToProcess]

ADD R2 R2 RONE
GTE RI0 R2 R7
IFZ RI0 EINT
SET R2 RZERO
ADD R1 R1 RONE

LABEL CheckScroll
GTE RI0 R1 R6
IFZ RI0 EINT

SUB R1 R1 RONE
CPY R0 (R0 + R7) (RZERO + R6 * R7 + -R7)

SET RI0 R7
LABEL ScrollClearLoopStart
SUB RI0 RI0 RONE
SET [(R0 + R1 * R7 + RI0)] $SpaceUtf8 
IFZ RI0 EINT
SET RIP $ScrollClearLoopStart

EINT

INCLUDE .\Images\FindDevice.asm

VAR ShiftPressed 0d0
VAR ToProcess 0d0
LABEL ConvertScanCodeToUtf8
IFNZ [$ShiftPressed] SET RIP $ProcessUpperTable

SET [$ToProcess] [($ScanCodeLowerTableBase + [$ToProcess])]
RET

LABEL ProcessUpperTable
SET [$ToProcess] [($ScanCodeUpperTableBase + [$ToProcess])]
RET

LABEL ScanCodeLowerTableBase
CONST 0x60 // `
CONST 0x31 // 1
CONST 0x32 // 2
CONST 0x33 // 3
CONST 0x34 // 4
CONST 0x35 // 5
CONST 0x36 // 6
CONST 0x37 // 7
CONST 0x38 // 8
CONST 0x39 // 9
CONST 0x30 // 0
CONST 0x2D // -
CONST 0x3D // =
CONST 0x08 // BACKSPACE
CONST 0x09 // TAB
CONST 0x71 // Q
CONST 0x77 // W
CONST 0x65 // E
CONST 0x72 // R
CONST 0x74 // T
CONST 0x79 // Y
CONST 0x75 // U
CONST 0x69 // I
CONST 0x6F // O
CONST 0x70 // P
CONST 0x5B // [
CONST 0x5D // ]
CONST 0x5C // \
CONST 0x00 // CAPS LOCK
CONST 0x61 // A
CONST 0x73 // S
CONST 0x64 // D
CONST 0x66 // F
CONST 0x67 // G
CONST 0x68 // H
CONST 0x6A // J
CONST 0x6B // K
CONST 0x6C // L
CONST 0x3B // ;
CONST 0x27 // '
CONST 0x0A // ENTER
CONST 0x00 // LEFT SHIFT
CONST 0x7A // Z
CONST 0x78 // X
CONST 0x63 // C
CONST 0x76 // V
CONST 0x62 // B
CONST 0x6E // N
CONST 0x6D // M
CONST 0x2C // ,
CONST 0x2E // .
CONST 0x2F // /
CONST 0x00 // RIGHT SHIFT
CONST 0x00 // LEFT CONTROL
CONST 0x00 // OPTION
CONST 0x00 // LEFT ALT
CONST 0x20 // SPACE
CONST 0x00 // RIGHT ALT
CONST 0x00 // MENU
CONST 0x00 // RIGHT CONTROL

LABEL ScanCodeUpperTableBase
CONST 0x7E // `
CONST 0x21 // 1
CONST 0x40 // 2
CONST 0x23 // 3
CONST 0x24 // 4
CONST 0x25 // 5
CONST 0x5E // 6
CONST 0x26 // 7
CONST 0x2A // 8
CONST 0x28 // 9
CONST 0x29 // 0
CONST 0x5F // -
CONST 0x2B // =
CONST 0x08 // BACKSPACE
CONST 0x09 // TAB
CONST 0x51 // Q
CONST 0x57 // W
CONST 0x45 // E
CONST 0x52 // R
CONST 0x54 // T
CONST 0x59 // Y
CONST 0x55 // U
CONST 0x49 // I
CONST 0x4F // O
CONST 0x50 // P
CONST 0x7B // [
CONST 0x7D // ]
CONST 0x7C // \
CONST 0x00 // CAPS LOCK
CONST 0x41 // A
CONST 0x53 // S
CONST 0x44 // D
CONST 0x46 // F
CONST 0x47 // G
CONST 0x48 // H
CONST 0x4A // J
CONST 0x4B // K
CONST 0x4C // L
CONST 0x3A // ;
CONST 0x22 // '
CONST 0x0A // ENTER
CONST 0x00 // LEFT SHIFT
CONST 0x5A // Z
CONST 0x58 // X
CONST 0x43 // C
CONST 0x56 // V
CONST 0x42 // B
CONST 0x4E // N
CONST 0x4D // M
CONST 0x3C // ,
CONST 0x3E // .
CONST 0x3F // /
CONST 0x00 // RIGHT SHIFT
CONST 0x00 // LEFT CONTROL
CONST 0x00 // OPTION
CONST 0x00 // LEFT ALT
CONST 0x00 // SPACE
CONST 0x00 // RIGHT ALT
CONST 0x00 // MENU
CONST 0x00 // RIGHT CONTROL

LABEL EOF