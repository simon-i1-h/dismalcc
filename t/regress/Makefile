.PHONY: all clean tcversion test

#CC = clang
CC = ../../_build/bin/clang
LLD = ../../_build/bin/ld.lld

all: sample_c sample_gnuc

clean:
	rm -f sample_c sample_gnuc

tcversion:
	$(CC) --version
	$(LLD) --version

sample_c: sample_c.c
	$(CC) -std=c99 -o sample_c sample_c.c

sample_gnuc: sample_gnuc.c
	$(CC) -std=gnu99 -o sample_gnuc sample_gnuc.c

test: all
	test "$$(./sample_c 2 3 4 5)" = 'result: 10'
	test "$$(./sample_gnuc 2 3)" = baz
