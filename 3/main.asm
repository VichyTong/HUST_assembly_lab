.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 scanf           PROTO C :VARARG
 printMid proto
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

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
    username db "tongweixi", 0
    password db "U202115361" XOR '114514', 0

    buf1 db 20 dup(0), 0
    buf2 db 10 dup(0), 0

    info1 db "Please input username: ", 0
    info2 db "Please input password: ", 0
    info3 db "Please input 5 sets of data, the response is MIDF: ", 0
    info4 db "press R to input again, press Q to exit: ", 0
    info5 db "MIDF data SF: ", 0
    info6 db "OK", 0
    info7 db "Incorrect username or password!", 0

    LOWF DSE 4 DUP(<>)
    MIDF DSE 4 DUP(<>)
    HIGHF DSE 4 DUP(<>)
    
    EXPL DSE <0, 0, 0, 0>
    NUM NUMCNT <0, 0, 0>

    lpFmtString	 db	"%s", 0
    lpFmtInt	 db	"%d", 0
    lpFmtChar	 db	"%c", 0
    lpFmtIntn	 db	"[INFO]: %d", 0ah, 0dh, 0
    lpFmtStringn db "%s", 0ah, 0dh, 0

    keyinput db 0
    cnt dw 0
    flag dw 0
    printMid proto
    calc proto:sdword, :sdword, :sdword
    copy proto:sdword, :sdword, :sdword, :sdword, :sdword


.STACK 200

.CODE

STRCMP macro str1, str2, res ;如果str1和str2相等，res是0；不等，res是1
    LOCAL L1,L2,L3
    MOV EAX, 0
    MOV res, 1
L1:
    MOV BH, str1[EAX]
    CMP str2[EAX], BH
    JNZ L3
    CMP str1[EAX], 0
    JZ L2
    INC EAX
    JMP L1
L2:
    MOV res, 0
L3:
    endm

main proc c
    MOV cnt, 0
F0:
    CMP cnt, 3
    JZ ERR
    MOV flag, 0
    invoke printf, offset lpFmtStringn, offset info1
    invoke scanf, offset lpFmtString, offset buf1
    invoke printf, offset lpFmtStringn, offset info2
    invoke scanf, offset lpFmtString, offset buf2

    STRCMP buf1, username, flag

    ; 插入无意义代码增加难度
    jmp trick
    trick_data DD 114514
    trick:
    ; 无意义代码结束

    cmp flag, 0
    JNZ NOTAUTH
    STRCMP buf2, password, flag
    cmp flag, 0
    JNZ NOTAUTH
    
    invoke printf, offset lpFmtStringn, offset info6
    MOV cnt, 0
    invoke printf, offset lpFmtStringn, offset info3
    JMP F1

ERR:
    invoke ExitProcess, 0

NOTAUTH:
    invoke printf, offset lpFmtStringn, offset info7
    INC cnt
    JMP F0
    
F1:
    invoke scanf, offset lpFmtInt, offset EXPL.SDA
    invoke scanf, offset lpFmtInt, offset EXPL.SDB
    invoke scanf, offset lpFmtInt, offset EXPL.SDC
    invoke calc, EXPL.SDA, EXPL.SDB, EXPL.SDC
    MOV EXPL.SF, EAX

    invoke printf, offset lpFmtIntn, EAX
    invoke copy, offset LOWF, offset MIDF, offset HIGHF, offset EXPL, offset NUM
    inc cnt
	cmp cnt, 5
	jnz F1

	invoke printMid
	invoke printf,offset lpFmtStringn, offset info4
	invoke scanf,offset lpFmtString, offset keyinput
	cmp keyinput, 'R'
	JZ F1
	invoke ExitProcess, 0

main endp

printMid proc
    invoke printf, offset lpFmtStringn, offset info5
    MOV ECX, NUM.mcnt
    DEC ECX
L1:
    CMP ECX, -1
    JZ L2
    MOV EBX, offset MIDF
    MOV EDX, ECX
    SAL EDX, 4
    ADD EBX, EDX
    PUSH ECX
    invoke printf, offset lpFmtIntn, (DSE ptr [EBX]).SF
    POP ECX
    DEC ECX
    JMP L1

L2:
    ret
printMid endp
 
END