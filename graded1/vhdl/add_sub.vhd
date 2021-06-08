library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is

  signal s_r : unsigned(32 downto 0) := to_unsigned(0,33);

begin


  s_r <= unsigned('0' & a) + unsigned('0' & b) when(sub_mode =  '0') else
         unsigned('0' & a) + ('0' & not(unsigned(b))) + 1;

  zero <= '1' when (s_r(31 downto 0) = to_unsigned(0, 32)) else
          '0';

  r <= std_logic_vector(s_r(31 downto 0));

  carry <= s_r(32);


end synth;
