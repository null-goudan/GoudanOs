int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
void api_putstrwin(int win, int x, int y, int col, int len, char *str);
void api_boxfilwin(int win, int x0, int y0, int x1, int y1, int col);
void api_initmalloc(void);
char *api_malloc(int size);
void api_refreshwin(int win, int x0, int y0, int x1, int y1);
void api_linewin(int win, int x0, int y0, int x1, int y1, int col);
void api_closewin(int win);
int api_getkey(int mode);
void api_end(void);

void HariMain(void)
{
	char *buf;
	int win, i, c, x, y;
	api_initmalloc();
	buf = api_malloc(160 * 100);
	win = api_openwin(buf, 160, 100, -1, "walk");
	api_boxfilwin(win, 4, 24, 155, 95, 0 );
	x = 76;
	y = 56;
    c = 1;
	api_putstrwin(win, x, y, 3, 1, "*");

	for (;;) {
		i = api_getkey(1);
		api_putstrwin(win, x, y, c, 1, "*"); 
		if (i == 'a' && x >   4) { x -= 8; }
		if (i == 'd' && x < 148) { x += 8; }
		if (i == 'w' && y >  24) { y -= 8; }
		if (i == 's' && y <  80) { y += 8; }
		if (i == 0x0a) { break; } 
		api_putstrwin(win, x, y, c, 1, "*");
        c = (c + 1) % 11 ;
	}	
	api_closewin(win);
	api_end();
}
