library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
  signal cs_which : std_logic_vector(2 downto 0);
begin


  cs_which <= "110" when (address <= x"0FFC") else
			  "100" when ( (address >= x"1000") and (address <= x"1FFC")) else
			  "010" when ((address >= x"2000") and (address <= x"200C")) else
			  "001" when ((address >= x"2030") and (address <= x"2034")) else
              "000";


  cs_buttons <= '1' when (cs_which = "001") else '0'; 
  cs_LEDS <= '1' when (cs_which = "010") else '0';
  cs_RAM <= '1' when (cs_which = "100") else '0';
  cs_ROM <= '1' when (cs_which = "110") else '0';
end synth;
