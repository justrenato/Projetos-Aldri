-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2013-2, autor: Roberto Hexsel, 03sep2016
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio mux2(a,b,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2 is
  port(a,b : in  bit;                   -- entradas de dados
       s   : in  bit;                   -- entrada de selecao
       z   : out bit);                  -- saida
end mux2;

architecture estrut of mux2 is 

  -- declara componentes que sao instanciados
  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

  component or2 is
    port(A,B : in bit; S : out bit);
  end component or2;

  -- sinais internos
  signal r, p, q : bit;              
  
  -- compare ligacoes dos sinais com diagrama das portas logicas
  begin  

    Uinv0: inv  port map(s, r);
    Uand0: and2 port map(a, r, p);
    Uand1: and2 port map(b, s, q);
    Uor0:  or2  port map(p, q, z);
    
end architecture estrut;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio mux4(a,b,c,d,s0,s1,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux4 is
  port(a,b,c,d : in  bit;               -- quatro entradas de dados
       s0,s1   : in  bit;               -- dois sinais de selecao
       z       : out bit);              -- saida
end mux4;

architecture estrut of mux4 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  signal p,q: bit;                   -- sinais internos
begin
  
  Umux1: mux2 port map (a, b, s0, p); 
  Umux2: mux2 port map (c, d, s0, q);
  Umux3: mux2 port map (p, q, s1, z);

    -- implemente usando tres mux2

end architecture estrut;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio mux8(a,b,c,d,e,f,g,h,s0,s1,s2,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux8 is
  port(a,b,c,d,e,f,g,h : in  bit;       -- oito entradas de dados
       s0,s1,s2        : in  bit;       -- tres sinais de controle
       z               : out bit);      -- saida
end mux8;

architecture estrut of mux8 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  component mux4 is
    port(A,B,C,D : in  bit; S0,S1 : in  bit; Z : out bit);
  end component mux4;

  signal p,q : bit;                   -- sinais internos
  
begin
  
  Umux1: mux4 port map (a, b, c, d, s0, s1, p); 
  Umux2: mux4 port map (e, f, g, h, s0, s1, q);
  Umux3: mux2 port map (p, q, s2, z);

  -- implemente usando dois mux4 e um mux2

end architecture estrut;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio mux8vet(entr(7downto0),sel(2downto1),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux8vet is
  port(entr : in  reg8;
       sel  : in  reg3;
       z    : out bit);
end mux8vet;

architecture estrut of mux8vet is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  component mux4 is
    port(A,B,C,D : in  bit; S0,S1 : in  bit; Z : out bit);
  end component mux4;

  signal p,q,r : bit;
  
begin
  
  Umux1: mux4 port map (entr(0),entr(1),entr(2),entr(3),sel(0),sel(1) , p); 
  Umux2: mux4 port map (entr(4),entr(5),entr(6),entr(7),sel(0),sel(1) , q);
  Umux3: mux2 port map (p, q, sel(2), z);

  -- implemente usando dois mux4 e um mux2

end architecture estrut;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio demux2(a,s,z,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux2 is
  port(a   : in  bit;
       s   : in  bit;
       z,w : out bit);
end demux2;

architecture estrut of demux2 is 

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

signal r : bit;  

begin

    Uinv0:  inv port map(s, r);
    Uand0: and2 port map(a, r, z);
    Uand1: and2 port map(a, s, w);

  -- implemente com portas logicas

end architecture estrut;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio demux4(a,s0,s1,x,y,z,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux4 is
  port(a       : in  bit;
       s0,s1   : in  bit;
       x,y,z,w : out bit);
end demux4;

architecture estrut of demux4 is

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

  component demux2 is
    port(A,S : in bit; Z,W : out bit);
  end component demux2;

signal o,p,q,r : bit;

begin
  
    Uinv0:  inv   port map(s0, q);
    Uinv1:  inv   port map(s1, r);
    Uand0: and2  port map(a, r, o);
    Udem: demux2 port map (o, s0, x, y);
    Uand1: and2  port map(a, s1, p);
    Uand2: and2  port map(p, q, z);
    Uand3: and2  port map(p, s0, w);
  -- implemente com um demux2 e circuito(s) visto(s) nesta aula

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio demux8(a,s0,s1,s2,p,q,r,s,t,u,v,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux8 is
  port(a               : in  bit;
       s0,s1,s2        : in  bit;
       p,q,r,s,t,u,v,w : out bit);
end demux8;

architecture estrut of demux8 is

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

  component demux2 is
    port(A,S : in bit; Z,W : out bit);
  end component demux2;

signal b,c,d,e,f,g,h,i : bit;

begin

    Ui1:  inv     port map(s1, d);
    Ui2:  inv     port map(s2, i);
    Ud:   demux2  port map(a, s0, b, c);
    Ua0:  and2    port map(b, s1, e);
    Ua1:  and2    port map(b, d, f);
    Ua2:  and2    port map(c, s1, g);
    Ua3:  and2    port map(c, d, h);
    Ua4:  and2    port map(s2, e, p);
    Ua5:  and2    port map( e, i, q);
    Ua6:  and2    port map( f, s2, r);
    Ua7:  and2    port map( f, i, s);
    Ua8:  and2    port map( g, s2, t);
    Ua9:  and2    port map( g, i, u);
    Ua10: and2    port map( h, s2, v);
    Ua11: and2    port map( h, i, w);
  -- implemente com um demux2 e circuito(s) visto(s) nesta aula

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio decod2(s,z,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity decod2 is
  port(s   : in  bit;
       z,w : out bit);
end decod2;

architecture estrut of decod2 is 

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

signal r : bit;

begin

    Ui:  inv  port map(r, z);
    Ua0: and2 port map(s, s, r);
    Ua1: and2 port map(s, s, w);

  -- implemente com portas logicas

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio decod4(s0,s1,x,y,z,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity decod4 is
  port(s0,s1   : in  bit;
       x,y,z,w : out bit);
end decod4;

architecture estrut of decod4 is

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

  component decod2 is
    port(S : in bit; Z,W : out bit);
  end component decod2;  

signal a,b,c,d,e : bit;

begin

    Ui:  inv    port map(s1, a);
    Ud0: decod2 port map(s0, b, c);
    Ud1: decod2 port map(s0, d, e);
    Ua0: and2 port map(b, a, x);
    Ua1: and2 port map(c, a, y);
    Ua2: and2 port map(d, s1, z);
    Ua3: and2 port map(e, s1, w);

  -- implemente com decod2 e circuito(s) visto(s) nesta aula


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inicio decod8(s0,s1,s2,p,q,r,s,t,u,v,w)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity decod8 is
  port(s0,s1,s2        : in  bit;
       p,q,r,s,t,u,v,w : out bit);
end decod8;

architecture estrut of decod8 is 

  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and3 is
    port(A,B,C : in bit; S : out bit);
  end component and3;

  component decod2 is
    port(S : in bit; Z,W : out bit);
  end component decod2;  

signal a,b,g,h : bit;

begin
  
    Ui0:  inv    port map(s1, h);
    Ui1:  inv    port map(s2, g);
    Ud0: decod2 port map(s0, a, b);
    Ua0: and3 port map(g, h, a, p);
    Ua1: and3 port map(g, h, b, q);
    Ua2: and3 port map(g, s1, a, r);
    Ua3: and3 port map(g, s1, b, s);
    Ua4: and3 port map(s2, h, a, t);
    Ua5: and3 port map(s2, h, b, u);
    Ua6: and3 port map(s2, s1, a, v);
    Ua7: and3 port map(s2, s1, b, w);
  -- implemente com decod2 e circuito(s) visto(s) nesta aula

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

