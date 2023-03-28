.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 scanf           PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
    info1 db "Please input username\n", 0
    info2 db "Please input password\n", 0

    lpFmt	db	"%s", 0
	std_password db 'tongweixi', 0

    username db 10 dup(0), 0
    password db 10 dup(0), 0
    buf1 db 'Incorrect Password!', 0
    buf2 db 'OK!', 0
.STACK 200

STRCMP marco str1, str2
    

.CODE
main proc c
    

    invoke printf, offset lpFmt, offset info1
    invoke scanf, offset lpFmt, offset username
    invoke printf, offset lpFmt, offset info2
    invoke scanf, offset lpFmt, offset  password

    MOV ECX, 0

L1:
    MOV al, str1[ECX] 
    cmp al, password[ECX]
    JNZ  wrong 
    CMP al, 0
    JZ ok
    INC ECX
    jmp L1

wrong:
    invoke printf,offset lpFmt,OFFSET buf1
    jmp exit
ok:
    invoke printf,offset lpFmt,OFFSET buf2
exit:
    invoke ExitProcess, 0
main endp
END
