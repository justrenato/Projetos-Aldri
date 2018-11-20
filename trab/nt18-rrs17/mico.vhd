-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2017-2 trabalho semestral, autor: Roberto Hexsel, 21out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- processador MICO XI
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;


entity mico is
  port (rst,clk : in bit);
end mico;

architecture functional of mico is

  component mem_prog is                 -- no arquivo mem.vhd | MI
    port (ender : in  reg7;
          instr : out reg32);
  end component mem_prog;

  component display is                  -- neste arquivo | DISPLAY
    port (rst,clk : in bit;
          enable  : in bit;
          data    : in reg32);
  end component display;

  component ULA is                      -- neste arquivo | ULA
    port (fun : in reg4;
          alfa,beta : in  reg32;
          gama      : out reg32);
  end component ULA;

  component R is                        -- neste arquivo | R
    port (clk         : in  bit;
          wr_en       : in  bit;
          r_a,r_b,r_c : in  reg4;
          A,B         : out reg32;
          C           : in  reg32);
  end component R;

  component RAM is                      -- neste arquivo | M
    port (rst, clk : in  bit;
          sel      : in  bit;           -- ativo em 1
          wr       : in  bit;           -- ativo em 1
          ender    : in  reg16;
          data_inp : in  reg32;
          data_out : out reg32);
  end component RAM;

  component inv is
    port (A  	: in  bit;
          S	: out bit);
  end component inv;

  component mux2_32b is
    port (a0, a1  : in reg32;
          s		: in  bit;
          z 		: out  reg32);
  end component mux2_32b;

  component mux4_16b is
    port (a0, a1, a2, a3  : in reg16;
          s		: in  reg2;
          z 		: out  reg16);
  end component mux4_16b;

  component mux4_32b is
    port (a0, a1, a2, a3  : in reg32;
          s		: in  reg2;
          z 		: out  reg32);
  end component mux4_32b;

  component adderAdianta16 is
    port (inpA, inpB : in reg16;
          outC		: out  reg16;
          vem 		: in  bit;
          vai 		: out  bit);
  end component adderAdianta16;

  component ip_reg is
  port(rel, rst, ld, en: in  bit;
        D:               in  reg16;
        Q:               out reg16);
  end component ip_reg;

  component branch is
  port(A, B : in  reg32;
       op   : in  reg4;
       ip   : in reg2;
       ipSaida : out reg2);
  end component branch;

  component extender is
  port(const	: in  reg16;
       sel 	: in bit;
       ext 	: out reg32);
  end component extender;

  type t_control_type is record
    selNxtIP   : reg2;     -- seleciona fonte do incremento do IP
    selC       : reg2;     -- seleciona fonte da escrita no reg destino
    wr_reg     : bit;      -- atualiza banco de registradores
    selBeta    : bit;      -- seleciona fonte para entrada B da ULA
    mem_sel    : bit;      -- habilita acesso a RAM
    mem_wr     : bit;      -- habilita escrita na RAM
    wr_display : bit;      -- atualiza display=1
  end record;

  type t_control_mem is array (0 to 15) of t_control_type;

  constant ctrl_table : t_control_mem := (
  --sNxtIP selC  wrR selB  Msel Mwr wrDsp
    ("00", "00", '0', '0', '0', '0', '0'),            -- NOP
    ("00", "01", '1', '0', '0', '0', '0'),            -- ADD
    ("00", "01", '1', '0', '0', '0', '0'),            -- SUB
    ("00", "01", '1', '0', '0', '0', '0'),            -- MUL
    ("00", "01", '1', '0', '0', '0', '0'),            -- AND
    ("00", "01", '1', '0', '0', '0', '0'),            -- OR
    ("00", "01", '1', '0', '0', '0', '0'),            -- XOR
    ("00", "01", '1', '0', '0', '0', '0'),            -- NOT
    ("00", "01", '1', '1', '0', '0', '0'),            -- ADDI
    ("00", "10", '1', '1', '1', '0', '0'),            -- LD
    ("00", "00", '0', '1', '1', '1', '0'),            -- ST
    ("00", "00", '0', '0', '0', '0', '1'),            -- SHOW
    ("01", "00", '1', '0', '0', '0', '0'),            -- JAL
    ("10", "00", '0', '0', '0', '0', '0'),            -- JR
    ("00", "00", '0', '0', '0', '0', '0'),            -- BRANCH
    ("11", "00", '0', '0', '0', '0', '0'));           -- HALT

  constant HALT : bit_vector := x"f";


  signal selNxtIP, selC : reg2;
  signal selBeta, wr_display, wr_reg : bit;
  signal mem_sel, mem_wr : bit;

  signal instr, A, B, C, beta, extended, ula_D, mem_D, ula_beta, ipPlus1: reg32;
  signal this  : t_control_type;
  signal const, ip, ipSel : reg16;
  signal opcode : reg4;
  signal selNxtIP2 : reg2;
  signal invRst : bit;
  signal i_opcode : natural range 0 to 15;

begin  -- functional

  -- memoria de programa contem somente 128 palavras
  U_mem_prog: mem_prog port map(ip(6 downto 0), instr);

  opcode <= instr(31 downto 28);
  i_opcode <= BV2INT4(opcode);          -- indice do vetor DEVE ser inteiro
  const    <= instr(15 downto 0);

  this <= ctrl_table(i_opcode);         -- sinais de controle

  selBeta    <= this.selBeta;
  wr_display <= this.wr_display;
  selNxtIP   <= this.selNxtIP;
  wr_reg     <= this.wr_reg;
  selC       <= this.selC;
  mem_sel    <= this.mem_sel;
  mem_wr     <= this.mem_wr;

  U_invRst : inv port map (rst, invrst);

  U_bran: branch port map (A, B, opcode, selNxtIP, selNxtIP2);

  U_muxIP: mux4_16b port map (ipPlus1(15 downto 0), extended(15 downto 0), A(15 downto 0), ip, selNxtIP2, ipSel);

  U_ip_control: ip_reg port map (clk, invRst, '0', '1', ipSel, ip);

  U_ext: extender port map (const, const(15), extended);

  U_ip1: adderAdianta16 port map (ip, x"0000", ipPlus1(15 downto 0), '1', open);

  U_regs: R port map (clk, wr_reg, instr(27 downto 24), instr(23 downto 20), instr(19 downto 16), A, B, C);

  U_muxBeta: mux2_32b port map (B, extended, selBeta, ula_beta);

  U_ULA: ULA port map (instr(31 downto 28), A, ula_beta, ula_D);

  U_mem: RAM port map (rst, clk, mem_sel, mem_wr, ula_D(15 downto 0), B, mem_D);

  U_muxC: mux4_32b port map (ipPlus1, ula_D, mem_D, x"00000000", selC, C);


  -- nao altere esta linha
  U_display: display port map (rst, clk, wr_display, A);


  assert opcode /= HALT
    report LF & LF & "simulation halted: " &
    "ender = "&integer'image(BV2INT16(ip))&" = "&BV16HEX(ip)&LF
    severity failure;

end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity ULA is
  port (fun : in reg4;
        alfa,beta : in  reg32;
        gama      : out reg32);
end ULA;

architecture behaviour of ULA is

  component adderAdianta16 is                      -- aux.vhd | ip+1
    port (inpA, inpB : in reg16;
          outC		: out  reg16;
          vem 		: in  bit;
          vai 		: out  bit);
  end component adderAdianta16;

  component mult16x16 is                      -- aux.vhd | ip+1
    port (A, B : in reg16;
          prod		: out  reg32);
  end component mult16x16;

  component mux2_16b is                      -- aux.vhd | seletor ip
    port (a0, a1  : in reg16;
          s		: in  bit;
          z 		: out  reg16);
  end component mux2_16b;

  component mux16_32b is                      -- aux.vhd | seletor ip
    port (a0, a1, a2, a3, a4, a5, a6, a7, a8,
  	  a9, a10, a11, a12, a13, a14, a15  : in reg32;
          s		: in  reg4;
          z 		: out  reg32);
  end component mux16_32b;

  -- signal
  signal soma, sub, mult, multPos, invMult, multNeg, auxMult, and32, or32, xor32, invA, invB : reg32;
  signal comp2A, comp2B, multA, multB : reg16;
  signal vaiSoma, vaiSub, vaiMult : bit;

begin  -- behaviour

	-- operacoes logicas
	and32 <= alfa and beta;
	or32 <= alfa or beta;
	xor32 <= alfa xor beta;
	invA <= not alfa;
	invB <= not beta;

	--operacoes aritmeticas
	-- soma
	U_soma1: adderAdianta16 port map (alfa(15 downto 0), beta(15 downto 0), soma (15 downto 0), '0', vaiSoma);
	U_soma2: adderAdianta16 port map (alfa(31 downto 16), beta(31 downto 16), soma (31 downto 16), vaiSoma, open);

	-- sub
	U_sub1: adderAdianta16 port map (alfa(15 downto 0), beta(15 downto 0), sub (15 downto 0), '1', vaiSub);
	U_sub2: adderAdianta16 port map (alfa(31 downto 16), beta(31 downto 16), sub (31 downto 16), vaiSub, open);

	-- mult
		-- cria complementos
	U_comp1: adderAdianta16 port map (invA(15 downto 0), x"0000", comp2A, '1', open);
	U_comp2: adderAdianta16 port map (invB(15 downto 0), x"0000", comp2B, '1', open);

		-- se o numero for negativo, seleciona o seu complemento
	U_muxMult1: mux2_16b port map (alfa(15 downto 0), comp2A, alfa(31), multA);
	U_muxMult2: mux2_16b port map (beta(15 downto 0), comp2B, beta(31), multB);

	U_mult: mult16x16 port map (multA, multB, multPos);

		-- transforma a multiplicação em numero negativo / cria o complemento da multiplicacao
	invMult <= not multPos;
	U_comp3: adderAdianta16 port map (invMult(15 downto 0), x"0000", multNeg (15 downto 0), '1', vaiMult);
	U_comp4: adderAdianta16 port map (invMult(31 downto 16), x"0000", multNeg (31 downto 16), vaiMult, open);

		-- seleciona o resultado da multiplicacao
	mult <= multNeg when ((alfa(31) xor beta(31)) = '1')
		else multPos;

	-- seleciona a operacao
	U_result: mux16_32b port map (x"00000000", soma, sub, mult, and32, or32, xor32, invA, soma, soma, soma, x"00000000", x"00000000", x"00000000",
			     x"00000000", x"00000000", fun, gama);



end behaviour;
-- -----------------------------------------------------------------------



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- display: exibe inteiro na saida padrao do simulador
--          NAO ALTERE ESTE MODELO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use std.textio.all;
use work.p_wires.all;

entity display is
  port (rst,clk : in bit;
        enable  : in bit;
        data    : in reg32);
end display;

architecture functional of display is
  file output : text open write_mode is "STD_OUTPUT";
begin  -- functional

  U_WRITE_OUT: process(clk)
    variable msg : line;
  begin
    if falling_edge(clk) and enable = '1' then
      write ( msg, string'(BV32HEX(data)) );
      writeline( output, msg );
    end if;
  end process U_WRITE_OUT;

end functional;
-- ++ display ++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- memoria RAM, com capacidade de 64K palavras de 32 bits
--          NAO ALTERE ESTE MODELO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity RAM is
  port (rst, clk : in  bit;
        sel      : in  bit;          -- ativo em 1
        wr       : in  bit;          -- ativo em 1
        ender    : in  reg16;
        data_inp : in  reg32;
        data_out : out reg32);

  constant DATA_MEM_SZ : natural := 2**16;
  constant DATA_ADDRS_BITS : natural := log2_ceil(DATA_MEM_SZ);

end RAM;

architecture rtl of RAM is

  subtype t_address is unsigned((DATA_ADDRS_BITS - 1) downto 0);

  subtype word is bit_vector(31 downto 0);
  type storage_array is
    array (natural range 0 to (DATA_MEM_SZ - 1)) of word;
  signal storage : storage_array;
begin

  accessRAM: process(rst, clk, sel, wr, ender, data_inp)
    variable u_addr : t_address;
    variable index, latched : natural;

    variable d : reg32 := (others => '0');
    variable val, i : integer;

  begin

    if (rst = '0') and (sel = '1') then -- normal operation

      index := BV2INT16(ender);

      if  (wr = '1') and rising_edge(clk) then

        assert (index >= 0) and (index < DATA_MEM_SZ)
          report "ramWR index out of bounds: " & natural'image(index)
          severity failure;

        storage(index) <= data_inp;

        assert TRUE report "ramWR["& natural'image(index) &"] "
          & BV32HEX(data_inp); -- DEBUG

      else

        assert (index >= 0) and (index < DATA_MEM_SZ)
          report "ramRD index out of bounds: " & natural'image(index)
          severity failure;

        d := storage(index);

        assert TRUE report "ramRD["& natural'image(index) &"] "
          & BV32HEX(d);  -- DEBUG

      end if; -- normal operation

      data_out <= d;

    else

      data_out <= (others=>'0');

    end if; -- is reset?

  end process accessRAM; -- ---------------------------------------------

end rtl;
-- -----------------------------------------------------------------------



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- banco de registradores
--          NAO ALTERE ESTE MODELO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity R is
  port (clk         : in  bit;
        wr_en       : in  bit;          -- ativo em 1
        r_a,r_b,r_c : in  reg4;
        A,B         : out reg32;
        C           : in  reg32);
end R;

architecture rtl of R is
  type reg_file is array(0 to 15) of reg32;
  signal reg_file_A : reg_file;
  signal reg_file_B : reg_file;
  signal int_ra, int_rb, int_rc : integer range 0 to 15;
begin

  int_ra <= BV2INT4(r_a);
  int_rb <= BV2INT4(r_b);
  int_rc <= BV2INT4(r_c);

  A <= reg_file_A( int_ra ) when r_a /= b"0000" else
       x"00000000";                        -- reg0 always zero
  B <= reg_file_B( int_rb ) when r_b /= b"0000" else
       x"00000000";

  WRITE_REG_BANKS: process(clk)
  begin
    if rising_edge(clk) then
      if wr_en = '1' and r_c /= b"0000" then
        reg_file_A( int_rc ) <= C;
        reg_file_B( int_rc ) <= C;
      end if;
    end if;
  end process WRITE_REG_BANKS;

end rtl;
-- -----------------------------------------------------------------------

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- branch(A,B,op,ip,ipSaida)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity branch is
  port(A, B : 	in  reg32;
       op   : 	in  reg4;
       ip   : 	in reg2;
       ipSaida : out reg2);
end branch;

architecture comport of branch is

begin
	ipSaida <= "01" when (op = x"e" and A = B)
		   else ip;
end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- extender(const, sel, ext)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity extender is
  port(const	: in  reg16;             -- oito entradas de dados
       sel 	: in bit;
       ext 	: out reg32);
end extender;

architecture comport of extender is

begin
	ext <= x"0000" & const when sel = '0'
	       else x"ffff" & const;
end architecture comport;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- registrador de 32 bits, reset=0 assincrono, load=1, enable=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use work.p_WIRES.all;

entity ip_reg is
  port(rel, rst, ld, en: in  bit;
        D:               in  reg16;
        Q:               out reg16);
end ip_reg;

architecture funcional of ip_reg is
  signal count: reg16;
begin

  process(rel, rst, ld)
  begin
    if rst = '0' then
      count <= x"0000";
    elsif ld = '1' then
      count <= D;
    elsif en = '1' and rising_edge(rel) then
      count <= D;
    end if;
  end process;

  Q <= count after t_FFD;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2_32b(a0,a1,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2_32b is
  port(a0,a1: in  reg32;
       s   : in  bit;
       z       : out reg32);
end mux2_32b;

architecture comport of mux2_32b is

begin
	with s select
		z <= a0 when '0',
		     a1 when others;

end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2_16b(a0,a1,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2_16b is
  port(a0,a1 : in  reg16;
       s   : in  bit;
       z   : out reg16);
end mux2_16b;

architecture comport of mux2_16b is

begin
	with s select
		z <= a0 when '0',
	     	     a1 when others;

end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux4_16b(a0,a1,a2,a3,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux4_16b is
  port(a0,a1,a2,a3 : in  reg16;
       s   : in  reg2;
       z       : out reg16);
end mux4_16b;

architecture comport of mux4_16b is

begin
	with s select
		z <= a0 when "00",
		     a1 when "01",
		     a2 when "10",
		     a3 when others;

end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux4_32b(a0,a1,a2,a3,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux4_32b is
  port(a0,a1,a2,a3 : in  reg32;
       s   : in  reg2;
       z       : out reg32);
end mux4_32b;

architecture comport of mux4_32b is

begin
	with s select
		z <= a0 when "00",
		     a1 when "01",
		     a2 when "10",
		     a3 when others;

end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux16_32b(a0,a1,a2,a3,a4,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux16_32b is
  port(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15: in  reg32;
       s   : in  reg4;
       z       : out reg32);
end mux16_32b;

architecture comport of mux16_32b is

begin
	with s select
		z <= a0 when "0000",
		     a1 when "0001",
		     a2 when "0010",
		     a3 when "0011",
		     a4 when "0100",
		     a5 when "0101",
		     a6 when "0110",
		     a7 when "0111",
		     a8 when "1000",
		     a9 when "1001",
		     a10 when "1010",
		     a11 when "1011",
		     a12 when "1100",
		     a13 when "1101",
		     a14 when "1110",
		     a15 when others;

end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
