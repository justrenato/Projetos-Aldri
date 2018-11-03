.section .data
.section .text

.globl _start
_start:

addi $s0, $s0, 0 # variavel a=0
addi $s1, $s1, 0 # variavel i=0
addi $s2, $s2, 15 # variavel k = 15 (valor qualquer)

while:
bge $s1, $s2, done # pular para rotulo done caso condição i < k seja falsa
add $s0, $s0, $s1
addi $s1, $s1, 1
j while
done:
