.MODEL SMALL

.STACK 100H

.DATA

SZ DW ?
x2 DW ?
a3 DW ?
b3 DW ?
t1 DW ?
t2 DW ?

.CODE

OUP PROC

CMP AX, 0
JL LVL10
JMP LVL100

LVL10:
MOV BX, AX
MOV AH, 2
MOV DL, '-'
INT 21H
NEG BX
MOV AX, BX

LVL100:
MOV SZ, 0
CMP AX, 0
JE DO
LVL3:
MOV BX, 0
MOV CX, 0
MOV DX, 0
CMP AX, 0
JE LVL5
INC SZ
MOV CL, 10
DIV CL
MOV CL, AH
ADD CL, '0'
MOV AH, 0
MOV BX, AX
PUSH CX
MOV AX, BX
JMP LVL3
LVL5:
MOV BX, SZ
CMP BX, 0
JE GO
POP CX
MOV AH, 2
MOV DL, CL
INT 21H
DEC SZ
JMP LVL5
DO:
MOV AH, 2
MOV DL, '0'
INT 21H
GO:
RET

OUP ENDP

foo PROC

ret
INC x2
MOV AX, x2
PUSH AX

foo ENDP

main PROC

MOV AX, @DATA
MOV DS, AX
L1:
INC a3
CMP a3, 0
JE L3
JMP L2
L2:
DEC b3
JMP L1
L3:
MOV AX, b3
CALL OUP
MOV AH, 2
MOV DL, 0AH
INT 21H
MOV DL, 0DH
INT 21H
MOV AX, t1
MOV x2, AX
CALL foo
POP t2

main ENDP

END main