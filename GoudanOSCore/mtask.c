#include "bootpack.h"

struct TASKCTL *taskctl;
struct TIMER *task_timer;

// 闲置任务
void task_idle(void){
    for(;;){
        io_hlt();
    }
}

// struct TASKLEVEL
struct TASK *task_now(void){
    struct TASKLEVEL *t1 = &taskctl->level[taskctl->now_lv];
    return t1->tasks[t1->now];
}

void task_add(struct TASK* task){
    struct TASKLEVEL *t1 = &taskctl->level[task->level];
    if(t1->running < MAX_TASKS_LV){
        t1->tasks[t1->running] = task;
        t1->running++;
        task->flags = 2;
    }
    return ;
}

void task_remove(struct TASK *task){
    int i;
    struct TASKLEVEL *t1 = &taskctl->level[task->level];
    // 寻找task所在的位置
    for(i = 0; i < t1->running; i++){
        if(t1->tasks[i] == task) break;
    }
    t1->running--;
    if(i<t1->now){
        t1->now--;      // 需要移动成员， 要相应地进行处理
    }
    if(t1->now >= t1->running){
        // 如果now值出现异常， 则修正
        t1->now = 0;
    }
    task->flags = 1;    //休眠
    for(; i < t1->running; i++){
        t1->tasks[i] = t1->tasks[i + 1];
    }
    return ;
}

// 任务切换时决定切换到哪个LEVEL
void task_switchsub(void){
    int i;
    // 寻找最上层的LEVEl;
    for(i = 0; i<MAX_TASKLEVELS; i++){
        if(taskctl->level[i].running > 0){
            break; // 找到了
        }
    }
    taskctl->now_lv = i;
    taskctl->lv_change = 0;
    return ;
}

// TASK 
struct TASK* task_alloc(){
    int i ;
    struct TASK* task;
    for (i = 0; i < MAX_TASKS; i++) {
		if (taskctl->tasks0[i].flags == 0) {
			task = &taskctl->tasks0[i];
			task->flags = 1;    
			task->tss.eflags = 0x00000202; /* IF = 1; */
			task->tss.eax = 0;  // 先置0
			task->tss.ecx = 0;
			task->tss.edx = 0;
			task->tss.ebx = 0;
			task->tss.ebp = 0;
			task->tss.esi = 0;
			task->tss.edi = 0;
			task->tss.es = 0;
			task->tss.ds = 0;
			task->tss.fs = 0;
			task->tss.gs = 0;
			// task->tss.ldtr = 0;
			task->tss.iomap = 0x40000000;
            task->tss.ss0 = 0;
			return task;
		}
	}
	return 0; /* 全部使用中 */
}

struct TASK *task_init(struct MEMMAN *memman){
    int i;
    struct TASK *task, *idle;
    struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR*) ADR_GDT;
    
    taskctl = (struct TASKCTL *) memman_alloc_4k(memman, sizeof (struct TASKCTL));
	for (i = 0; i < MAX_TASKS; i++) {
		taskctl->tasks0[i].flags = 0;
		taskctl->tasks0[i].sel = (TASK_GDT0 + i) * 8;
		taskctl->tasks0[i].tss.ldtr = (TASK_GDT0 + MAX_TASKS + i) * 8;
		set_segmdesc(gdt + TASK_GDT0 + i, 103, (int) &taskctl->tasks0[i].tss, AR_TSS32);
		set_segmdesc(gdt + TASK_GDT0 + MAX_TASKS + i, 15, (int) taskctl->tasks0[i].ldt, AR_LDT);
	}
	for (i = 0; i < MAX_TASKLEVELS; i++) {
		taskctl->level[i].running = 0;
		taskctl->level[i].now = 0;
	}
    
    task = task_alloc();
    task->flags = 2; // 活动标志
    task->priority = 2; // 0.02
    task->level = 0; //最高level
    task_add(task);
    task_switchsub(); //level设置
    load_tr(task->sel);
    task_timer = timer_alloc();
    timer_settime(task_timer, task->priority);

    idle = task_alloc();
	idle->tss.esp = memman_alloc_4k(memman, 64 * 1024) + 64 * 1024;
	idle->tss.eip = (int) &task_idle;
	idle->tss.es = 1 * 8;
	idle->tss.cs = 2 * 8;
	idle->tss.ss = 1 * 8;
	idle->tss.ds = 1 * 8;
	idle->tss.fs = 1 * 8;
	idle->tss.gs = 1 * 8;
	task_run(idle, MAX_TASKLEVELS - 1, 1);

    return task;
}



void task_run(struct TASK *task, int level, int priority){
    if(level < 0){
        level = task->level; //不改变LEVEL
    }
    if(priority > 0){
        task->priority = priority;
    }
    if(task->flags == 2 && task->level != level){ // 改变活动中的LEVEL
        task_remove(task);  //这里执行后flag值会变成1, 于是下面的if语句会执行
    }
    if(task->flags != 2){
        // 从休眠状态唤醒的情形
        task->level = level;
        task_add(task);
    }
    taskctl->lv_change = 1; //下次任务切换时检查level
    return;
}

void task_sleep(struct TASK *task){
    struct TASK *now_task;
    if(task->flags == 2){ // 处于唤醒状态
        now_task = task_now();
        task_remove(task); // 执行此语句 将会将任务休眠 也就是 flag = 1
        if(task == now_task){
            // 如果是让自己休眠， 则需要任务切换
            task_switchsub(); //切换到最高层优先级最高的任务
            now_task = task_now();
            farjmp(0, now_task->sel);
        }
    }
    return ;
}

void task_switch(void){
    struct TASKLEVEL *t1 = &taskctl->level[taskctl->now_lv];
    struct TASK *new_task, *now_task = t1->tasks[t1->now];
    t1->now++;
    if(t1->now == t1->running){
        t1->now = 0;
    }
    if(taskctl->lv_change != 0){
        task_switchsub();
        t1 = &taskctl->level[taskctl->now_lv];
    }
    new_task = t1->tasks[t1->now];
    timer_settime(task_timer, new_task->priority);
    if(new_task != now_task){
        farjmp(0, new_task->sel);
    }
    return;
}
