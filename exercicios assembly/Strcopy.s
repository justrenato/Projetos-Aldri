.data
	str1: .space 200
	str2: .space 200
	str3: .asciiz "A string copiada foi: "
.text

.globl _start
_start:

	li $v0, 8 #chamada de sistema para ler string
	la $a0,str1 #endereço de onde ira guardar a string lida
	addi $a1, $0, 200 #ler no maximo 200 characteres
	syscall



	la $a1,str2 # string a ser escrita

	## str1(lida) em $a0 e str2(a ser escrita) em $a1
	jal Strcopy #jump and link, chama procedimento e salva em $ra pc+4

	la $a0, str3 # endereço da string em $a0
	addi $v0, $0, 4 # 4 em $v0 para imprimir na tela
	syscall

	la $a0, str2 # endereço da string em $a0
	addi $v0, $0, 4 # 4 em $v0 para imprimir na tela
	syscall

	li $v0, 10
	syscall

	Strcopy: 
		li $t0, 0
		lb $s0, 0($a0) #pegar primeiro byte da palavra origem para ver se n é \0
		while:
			#beqz $a0,fim_while
			beq $s0, $0,fim_while
			lb $s0, 0($a0)
			sb $s0, 0($a1)

			addi $a0, $a0, 1
			addi $a1, $a1, 1
			j while
		fim_while:
	
		addi $a1, $a1, 1 #incrementa o endereço da palavra destino
		sb $0, 0($a1) #coloca o \0 no final dessa palavra

	 	jr $ra #registrador com endereço de retorno

