# Algoritmo em Assembly (MIPS) que implementa uma vers�o para a fun��o strcpy () do c
	.data
	.align 0
str_src: 	.asciiz "Organizacao de Computadores Digitais I"  # string origem  (que sera copiada - 12 bytes) 

	.text
	.globl main
main:
	li $v0, 9		    # codigo da chamada de sistema para alocar $a0 bytes de memoria
	addi $a0, $zero, 39 # qtde de bytes para serem alocados na memoria
	syscall				# chamada de sistema

	add $a0, $zero, $v0	# endereco inicial da string destino
	la $a1, str_src		# $a1 recebe o endereco da string origem 
	
	jal strcpy
	
	li $v0, 4		# codigo da chamada de sistema para a print_string
	# $a0 j� tem o endereco da string destino!!!
	syscall			# chamada de sistema

	li $v0, 10		# codigo da chamada de sistema para a exit
	syscall			# chamada de sistema
# ******************************************
# acabou a main aqui.
# ******************************************
	
strcpy:	
	# empilhando
    addi $sp, $sp, -12  # 0x23bdfff4 desloca 12 bytes para inserir 3 palavras na pilha
	sw $a0, 0($sp)		# 0xafa40000 empilha $a0 
	sw $a1, 4($sp)		# 0xafa50004 empilha $a1
	sw $s0, 8($sp)     	# 0xafb00008 empilha $s0
	
loop:
	lb $s1, 0($a1)		# 0x80b10000 $s1 = primeiro caracter da string origem
	sb $s1, 0($a0)		# 0xa0910000 memoria[a0] = $s1  (copia o caracter para a string destino)

	addi $a1, $a1, 1	# 0x20a50001 incrementa endereco da string origem
	addi $a0, $a0, 1	# 0x20840001 incrementa endereco da string destino

	bne $s1, $zero, loop 	# 0x1620fffb repita ate string origem encontrar o '\0'
# final do loop
	
	#desempilhando
	lw $a0, 0($sp)		# 0x8fa40000 recupera $a0 original da pilha
	lw $a1, 4($sp)		# 0x8fa50004 recupera $a1 original da pilha
	lw $s0, 8($sp)     	# 0x8fb00008 recupera $s0 original da pilha
    addi $sp, $sp, 12   # 0x23bd000c volta 12 bytes para retirar 3 palavras na pilha
		
	jr $ra				# 0x03e00008 retona para a main