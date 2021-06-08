library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
signal s_sll, s_srl, s_sra, s_rol, s_ror : unsigned(31 downto 0) := to_unsigned(0,32);
begin




  r <= std_logic_vector(s_sll) when (op = "010") else
       std_logic_vector(s_srl) when (op = "011") else
       std_logic_vector(s_sra) when (op = "111") else
       std_logic_vector(s_ror) when (op = "001") else
       std_logic_vector(s_rol) when (op = "000") else
       std_logic_vector(to_unsigned(0,32));

  sh_leftl : process(a, b)
    variable v : std_logic_vector(31 downto 0);
  begin
    v := a;
-- shift by 1
    if (b(0) = '1') then
      v := v(30 downto 0) & '0';
    end if;
-- shift by 2
    if (b(1) = '1') then
      v := v(29 downto 0) & (1 downto 0 => '0');
    end if;
-- shift by 4
    if (b(2) = '1') then
      v := v(27 downto 0) & (3 downto 0 => '0');
    end if;
-- shift by 8
    if (b(3) = '1') then
      v := v(23 downto 0) & (7 downto 0 => '0');
    end if;
-- shift by 16
    if (b(4) = '1') then
      v := v(15 downto 0) & (15 downto 0 => '0');
    end if;
    s_sll <= unsigned(v);
  end process;


    sh_rightl : process(a, b)
    variable v : std_logic_vector(31 downto 0);
    begin
    v := a;
-- shift by 1
    if (b(0) = '1') then
      v := '0' & v(31 downto 1);
    end if;
-- shift by 2
    if (b(1) = '1') then
      v := (1 downto 0 => '0') & v(31 downto 2);
    end if;
-- shift by 4
    if (b(2) = '1') then
      v := (3 downto 0 => '0') & v(31 downto 4);
    end if;
-- shift by 8
    if (b(3) = '1') then
      v := (7 downto 0 => '0') & v(31 downto 8);
    end if;
-- shift by 16
    if (b(4) = '1') then
      v := (15 downto 0 => '0') & v(31 downto 16);
    end if;
    s_srl <= unsigned(v);
  end process;

    sh_righta : process(a, b)
    variable v : std_logic_vector(31 downto 0);
    begin
    v := a;
-- shift by 1
    if (b(0) = '1') then
      v := v(31)  & v(31 downto 1);
    end if;
-- shift by 2
    if (b(1) = '1') then
      v := (1 downto 0 => v(31)) & v(31 downto 2);
    end if;
-- shift by 4
    if (b(2) = '1') then
      v := (3 downto 0 => v(31)) & v(31 downto 4);
    end if;
-- shift by 8
    if (b(3) = '1') then
      v := (7 downto 0 => v(31)) & v(31 downto 8);
    end if;
-- shift by 16
    if (b(4) = '1') then
      v := (15 downto 0 => v(31)) & v(31 downto 16);
    end if;
    s_sra <= unsigned(v);
  end process;


    ro_r : process(a, b)
    variable v : std_logic_vector(31 downto 0);
    begin
    v := a;
-- shift by 1
    if (b(0) = '1') then
      v := v(0) & v(31 downto 1);
    end if;
-- shift by 2
    if (b(1) = '1') then
      v := v(1 downto 0) & v(31 downto 2);
    end if;
-- shift by 4
    if (b(2) = '1') then
      v := v(3 downto 0) & v(31 downto 4);
    end if;
-- shift by 8
    if (b(3) = '1') then
      v := v(7 downto 0) & v(31 downto 8);
    end if;
-- shift by 16
    if (b(4) = '1') then
      v := v(15 downto 0) & v(31 downto 16);
    end if;
    s_ror <= unsigned(v);
  end process;

    ro_l : process(a, b)
    variable v : std_logic_vector(31 downto 0);
  begin
    v := a;
-- shift by 1
    if (b(0) = '1') then
      v := v(30 downto 0) & v(31);
    end if;
-- shift by 2
    if (b(1) = '1') then
      v := v(29 downto 0) & v(31 downto 30);
    end if;
-- shift by 4
    if (b(2) = '1') then
      v := v(27 downto 0) & v(31 downto 28);
    end if;
-- shift by 8
    if (b(3) = '1') then
      v := v(23 downto 0) & v(31 downto 24);
    end if;
-- shift by 16
    if (b(4) = '1') then
      v := v(15 downto 0) & v(31 downto 16);
    end if;
    s_rol <= unsigned(v);
  end process;



end synth;
