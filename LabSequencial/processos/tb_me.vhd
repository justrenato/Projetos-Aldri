-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210                       autor: Roberto Hexsel, 27out2015
--                                               rev 12set2016
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- esqueleto do testbench para ME que detecta ...01111110...
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;


library ieee;

--entity FF0 is
--  port (D: in  bit;
--      clk: in  bit;
--        Q: out bit);
--end FF0;

--architecture waitSimples of FF0 is
--begin
--  FF: process
-- begin
--  wait for (clk'event and clk ='1'); -- borda em clk
--  Q <= D;
--  end process FF ;
--end waitSimples;



entity tb_ME is
end tb_ME;


architecture TB of tb_ME is


  type test_record is record
                        e : bit;        -- entrada
                        s : bit;        -- saida esperada
  end record;
  type test_array is array(positive range <>) of test_record;
    
  constant test_vectors : test_array := (
    -- entr, saida
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('1', '0'),
    ('1', '0'),
    ('1', '0'),
    ('1', '0'),
    ('1', '0'),
    ('1', '0'),
    ('0', '0'),
    ('0', '1'),
    ('0', '0'),      -- acrescente mais testes a partir daqui
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0'),
    ('0', '0')
    );


  -- tipo enumerado: A=0, B=1, C=2, ...
  -- acrescente tantos estados quanto necessario
  type states is (A, B, C);

  signal curr_st, next_st : states;

  signal clk, reset, entr, found, esperada : bit;

  signal dbg_st : integer;
  
begin  -- TB

  dbg_st <= integer(states'pos(curr_st));  -- debugging only

  U_state_reg: process(reset, clk)
  begin
    if reset = '0' then
      curr_st <= A;
    elsif rising_edge(clk) then
      curr_st <= next_st;
    end if;
  end process U_state_reg;

  U_st_transitions: process(curr_st, entr)
  begin                  -- Máquina de Moore
    case curr_st is
      when A =>
        if entr = '0' then next_st <= A; 
        else next_st <= B;       end if;
        found <= '0';
      when B =>
        if entr = '1' then next_st <= A;
        else next_st <= C;       end if;
        found <= '0';
      when C =>
        if entr = '1' then next_st <= A;
        else next_st <= C;       end if;
        found <= '0';
    -- ...
    end case;
  end process U_st_transitions;
  -- ----------------------------------------------------------------
  

  -- ----------------------------------------------------------------
  U_testValues: process -- test the circuit
    variable v : test_record;
  begin

    esperada <= '0';
    entr     <= '0';

    wait until rising_edge(clk);        -- espera por dois ciclos e então 
    wait until rising_edge(clk);        --  inicia os testes
    
    for i in test_vectors'range loop

      v := test_vectors(i);
      entr     <= v.e;
      esperada <= v.s;

      assert esperada = found
        report LF & "entr="& B2STR(entr) & " esp=" & B2STR(esperada) &
               " found=" & B2STR(found) & " estado=" & natural'image(dbg_st)
        severity note;

      wait until rising_edge(clk);
      
    end loop;

    wait; -- -------------- end the simulation ------------------------
    
  end process;





--  FF0: process (clk) -- somente  clk na lista de sensibilidade
--  begin
--  if rising_edge(clk) then
--    Q <= D;
--  end if;
--  end process FF0;



  U_clock: process      -- concurrent process for clock, clock runs free
  begin
    clk <= '0';
    wait for t_clock_period / 2;
    clk <= '1';
    wait for t_clock_period / 2;
  end process;

  U_reset: process      -- reset initializes all
  begin
    reset <= '0';
    wait for t_reset;
    reset <= '1';	-- end of reset pulse
    wait;               -- this process stops here
  end process;
  
end TB;

----------------------------------------------------------------
configuration CFG_TB of TB_ME is
	for TB
  end for;
end CFG_TB;
----------------------------------------------------------------
