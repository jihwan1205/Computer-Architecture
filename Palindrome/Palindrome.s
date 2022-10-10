# Palindrome Program

.data   # Data Decleration Section
is_palindrome : .asciiz "true\n"
not_palindrome : .asciiz "false\n"

.text   # Code Section
main:
    li $v0, 5   # system call code for input
    syscall
    move $s0, $v0   # move input number to n(s0)
    addi $s3, $s0, 0   # save input number in s3(original)
    li $s2, 0   # initialize 'reversed' with 0
    bltz $s3, returnFalse   # false when input number is negative
L1:
    beq $s0, $zero, OUT    # break loop if n==0
    li $t0, 10          # load 10 to t0
    div $s0, $t0        # divide input by 10
    mfhi $s1            # save remainder to s1
    mflo $s0        # update n with the quotient
    mul $s2, $s2, $t0   # multiply 10 to 'reversed'(s2)
    add $s2, $s2, $s1   # add the remainder(s1) to 'reversed'
    j L1        # loop back to L1
OUT:
    beq $s3, $s2, returnTrue    # jump to returnTrue if original and reversedis the same
    j returnFalse   # else jump to returnFalse
returnTrue:
    li $v0, 4   # system call code for print string
    la $a0, is_palindrome   # load is_palindrome address to a0
    syscall     # print 
    j EXIT      # jump to EXIT
returnFalse:
    li $v0, 4   # system call code for print string
    la $a0, not_palindrome  # load not_palindrome address to a0
    syscall     # print 
    j EXIT      # jump to EXIT
EXIT:
    jr $ra      # return address
