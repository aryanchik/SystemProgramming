dz_asm: dz.asm
	fasm dz.asm

test_c: test.c
	gcc -c test.c -o test.o -no-pie

build: dz_asm test_c
	gcc test.o dz.o -o myprog

run: build myprog
	./myprog

clean:
	rm -f *.o
