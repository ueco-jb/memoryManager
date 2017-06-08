.data
#This points to the beginning of the memory we are managing
heap_begin: .long 0
#This points to one location past the memory we are managing
current_break: .long 0

testaddr: .long 0

#size of space for memory region header
.equ HEADER_SIZE, 8
#Location of the "available" flag in the heade
.equ HDR_AVAIL_OFFSET, 0
#Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4

#This is the number we will use to mark space that has been given out
.equ UNAVAILABLE, 0
#This is the number we will use to mark space that has been returned, and is available for giving
.equ AVAILABLE, 1

.equ SYS_BRK, 45
.equ LINUX_SYSCALL, 0x80

.bss
.text
.globl allocateInit
allocateInit:
    pushl %ebp
    movl %esp,%ebp

    #If the brk system call is called with 0 in %ebx, it returns the last valid usable address
    movl $SYS_BRK,%eax
    movl $0,%ebx
    int $LINUX_SYSCALL

    incl %eax #I need memory after that address
    movl %eax,current_break
    movl %eax,heap_begin #Current break and heap begin - first address

    movl %ebp,%esp
    popl %ebp
    ret

.globl allocate
allocate:
    pushl %ebp
    movl %esp,%ebp

    movl 8(%ebp),%ecx # First parametr of function

    movl heap_begin,%eax # Current search location
    movl current_break,%ebx

threeWay:
	cmpl %ebx,%eax # at first these are equal
	je realAllocate

	movl 4(%eax),%edx # at second time this should contain info about mapped memory
	cmpl $UNAVAILABLE,0(%eax) # if there was no deallocate, we have to move forward
	je moveForward

	cmpl %edx,%ecx # if previously deallocated space is enough for this iteration, I don't need to aquire more memory
	jle enoughSpace

moveForward:
	addl $8,%eax
	addl %edx,%eax
	jmp threeWay # at this time we will be at current_break

enoughSpace:
	movl $UNAVAILABLE,0(%eax)
	addl $8,%eax
	movl %ebp,%esp
	popl %ebp
	ret

realAllocate:
    # I need more memory; ebx holds current endpoint of tata and ecx holds its size
    addl $HEADER_SIZE,%ebx
    addl %ecx,%ebx

    pushl %eax
    pushl %ecx
    pushl %ebx

    movl $SYS_BRK,%eax
    int $LINUX_SYSCALL

    cmpl $0,%eax
    je error

    popl %ebx
    popl %ecx
    popl %eax

    movl $UNAVAILABLE,HDR_AVAIL_OFFSET(%eax)
    movl %ecx,HDR_SIZE_OFFSET(%eax)

    addl $HEADER_SIZE,%eax

    movl %ebx,current_break

    movl %ebp,%esp
    popl %ebp
    ret

    error:
        movl $0,%eax
        movl %ebp,%esp
        popl %ebp
        ret

.globl check_brk
check_brk:
    pushl %ebp
    movl %esp,%ebp

    movl $SYS_BRK,%eax
    movl $0,%ebx
    int  $LINUX_SYSCALL

    movl %ebp,%esp
    popl %ebp
    ret

.globl deallocate
deallocate:
	movl 4(%esp),%eax
	subl $HEADER_SIZE,%eax
	movl $AVAILABLE,HDR_AVAIL_OFFSET(%eax)

    ret


