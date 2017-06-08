#include <stdio.h>

void allocateInit();
int allocate(int length);
void deallocate(int address);
int check_brk();

int main() {
    allocateInit();
    int res;
    int i=1;
    int sum=0;
    printf("%d - first brk\n", check_brk());
    while(i<100){
        res = i;
        int address = allocate(res);
        deallocate(address);
        sum+=i;
        sum+=8;
        i++;
    }
    printf("%d - after multiple alloc/dealloc brk\n", check_brk());
    printf("%d\n", sum);

    return 0;
}
