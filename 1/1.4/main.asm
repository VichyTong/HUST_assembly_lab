.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 scanf           PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
	SAMID  DB '000001' ;每组数据的流水号
	SDA   DD  256809      ;状态信息a
	SDB   DD  7FFFFFFFH       ;状态信息b
	SDC   DD   1265       ;状态信息c
	SF     DD   0         ;处理结果f
	len = $ - SAMID
	lowf dd 10 dup(0)
	midf dd 10 dup(0)
	highf dd 10 dup(0)
	lpFmt	db	"%u", 0
	lpFmtString db "%s", 0
	err db 'overflow!'
	

.STACK 200
.CODE
main proc c

	mov eax, SDA
	jo overflow
	imul eax, 5
	jo overflow
	add eax, SDB
	jo overflow
	sub eax, SDC
	jo overflow
	add eax, 100
	jo overflow
	mov ebx, 128
	jo overflow
	cdq
	idiv ebx
	jo overflow

	
	cmp eax, 100
	jl less
	je equal
	jg greater

	mov ecx, 0

less:
	lea ebx, lowf
	jmp copy
equal:
	lea ebx, midf
	jmp copy
greater:
	lea ebx, highf
	jmp copy
copy:
	mov dl, SAMID[ecx]
	mov [ebx + ecx], dl
	inc ecx
	cmp ecx, len
	je exit
	jmp copy
overflow:
	invoke printf, offset lpFmtString, offset err
	invoke ExitProcess, 1
exit:	
	invoke printf, offset lpFmt, eax
	invoke ExitProcess, 0
	main endp
END
