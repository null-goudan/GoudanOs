#include "bootpack.h"
#include <stdio.h>

void init_pic(void){
    io_out8(PIC0_IMR, 0xff);    // 禁止所有中断
    io_out8(PIC1_IMR, 0xff);    // 禁止所有中断 

    io_out8(PIC0_ICW1, 0x11);   // 边沿触发模式
    io_out8(PIC0_ICW2, 0x20);   // IRQ0-7 由 INT 20-27接收
    io_out8(PIC0_ICW3, 1 << 2); // PIC1有IRQ2连接
    io_out8(PIC0_ICW4, 0x01);   // 无缓冲区模式

    io_out8(PIC1_ICW1, 0x11  ); // ~
	io_out8(PIC1_ICW2, 0x28  ); // 8-15 -> 28-2f
	io_out8(PIC1_ICW3, 2     ); // ~
	io_out8(PIC1_ICW4, 0x01  ); // ~

	io_out8(PIC0_IMR,  0xfb  ); /* 11111011  */
	io_out8(PIC1_IMR,  0xff  ); /* 11111111  */

	return;
}

#define PORT_KEYDAT		0x0060

void inthandler27(int *esp)						
{
	io_out8(PIC0_OCW2, 0x67); 
	return;
}
