; goudan.nas
; TAB=4

[INSTRSET "i486p"]

VBEMODE	EQU		0x105			; 1024 x  768 x 8bit 彩色
;   (画面模式一览)
;	0x100 :  640 x  400 x 8bit 彩色
;	0x101 :  640 x  480 x 8bit 彩色
;	0x103 :  800 x  600 x 8bit 彩色
;	0x105 : 1024 x  768 x 8bit 彩色
;	0x107 : 1280 x 1024 x 8bit 彩色

BOTPAK	EQU		0x00280000  ; bootpack的加载地址
DSKCAC	EQU		0x00100000	; 磁盘缓存地址
DSKCAC0	EQU		0x00008000  ; 磁盘缓存地址 （实模式）

; 有关BOOT_INFO
CYLS    EQU     0X0FF0
LEDS    EQU     0X0FF1
VMODE   EQU     0X0FF2
SCRNX   EQU     0X0FF4
SCRNY   EQU     0X0FF6
VRAM    EQU     0X0FF8

        ORG     0xc200

; 确认VBE是否存在

        MOV		AX,0x9000
		MOV		ES,AX
		MOV		DI,0
		MOV		AX,0x4f00
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320

; 检查VBE版本
        MOV     AX, [ES:DI+4]
        CMP     AX, 0x0200
        JB      scrn320

; 取得画面模式的信息
        MOV		CX,VBEMODE
		MOV		AX,0x4f01
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320

; 画面模式信息的确认
        CMP		BYTE [ES:DI+0x19],8
        JNE		scrn320
        CMP		BYTE [ES:DI+0x1b],4
        JNE		scrn320
        MOV		AX,[ES:DI+0x00]
        AND		AX,0x0080
        JZ		scrn320    

; 画面模式的切换
        MOV		BX,VBEMODE+0x4000
        MOV		AX,0x4f02
        INT		0x10
        MOV		BYTE [VMODE],8
        MOV		AX,[ES:DI+0x12]
        MOV		[SCRNX],AX
        MOV		AX,[ES:DI+0x14]
        MOV		[SCRNY],AX
        MOV		EAX,[ES:DI+0x28]
        MOV		[VRAM], EAX
        JMP		keystatus

scrn320:
        MOV		AL,0x13			; VGA图、320x200x8bit彩色
        MOV		AH,0x00
        INT		0x10
        MOV		BYTE [VMODE],8	
        MOV		WORD [SCRNX],320
        MOV		WORD [SCRNY],200
        MOV		DWORD [VRAM],0x000a0000

; 用BIOS取得键盘上中各种LED指示灯的状态
keystatus:
        MOV     AH, 0X02
        INT     0X16
        MOV     [LEDS], AL

; PIC不接受任何中断  
; 在AT兼容机的规范中，如果要进行PIC的初始化，  
; 不把这家伙放到CLI前的话，偶尔会挂起来  
; PIC的初始化以后再做 

        MOV     AL, 0XFF
        OUT     0X21, AL
        NOP
        OUT     0XA1, AL

        CLI

; 设置A20GATE，使得CPU可以访问1mb以上的内存 

    CALL    waitkbdout
    MOV		AL,0xd1
    OUT		0x64,AL
    CALL	waitkbdout
    MOV		AL,0xdf			; enable A20
    OUT		0x60,AL
    CALL	waitkbdout

; 保护模式转变
[INSTRSET "i486p"]          ; 想要使用486条指令的描述

    LGDT	[GDTR0]         ; 设定临时GDT
    MOV		EAX,CR0         
	AND		EAX,0x7fffffff  ; 使bit31为0(因为禁止寻呼)
    OR		EAX,0x00000001  ; 使bit0为1(为了保护模式转移)
    MOV		CR0,EAX
	JMP		pipelineflush

pipelineflush:
    MOV		AX,1*8			; 32bit可读段
    MOV		DS,AX
    MOV		ES,AX
    MOV		FS,AX
    MOV		GS,AX
    MOV		SS,AX

; bootpack的转发
    MOV		ESI,bootpack	; 转发源
    MOV		EDI,BOTPAK		; 转发源
    MOV		ECX,512*1024/4
    CALL	memcpy

; 顺便把磁盘数据也传送到本来的位置  
; 从引导扇区开始
    MOV		ESI,0x7c00		; 转发源
    MOV		EDI,DSKCAC		; 转发源
    MOV		ECX,512/4
    CALL	memcpy

; 剩下的全部
    MOV		ESI,DSKCAC0+512	; 转发源
    MOV		EDI,DSKCAC+512	; 转发源
    MOV		ECX,0
    MOV		CL,BYTE [CYLS]
    IMUL	ECX,512*18*2/4	; 从气缸数转换为字节数/4
    SUB		ECX,512/4		; 减去IPL的部分
    CALL	memcpy

; 因为asmhead已经完成了所有的工作，  
; 之后就交给bootpack了 

; bootpack的启动

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 没有可以转发的东西
		MOV		ESI,[EBX+20]	; 转发源
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; 转发源
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; 堆栈初始值
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; 如果AND的结果不是0，到waitkbdout 
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 减法结果不为0则为memcpy
		RET
; memcpy也可以用串指令来写，只要不忘记加入地址大小前缀 

		ALIGNB	16
GDT0:
		RESB	8				
		DW		0xffff,0x0000,0x9200,0x00cf	; 32bit可读段
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行段32bit(用于bootpack)

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
