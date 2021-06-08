library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
  constant INCREMENT : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(4,16));
  signal s_pc : std_logic_vector(15 downto 0) := (others => '0');
begin

  flipflop : process(clk, reset_n, s_pc)
  begin
    if (reset_n = '0') then

      s_pc <= std_logic_vector(to_unsigned(0,16));

   

      elsif (rising_edge(clk)) then
        if(en = '1' and reset_n = '1') then
        if ( add_imm = '1') then
          s_pc <= std_logic_vector(unsigned(s_pc) + unsigned(imm(15 downto 2)&"00"));
        elsif (sel_imm = '1') then
          s_pc <= imm(13 downto 0) & "00";
        elsif (sel_a = '1') then
          s_pc <= a(15 downto 2) & "00";
        else
          s_pc <= std_logic_vector(unsigned(s_pc) + unsigned(INCREMENT));
        end if;
		end if;
	  else
	  s_pc <= s_pc;
      end if;
  end process;

  addr <= std_logic_vector(to_unsigned(0,16)&unsigned(s_pc(15 downto 0)));

end synth;
