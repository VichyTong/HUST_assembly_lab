.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 scanf          PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
 ;定义结构体
DSE STRUCT
    SDA sdword 0
    SDB sdword 0
    SDC sdword 0
    SF sdword 0
DSE ENDS

NUMCNT STRUCT
    lcnt sdword 0
    mcnt sdword 0
    hcnt sdword 0
NUMCNT ENDS

 .DATA

 .STACK 200
 .CODE
 
 ; SDF -> EAX
calc proc a:sdword, b:sdword, cc:sdword
	MOV EAX, a
	SAL EAX, 2 ; a * 4
	add eax, a ; a * 5
	add eax, b ; a * 5 + b
	sub eax, cc ; a * 5 + b - c
	add eax, 100 ; a * 5 + b - c + 100
	shr EAX, 7 ; (a * 5 + b - c + 100) / 128
	ret
calc endp

copy proc USES EAX EBX ECX EDX, lowArea:sdword, midArea:sdword, highArea:sdword, exp:sdword, buf:sdword 
	
	MOV EDX, exp
	MOV ECX, buf
	CMP (DSE ptr [EDX]).SF, 100
	JZ L1
	JS L2
	JNS L3
L1:
	; 将 mcnt 左移 4 位，用于计算 midArea 的偏移地址
	MOV EBX, (NUMCNT PTR [ECX]).mcnt
	SAL EBX, 4
	MOV EAX, midArea
	LEA EAX, [EAX + EBX]	; 使用 LEA 指令计算偏移地址
	INC (NUMCNT PTR [ECX]).mcnt
	JMP LL
L2:
	; 将 lcnt 左移 4 位，用于计算 lowArea 的偏移地址
	MOV EBX, (NUMCNT PTR [ECX]).lcnt
	SAL EBX, 4
	MOV EAX, lowArea
	LEA EAX, [EAX + EBX]	
	INC (NUMCNT PTR [ECX]).lcnt
	JMP LL
L3:
	; 将 hcnt 左移 4 位，用于计算 highArea 的偏移地址
	MOV EBX, (NUMCNT PTR [ECX]).hcnt
	SAL EBX, 4
	MOV EAX, highArea
	LEA EAX, [EAX + EBX]	
	INC (NUMCNT PTR [ECX]).hcnt
	JMP LL

LL:
	; 将结构体中的值拷贝到对应的区域
	MOV ECX, (DSE ptr [EDX]).SDA	
	MOV (DSE ptr [EAX]).SDA, ECX
	MOV ECX, (DSE ptr [EDX]).SDB
	MOV (DSE ptr [EAX]).SDB, ECX
	MOV ECX, (DSE ptr [EDX]).SDC
	MOV (DSE ptr [EAX]).SDC, ECX
	MOV ECX, (DSE ptr [EDX]).SF
	MOV (DSE ptr [EAX]).SF, ECX
	
	ret
copy endp

END
