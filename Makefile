TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/
APPPATH  = ./apps/

MAKE     = $(TOOLPATH)make.exe -r
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

default:
	$(MAKE) img

goudan.sys : asmhead.bin bootpack.hrb Makefile
	copy /B asmhead.bin+bootpack.hrb goudan.sys

goudan.img: GoudanOSCore/ipl.bin GoudanOSCore/goudan.sys Makefile \
		$(APPPATH)a/a.hrb  $(APPPATH)hello3/hello3.hrb \
		$(APPPATH)hello4/hello4.hrb $(APPPATH)hello5/hello5.hrb $(APPPATH)winhelo/winhello.hrb \
		$(APPPATH)winhelo2/winhelo2.hrb $(APPPATH)winhelo3/winhelo3.hrb $(APPPATH)star1/star1.hrb\
		$(APPPATH)stars/stars.hrb $(APPPATH)stars2/stars2.hrb $(APPPATH)lines/lines.hrb \
		$(APPPATH)walk/walk.hrb  $(APPPATH)noodle/noodle.hrb $(APPPATH)beepdown/beepdown.hrb \
		$(APPPATH)color/color.hrb $(APPPATH)color2/color2.hrb \
		$(APPPATH)crack7/crack7.hrb $(APPPATH)sosu/sosu.hrb $(APPPATH)sosu2/sosu2.hrb $(APPPATH)sosu3/sosu3.hrb \
		$(APPPATH)typeipl/typeipl.hrb  $(APPPATH)type/type.hrb $(APPPATH)bball/bball.hrb \
		$(APPPATH)invader/invader.hrb $(APPPATH)calc/calc.hrb
	$(EDIMG) imgin:../z_tools/fdimg0at.tek \
		wbinimg src:GoudanOSCore/ipl.bin len:512 from:0 to:0 \
		copy from:GoudanOSCore/goudan.sys to:@: \
		copy from:GoudanOSCore/ipl.nas to:@: \
		copy from:make.bat to:@: \
		copy from:$(APPPATH)a/a.hrb to:@: \
		copy from:$(APPPATH)hello3/hello3.hrb to:@: \
		copy from:$(APPPATH)hello4/hello4.hrb to:@: \
		copy from:$(APPPATH)hello5/hello5.hrb to:@: \
		copy from:$(APPPATH)winhelo/winhello.hrb to:@: \
		copy from:$(APPPATH)winhelo2/winhelo2.hrb to:@: \
		copy from:$(APPPATH)winhelo3/winhelo3.hrb to:@: \
		copy from:$(APPPATH)star1/star1.hrb to:@: \
		copy from:$(APPPATH)stars/stars.hrb to:@: \
		copy from:$(APPPATH)stars2/stars2.hrb to:@: \
		copy from:$(APPPATH)lines/lines.hrb to:@: \
		copy from:$(APPPATH)walk/walk.hrb to:@: \
		copy from:$(APPPATH)noodle/noodle.hrb to:@: \
		copy from:$(APPPATH)beepdown/beepdown.hrb to:@: \
		copy from:$(APPPATH)color/color.hrb to:@: \
		copy from:$(APPPATH)color2/color2.hrb to:@: \
		copy from:$(APPPATH)crack7/crack7.hrb to:@: \
		copy from:$(APPPATH)sosu/sosu.hrb to:@: \
		copy from:$(APPPATH)sosu2/sosu2.hrb to:@: \
		copy from:$(APPPATH)sosu3/sosu3.hrb to:@: \
		copy from:$(APPPATH)typeipl/typeipl.hrb to:@: \
		copy from:$(APPPATH)type/type.hrb to:@: \
		copy from:$(APPPATH)bball/bball.hrb to:@: \
		copy from:$(APPPATH)invader/invader.hrb to:@: \
		copy from:$(APPPATH)calc/calc.hrb to:@: \
		imgout:goudan.img

img :
	$(MAKE) goudan.img

run :
	$(MAKE) img
	$(COPY) goudan.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu 

install :
	$(MAKE) img
	$(IMGTOL) w a: goudan.img

full :
	$(MAKE) -C GoudanOSCore
	$(MAKE) -C apilib
	$(MAKE) -C $(APPPATH)a
	$(MAKE) -C $(APPPATH)hello3
	$(MAKE) -C $(APPPATH)hello4
	$(MAKE) -C $(APPPATH)hello5
	$(MAKE) -C $(APPPATH)winhelo
	$(MAKE) -C $(APPPATH)winhelo2
	$(MAKE) -C $(APPPATH)winhelo3
	$(MAKE) -C $(APPPATH)star1
	$(MAKE) -C $(APPPATH)stars
	$(MAKE) -C $(APPPATH)stars2
	$(MAKE) -C $(APPPATH)lines
	$(MAKE) -C $(APPPATH)walk
	$(MAKE) -C $(APPPATH)noodle
	$(MAKE) -C $(APPPATH)beepdown
	$(MAKE) -C $(APPPATH)color
	$(MAKE) -C $(APPPATH)color2
	$(MAKE) -C $(APPPATH)crack7
	$(MAKE) -C $(APPPATH)sosu
	$(MAKE) -C $(APPPATH)sosu2
	$(MAKE) -C $(APPPATH)sosu3
	$(MAKE) -C $(APPPATH)typeipl
	$(MAKE) -C $(APPPATH)type
	$(MAKE) -C $(APPPATH)bball
	$(MAKE) -C $(APPPATH)invader
	$(MAKE) -C $(APPPATH)calc
	$(MAKE) goudan.img

run_full :
	$(MAKE) full
	$(COPY) goudan.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install_full :
	$(MAKE) full
	$(IMGTOL) w a: goudan.img

clean :

src_only :
	$(MAKE) clean
	-$(DEL) goudan.img

clean_full :
	$(MAKE) -C GoudanOSCore			clean
	$(MAKE) -C apilib				clean
	$(MAKE) -C $(APPPATH)a			clean
	$(MAKE) -C $(APPPATH)hello3		clean
	$(MAKE) -C $(APPPATH)hello4		clean
	$(MAKE) -C $(APPPATH)hello5		clean
	$(MAKE) -C $(APPPATH)winhelo	clean
	$(MAKE) -C $(APPPATH)winhelo2	clean
	$(MAKE) -C $(APPPATH)winhelo3	clean
	$(MAKE) -C $(APPPATH)star1		clean
	$(MAKE) -C $(APPPATH)stars		clean
	$(MAKE) -C $(APPPATH)stars2		clean
	$(MAKE) -C $(APPPATH)lines		clean
	$(MAKE) -C $(APPPATH)walk		clean
	$(MAKE) -C $(APPPATH)noodle		clean
	$(MAKE) -C $(APPPATH)beepdown	clean
	$(MAKE) -C $(APPPATH)color		clean
	$(MAKE) -C $(APPPATH)color2		clean
	$(MAKE) -C $(APPPATH)crack7		clean
	$(MAKE) -C $(APPPATH)sosu		clean
	$(MAKE) -C $(APPPATH)sosu		clean
	$(MAKE) -C $(APPPATH)sosu2		clean
	$(MAKE) -C $(APPPATH)sosu3		clean
	$(MAKE) -C $(APPPATH)typeipl	clean
	$(MAKE) -C $(APPPATH)type		clean
	$(MAKE) -C $(APPPATH)bball		clean
	$(MAKE) -C $(APPPATH)invader	clean
	$(MAKE) -C $(APPPATH)calc		clean

src_only_full :
	$(MAKE) -C GoudanOSCore			src_only
	$(MAKE) -C apilib				src_only
	$(MAKE) -C $(APPPATH)a			src_only
	$(MAKE) -C $(APPPATH)hello3		src_only
	$(MAKE) -C $(APPPATH)hello4		src_only
	$(MAKE) -C $(APPPATH)hello5		src_only
	$(MAKE) -C $(APPPATH)winhelo	src_only
	$(MAKE) -C $(APPPATH)winhelo2	src_only
	$(MAKE) -C $(APPPATH)winhelo3	src_only
	$(MAKE) -C $(APPPATH)star1		src_only
	$(MAKE) -C $(APPPATH)stars		src_only
	$(MAKE) -C $(APPPATH)stars2		src_only
	$(MAKE) -C $(APPPATH)lines		src_only
	$(MAKE) -C $(APPPATH)walk		src_only
	$(MAKE) -C $(APPPATH)noodle		src_only
	$(MAKE) -C $(APPPATH)beepdown	src_only
	$(MAKE) -C $(APPPATH)color		src_only
	$(MAKE) -C $(APPPATH)color2		src_only
	$(MAKE) -C $(APPPATH)crack7		src_only
	$(MAKE) -C $(APPPATH)sosu		src_only
	$(MAKE) -C $(APPPATH)sosu2		src_only
	$(MAKE) -C $(APPPATH)sosu3		src_only
	$(MAKE) -C $(APPPATH)typeipl	src_only
	$(MAKE) -C $(APPPATH)type 		src_only
	$(MAKE) -C $(APPPATH)bball		src_only
	$(MAKE) -C $(APPPATH)invader	src_only
	$(MAKE) -C $(APPPATH)calc		src_only
	-$(DEL) goudan.img

refresh :
	$(MAKE) full
	$(MAKE) clean_full
	-$(DEL) goudan.img
