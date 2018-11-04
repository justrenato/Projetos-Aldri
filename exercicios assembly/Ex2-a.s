.data
	X: .word 0:2048 #aloca 2048*4 bytes para 2048 valores inteiros
	Y: .word 0:64 #aloca 64*4 bytes para 64 valores inteiros

.text
	li $s0,0 # $s0 = A = 0
	li $s1,1 # $s1 = I = 1

	while:
		bge $s1,2048,fim_while

		mul $t2,$s1,4 #$t2 = i * 4 (quando i mudar uma unidade, $t2 muda 4, para se adequar ao tamanho da palavra no mips)

		lw $t0, X($t2) # $t0 = x[i]
		add $s0, $s0, $t0 # a = a + $t0

		rem $t0,$s1,64 # $t0 = I%64 (mod)
		mul $t0,$t0,4
		lw $t1, Y($t0) #$t1 = Y[$t0]

		rem $t3,$t1,2048 #$t3 = $t1%2048 (mod)

		mul $t4,$t3,$4
		lw $t3, X($t4)

		add $s0, $s0, $t3 # a = a + $t3

		sll $s1, $s1, 1 #(shift left logical) i = i*2

		j while

	fim_while:

	li $v0,10
	syscall