## USAGE
Simple memory manager written for training purposes. Usage like in test file - you need to link assembly file with you C/C++ files.

Before first usage you need to run `allocateInit` function, which sets global variables.

Function `allocate` takes one argument - bytes of memory which you want to allocate - and return address of allocated memory.

Function `deallocate` requires address returned from `allocate` method.
