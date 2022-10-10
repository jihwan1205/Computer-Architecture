# Quicksort Program

	.data
	
	arr: .space 400000                # array that can have 10000 integer elements
	newline: .asciiz "\n"           # newline
	
	.text		
# call for input N
main:

	li		$v0, 5					# read integer N from input
	syscall							
	move	$s0, $v0				# $s0: N
	la		$s1, arr					# $s1: base address of A
	move	$t1, $s1				# $t1: base address of A (changing var)
    li      $t0, 0
    j       loop_input
	
loop_input:
	
	beq		$s0, $t0, main2			# when N=$t0, end loop
	li		$v0, 5					
	syscall							# read integer input
	sw		$v0, 0($t1)				# save integer at current address of A
	addi	$t0, $t0, 1				# increment $t0 by 1
	addi	$t1, $t1, 4				# move to next address of A
	j		loop_input				
	
main2:
	move	$a0, $s1				# $a0: base address of A
    move	$a1, $zero				# $a1: low = 0
    addi	$a2, $s0, -1			# $a2: high = N-1
	jal		quicksort				# call quicksort

	li	    $t0, 0				
	move	$t1, $s1				# $t1 : base address of A (used for printing)
	j		loop_print


quicksort:

	addi	$sp, $sp, -16			# space for 4
	sw		$a0, 0($sp)				# store base address of A
	sw		$a1, 4($sp)				# store low
	sw		$a2, 8($sp)				# store high
	sw		$ra, 12($sp)			# store return address
	
	slt		$t1, $a1, $a2			# $t1=1 if low<high
	beq		$t1, $zero,end_quicksort# end quicksort loop if low>=high					
	jal		partition				
	
	lw		$a1, 4($sp)				# $a1 = low
	addi	$a2, $s2, -1		    # $a2 = mid_left - 1
	jal		quicksort
	
	addi	$a1, $s3, 1				# $a1 = mid_right + 1
	lw		$a2, 8($sp)				# $a2 = high
	jal		quicksort

end_quicksort:
    lw		$a0, 0($sp)				# restore base address of A
	lw		$a1, 4($sp)				# restore low
	lw		$a2, 8($sp)				# restore high
	lw		$ra, 12($sp)			# restore return address
	addi	$sp, $sp, 16			# restore stack
	jr		$ra						# jump back to caller
	

partition:
	addi	$sp, $sp, -16			# make space for 4
    sw		$a0, 0($sp)				# store base address of A
	sw		$a1, 4($sp)				# store low
	sw		$a2, 8($sp)				# store high
	sw		$ra, 12($sp)			# store return address
	
	move	$s2, $a1				# $s2 : mid_left = low
	move	$s3, $a2				# $s3 : mid_right = high
	
    # $t0: i = low+(1664525*high+22695477*low)%(high-low+1)
    li      $t1,32767               # $t1 = 32767
    li      $t2, 50                 # $t2 = 50
    multu   $t1, $t2                # multiply
    mflo    $t1                     # $t1 = 32767*50
    addi    $t1, $t1, 26175 # $t1 = 1664525
    multu   $t1, $a2                # multiply
    mflo    $t1                     # $t1 = 1664525 * high

    li      $t2, 32767          # $t2 = 32767
    li      $t3, 692            # $t3 = 692
    multu   $t2, $t3            # multiply
    mflo    $t2                 # $t2 = 32767*692
    addi    $t2, $t2, 20713     # $t2 = 22695477
    multu   $t2, $a1            # multiply
    mflo    $t2                 # $t2 = 22695477 * low

    add     $t3, $t1, $t2       # $t3 = 1664525 * high + 22695477 * low
    sub     $t4, $a2, $a1       # $t4 = high-low
    addi    $t4, $t4, 1         # $t4 = high-low+1
    div     $t3, $t4            # divide
    mfhi    $t0                 # (1664525*high+22695477*low)%(high-low+1)
    add     $t0, $t0, $a1       # $t0: i = low+(1664525*high+22695477*low)%(high-low+1)
    
    # $t1: pivot
    # pivot = A[i]
    sll     $t2, $t0, 2     # $t2 = 4*i
    add     $t2, $a0, $t2   # $t2 = address of A[i]
    lw      $t1, 0($t2)     # $t1: pivot = A[i]
    # A[i] = A[low]
    sll     $t3, $a1, 2     # $t3 = 4*low
    add     $t3, $a0, $t3   # $t3 = address of A[low]
    lw      $t4, 0($t3)     # $t4 = A[low]
    sw      $t4, 0($t2)     # A[i] = A[low]
    # A[low] = pivot
    sw      $t1, 0($t3)     # A[low] = pivot
    # i = low + 1
    addi    $t0, $a1, 1
    j       while1

while1:

	j		while2					#jump to while2

while2:

	slt		$t2, $s3, $t0			# if mid_right>=i, $t2=0
	li	    $t4, 1			        # $t4 = 1
	sub		$t2, $t4, $t2			# if mid_right>=i, $t2=1

	sll		$t3, $s3, 2				# $t3 = 4*mid_right
	add		$t3, $a0, $t3			# $t3 : address of A[mid_right]
	lw		$t4, 0($t3)				# $t4 : A[mid_right]
	slt		$t5, $t1, $t4			# if pivot<A[mid_right], $t5=1
	
	and		$t3, $t2, $t5			# $t3 : mid_right>=i && pivot<A[mid_right]
	beq		$t3, $zero, while3		# if not true, branch to while3

	addi	$s3, $s3, -1			# mid_right--
	j		while2					# jump back to while2

while3:

	slt		$t2, $s3, $t0			# if mid_right>=i, $t2=0
	li	    $t3, 1			        # $t3 = 1
	sub		$t3, $t3, $t2			# if mid_right>=i, $t3=1

	sll		$t4, $t0, 2				# $t4 = 4*i
	add		$t4, $a0, $t4			# $t4 = address of A[i]
	lw		$t4, 0($t4)				# $t4 = A[i]

	slt		$t2, $t1, $t4			# if A[i]<=pivot, $t2=0
	li	    $t5, 1			        # $t5 = 1
	sub		$t2, $t5, $t2			# if A[i]<=pivot, $t2=0
	
	and		$t7, $t3, $t2			# if mid_right>=i && A[i]<=pivot, $t7=1
	beq		$t7, $zero, if

	sll		$t2, $t0, 2				# $t2 = 4*i
	add		$t2, $a0, $t2			# $t2: address of A[i]
	lw		$t3, 0($t2)				# $t3: A[i]
	sll		$t6, $s2, 2				# $t6 = 4*mid_left
	add		$t6, $a0, $t6			# $t6: address of A[mid_left]
	sw		$t3, 0($t6)				# A[mid_left] = A[i]
	addi	$s2, $s2, 1				# mid_left++
	
	sw		$t1, 0($t2)				#A[i] = pivot
	addi	$t0, $t0, 1				#i++
	
	j		while3					#move to start of loop

if:

	slt		$t2, $t0, $s3			# if i<mid_right, $t2=1
	beq		$t2, $zero, endwhile1	
    
	sll		$t2, $s2, 2				# $t2 = 4*mid_left
	add		$t2, $a0, $t2			# $t2 : address of A[mid_left]
	sll		$t3, $s3, 2				# $t3 = 4*mid_right
	add		$t3, $a0, $t3			# $t3 : address of A[mid_right]
	lw		$t4, 0($t3)				# $t4 : A[mid_right]
	sw		$t4, 0($t2)				# A[mid_left] = A[mid_right]
	addi	$s2, $s2, 1				# mid_left++
	
	sll		$t4, $t0, 2				# $t4 = 4*i
	add		$t4, $a0, $t4			# $t4 : address of A[i]
	lw		$t5, 0($t4)				# $t5 : A[i]
	sw		$t5, 0($t3)				# A[mid_right] = A[i]
	addi	$s3, $s3, -1			# mid_right--
	
	sw		$t1, 0($t4)				# A[i] = pivot
	addi	$t0, $t0, 1				# i++
	j		while1
	
endwhile1:
	lw		$ra, 12($sp)			# return address
	addi	$sp, $sp, 16			# restore stack pointer
	jr		$ra						# jump to caller

loop_print:
    beq     $t0, $s0, exit
    # system call for print number
    li      $v0, 1
    lw      $a0, 0($t1)
    syscall
    # system call for print new line
    li      $v0, 4    
    la      $a0, newline
    syscall
    addi    $t0, $t0, 1     # increase number printed
    addi    $t1, $t1, 4     # move to next integer address in A
    j       loop_print

exit:
    li      $v0, 10
    syscall

