.686P 
.model flat,c
 ExitProcess proto  stdcall :dword
 INCludelib  kernel32.lib
 printf      proto c :vararg
 INCludelib  libcmt.lib   
 INCludelib  legacy_stdio_definitions.lib
 clock		 proto c
.data
n = 10

SAMPLES  STRUCT
    SAMID  DB 9 DUP(0)   ;每组数据的流水号
    SDA   DD  ?     ;状态信息a
    SDB   DD  ?      ;状态信息b
    SDC   DD  ?      ;状态信息c
    SF    DD  ?        ;处理结果f
SAMPLES  ENDS


infos   SAMPLES<'00000001',321, 432, 10, ?>
        SAMPLES<'00000002',12654, 544, 342, ?>
        SAMPLES<'00000003',32100654, 432, 10, ?>
        SAMPLES<'00000004',324, 1235, 345, ?>
        SAMPLES<'00000005',546, 145, 445, ?>
        SAMPLES<'00000006',55, 14, 44785, ?>
        SAMPLES<'00000007',46, 12345, 47485, ?>
        SAMPLES<'00000008',54896, 1235, 4385, ?>
        SAMPLES<'00000009',46, 435, 4785, ?>
        SAMPLES<'00000010',546, 45, 445, ?>

lowf  DB n dup(25 dup(0))
midf  DB n dup(25 dup(0))
highf DB n dup(25 dup(0))
FLAG  DD 0,0,0
t     DD 0
m     DD 0
lpfmt DB "%d",0ah, 0dh, 0
.stack 200

.code
main proc 
START:   
    MOV ECX,0
    MOV EBX,0
    MOV EDX,0
LOOP:    
    MOV EBX,[t]
    CMP ds:[t],10
    JE EXIT
    ADD [t],1
CALC:
    MOV EAX, 0
    MOV EDX, infos[EBX].SDA
    MOV ECX, infos[EBX].SDB
    MOV EBX, infos[EBX].SDC
    ADD EAX, EDX
    ADD EAX, ECX
    SUB EAX, EBX
    AND EAX, 0FFFFFFFFh
    SHR EAX, 2
    CMP EAX, 100
    JG GREAT
    JL LESS
    JE EQUAL
GREAT:     
    MOV EAX, [FLAG]
    ADD [FLAG], 25
    LEA ESI, infos[EBX]
    LEA EDI, [highf+EAX]
    MOV es:[ESI+21], EDX
    MOV ECX , 6
    LOOP COPY
EQUAL:   
    MOV EAX,[FLAG+4]
    ADD [FLAG+4],25
    LEA ESI, infos[EBX]
    LEA EDI,[midf+EAX]
    MOV es:[ESI+21],EDX
    MOV ECX ,6
    LOOP COPY
LESS:   
    MOV EAX,[FLAG+8]
    ADD [FLAG+8],25
    LEA ESI, infos[EBX]
    LEA EDI,[lowf+EAX]
    MOV es:[ESI+21],EDX
    MOV ECX ,6
    LOOP COPY
COPY:
    MOV EAX, [DS:ESI]
    MOV [ES:EDI], EAX
    ADD ESI, 4
    ADD EDI, 4
    LOOP COPY
    INC EDI
    INC ESI
    MOV EAX, [DS:ESI]
    MOV [ES:EDI], EAX
    JMP LOOP
EXIT:
    ADD m, 1
    MOV t, 0
    MOV DWORD PTR [FLAG], 0
    MOV DWORD PTR [FLAG+8], 0
    MOV DWORD PTR [FLAG+4], 0
    CMP m, 10000000
    JL LOOP
    invoke ExitProcess, 0
main endp
end 