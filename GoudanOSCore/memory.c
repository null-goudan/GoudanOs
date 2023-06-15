#include "bootpack.h"
#define EFLAGS_AC_BIT 		0x00040000
#define CR0_CHCHE_DISABLE	0x60000000

unsigned int memtest(unsigned int start, unsigned int end){
	char flg486 = 0;
	unsigned int eflg, cr0, i;

	// 确认cpu是386还是496以上的
	eflg = io_load_eflags();
	eflg |= EFLAGS_AC_BIT;
	io_store_eflags(eflg);
	eflg = io_load_eflags();
	if((eflg & EFLAGS_AC_BIT) != 0)
	{	// 如果是386，即使设定AC=1， AC的值自动会回到0
		flg486 = 1;
	}
	eflg &= ~EFLAGS_AC_BIT;	// AC-bit = 0
	io_store_eflags(eflg);

	if(flg486 != 0){
		cr0 = load_cr0();
		cr0 |= CR0_CHCHE_DISABLE; // 禁止缓存
		store_cr0(cr0);
	}
	i = memtest_sub(start, end);
	if(flg486 != 0){
		cr0 = load_cr0();
		cr0 &= ~CR0_CHCHE_DISABLE; // 允许缓存
		store_cr0(cr0);
	}
	return i;
}

void memman_init(struct MEMMAN *man){
	man->frees = 0;
	man->maxfrees = 0;
	man->lostsize = 0;
	man->losts = 0;
	return ;
}

unsigned int memman_total(struct MEMMAN *man){
	unsigned int i, t = 0;
	for (i = 0; i < man->frees; i++) {
		t += man->free[i].size;
	}
	return t;
}

unsigned int memman_alloc(struct MEMMAN *man, unsigned int size){
	unsigned int i, a;
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].size >= size) {
			a = man->free[i].addr;
			man->free[i].addr += size;
			man->free[i].size -= size;
			if (man->free[i].size == 0) {
				man->frees--;
				for (; i < man->frees; i++) {
					man->free[i] = man->free[i + 1]; 
				}
			}
			return a;
		}
	}
	return 0;
}

int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size)
{
	int i, j;
	// 便于归纳内存 所以free内存表中的内存都是按照地址排列
	for (i = 0; i < man->frees; i++) {
		if (man->free[i].addr > addr) {
			break;
		}
	}
	if (i > 0) {
		// 前面有可用内存
		if (man->free[i - 1].addr + man->free[i - 1].size == addr) {
			// 可以和前面的可用内存合并
			man->free[i - 1].size += size;
			if (i < man->frees) {
				// 后面也有的情况
				if (addr + size == man->free[i].addr) {
					// 可以和后面的可用内存归纳在一起
					man->free[i - 1].size += man->free[i].size;
					// 删除 man->free[i]
					man->frees--;
					for (; i < man->frees; i++) {
						man->free[i] = man->free[i + 1]; /* 構造体の代入 */
					}
				}
			}
            return 0;
		}
	}
	// 前面没有可用内存不能合并
	if (i < man->frees) {
		// 但是后面还有
		if (addr + size == man->free[i].addr) {
			man->free[i].addr = addr;
			man->free[i].size += size;
			return 0;
		}
	}
	// 前面没有空间后面也没有空间
	if (man->frees < MEMMAN_FREES) {
		// free[i]之后的， 向后移动， 腾出一点可用空间
		for (j = man->frees; j > i; j--) {
			man->free[j] = man->free[j - 1];
		}
		man->frees++;
		if(man->maxfrees < man->frees){
			man->maxfrees = man->frees;
		}
		man->free[i].addr = addr;
		man->free[i].size = size;
		return 0;
	}
	// 不能向后移动了 ， 也就是没空间了
	man->losts++;
	man->lostsize += size;
	return -1; // 失败标识
}

unsigned int memman_alloc_4k(struct MEMMAN *man, unsigned int size)
{
	unsigned int a;
	size = (size + 0xfff) & 0xfffff000;
	a = memman_alloc(man, size);
	return a;
}

int memman_free_4k(struct MEMMAN *man, unsigned int addr, unsigned int size)
{
	int i;
	size = (size + 0xfff) & 0xfffff000;
	i = memman_free(man, addr, size);
	return i;
}