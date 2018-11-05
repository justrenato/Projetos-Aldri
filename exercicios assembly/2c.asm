.data 
.text

.globl main

main:
	addi $a0, $0, 2 # argument g = 2
	addi $a1, $0, 3 # argument h = 3
	addi $a2, $0, 4 # argument i = 4
	addi $a3, $0, 5 # argument j = 5

	addi $t0, $0, 3 # argument k = 3
	sub $sp, $sp, 4 #space on stack
	sw $t0, 0($sp) # save the 5th arg

	jal fun # call procedure

	addi $sp, $sp, 4 #restore old stack value
	add $s0, $v0, $0 # y = returned value
	addi $v0, $0, 10 #exit
	syscall

	fun:

		#g = $a0, h = $a1, i = $a2, j = $a3, k = 0($sp)

		add $t0, $a0, $a1 # $t0 = g + h
		add $t1, $a2, $a3 # $t1 = i + j
		mult $t1, $t4 # (i + j)*k
		mflo $t1 # $t1 = (i + j)*k
		sub $t2, $t0,  $t1 # $t2 = (g + h) - (i + j)*k

		addi $t3, $0, 4 # $t3 = 4
		mult $t2, $t3 # f*4 
		mflo $v0 # return = f*4

		jr $ra # return to caller
