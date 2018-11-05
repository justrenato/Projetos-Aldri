.data
myArray: .word 0:256
size: .word 256

.text

.globl main
main:
la $a0,myArray
lw $a1, size

jal clear1

addi $v0, $0, 10 #exit
syscall

clear1:
	li $t0,0 #variavel i

	for:
		bge $t0,$a1,fim_for #sai do for se i >= size
		mul $t1,$t0,4	#multiplica I por 4 para se adequar ao tamanho da palavra no mips
		sw $0, myArray($t1)	# myArray[i] = 0

		addi $t0, $t0, 1 #i++
		j for #volta ao inicio do for

		fim_for: #saida do for
	jr $ra #return to caller