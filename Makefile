test: memmgr_test.c
	clang -m32 -g -o memmgr_test memmgr_test.c memmgr.s
	./memmgr_test
clean:
	rm memmgr_test
