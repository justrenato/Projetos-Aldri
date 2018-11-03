.section .data
.section .text

.globl _start
_start:

jal Strcopy #jump and link, chama procedimento e salva em $ra pc+4


Strcopy: 
addi $s0, $s0, 0 # variavel i=0



jr $ra #registrador com endereço de retorno

################### PPT PAGINA 100