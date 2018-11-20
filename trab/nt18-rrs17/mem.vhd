-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2018-2 trabalho semestral, autor: Roberto Hexsel, 31out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

use work.p_wires.all;

entity mem_prog is
  port (ender : in  reg7;
        instr : out reg32);

  type t_prog_mem is array (0 to 63) of reg32;

  constant program : t_prog_mem := (

	x"80040000",	-- 0x00	addi r4, r0, 0                          	int M[16][16];

	x"80050000",	-- 0x01	main:	addi r5, r0, 0                  	int r;
	x"84020000",	-- 0x02		addi a0, r4, 0                  	primeiro parametro = M
	x"80030010",	-- 0x03		addi a1, r0, 16                 	segundo paramentro = 16
	x"c00f0009",	-- 0x04		jal init                        	chamada funcao init
	x"c00f0016",	-- 0x05		jal diag                        	chamada funcao diag
	x"11050000",	-- 0x06		add r5, v0, r0                  	r = diag (M, 16);
	x"b5000000",	-- 0x07		show r5                         	display (r)
	x"f0000000",	-- 0x08		halt                            	encerra simulacao

	x"82060000",	-- 0x09	init:	addi r6, a0, 0                          endereço de memoria de M
	x"80070000",	-- 0x0a		addi r7, r0, 0                  	int i = 0;
	x"e7300015",	-- 0x0b		for1:	bran r7, a1, fim1       	for (i = 0; i < sz; i++);
	x"80080000",	-- 0x0c			addi r8, r0, 0          	int j = 0;
	x"e8300013",	-- 0x0d			for2:	bran r8, a1, fim2	for (j = 0; j < sz; i++);
	x"17890000",	-- 0x0e				add r9, r7, r8  	i + j
	x"a6900000",	-- 0x0f				st r9, 0(r6)    	M[i][j] = i + j;
	x"88080001",	-- 0x10				addi r8, r8, 1  	j = j + 1;
	x"86060001",	-- 0x11				addi r6, r6, 1  	atualiza endereço de memoria
	x"e000000d",	-- 0x12				bran r0, r0, for2	retorna para o for2
	x"87070001",	-- 0x13			fim2:	addi r7, r7, 1   	i = i + 1;
	x"e000000b",	-- 0x14			bran r0, r0, for1       	retorna para o for1
	x"df000000",	-- 0x15		fim1:	jr ra                   	retorno para main

	x"82060000",	-- 0x16	diag:	addi r6, a0, 0                          endereço de memoria de M
	x"80070000",	-- 0x17		addi r7, r0, 0                  	int s = 0;
	x"80080000",	-- 0x18		addi r8, r0, 0                  	int i = 0;
	x"e8300020",	-- 0x19		for:	bran r8, a1, fim        	for (i = 0; i < sz; i++)
	x"96090000",	-- 0x1a			lw r9, 0(r6)            	carrega o valor de M[i][i]
	x"17970000",	-- 0x1b			add r7, r7, r9          	s = s + M[i][i];
	x"88080001",	-- 0x1c			addi r8, r8, 1          	i = i + 1;
	x"16360000",	-- 0x1d			add r6, r6, a1          	endereço de memoria + sz
	x"86060001",	-- 0x1e			addi r6, r6, 1          	endereço de memoria + 1
	x"e0000019",	-- 0x1f			bran r0, r0, for        	retorna para o for
	x"87010000",	-- 0x20		fim:	addi v0, r7, 0          	return = s
	x"df000000",	-- 0x21		jr ra                           	retorno para main

	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000",
	x"00000000"
  );

  function BV2INT7(S: reg7) return integer is
    variable result: integer;
  begin
    for i in S'range loop
      result := result * 2;
      if S(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end BV2INT7;

end mem_prog;

architecture tabela of mem_prog is
begin  -- tabela

  instr <= program( BV2INT7(ender) );

end tabela;
