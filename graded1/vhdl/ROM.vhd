library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

COMPONENT ROM_Block
port (
  address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
  clock		: IN STD_LOGIC  := '1';
  q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
end COMPONENT;

signal s_rddata : std_logic_vector(31 downto 0) := (others => 'Z');
signal s_addr: std_logic_vector(9 downto 0) := (others => '0');
signal s_readCs: std_logic := '0';

begin


  romClock: process(clk, s_rddata, cs, address)
  BEGIN
    if(rising_edge(clk) and cs = '1') then
		s_addr <= address;
		s_readCs <= read and cs;
    end if;
  end process;

rddata <= s_rddata when (s_readCs = '1') else
			(others => 'Z');

  romInst : ROM_Block
  port map(
    address => address,
    clock => clk,
    q => s_rddata
  );


end synth;
