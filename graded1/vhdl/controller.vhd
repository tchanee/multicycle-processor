library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
  type state_type is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP, BRANCH, JMP, CALL);
  signal current_state, next_state : state_type := FETCH1;


begin



  stateManager: process(reset_n, clk)
  begin
  if (reset_n = '0') then
    current_state <= FETCH1;
  elsif(rising_edge(clk)) then
      current_state <= next_state;
  end if;
  end process;

  flipflop : process(current_state, op, opx)
  begin
  read <= '0';
  write <= '0';
  imm_signed <= '0';
  rf_wren <= '0';
  sel_b <= '0';
  sel_rC <= '0';
  sel_addr <= '0';
  sel_mem <= '0';
  ir_en <= '0';
  pc_en <= '0';
  pc_sel_a <= '0';
  pc_sel_imm <= '0';
  sel_pc <= '0';
  sel_ra <= '0';
  pc_add_imm <= '0';
  branch_op <= '0';
  if (current_state = FETCH1) then
    read <= '1';
    next_state <= FETCH2;
  elsif (current_state = FETCH2) then
    ir_en <= '1';
    pc_en <= '1';
    next_state <= DECODE;
  elsif (current_state = DECODE) then
    if(("00"&op) = (x"3A") and (("00"&opx) /= x"34") and (("00"&opx) /= x"1D") and (("00"&opx) /= x"05") and (("00"&opx) /= x"0D")) then
      next_state <= R_OP;
    elsif (("00"&op) = (x"04") or (op(2 downto 0)) = ("100") or ( (op(2 downto 0)) = ("000") and (op /= "000000") ) ) then
      next_state <= I_OP;
    elsif (("00"&op) = (x"17")) then
      next_state <= LOAD1;
    elsif (("00"&op) = (x"15")) then
      next_state <= STORE;
    elsif(("00"&op) = (x"3A") and (("00"&opx) = x"34" )) then
      next_state <= BREAK;
    elsif(("00"&op) = (x"06") or ("00"&op) = (x"0E") or ("00"&op) = (x"16") or ("00"&op) = (x"1E") or ("00"&op) = (x"26") or ("00"&op) = (x"2E") or ("00"&op) = (x"") or ("00"&op) = (x"36")) then
      next_state <= BRANCH;
    elsif( ( ("00"&op)=(x"3A") and ( ("00"&opx)=x"05"  or ("00"&opx)=x"0D" ) ) or ("00")&op = (x"01")  ) then
      next_state <= JMP;
    elsif( ("00"&op) = (x"00") or ( ("00"&op) = (x"3A") and ( (("00"&opx) /= x"1D") or (("00"&opx)/=x"05") or (("00"&opx)=x"0D") ) )  ) then
      next_state <= CALL;
    end if;
  elsif (current_state = I_OP) then
	if(op /= "001100" and op /= "010100" and op /= "011100" and op /= "101000" and op /= "110000") then
	  imm_signed <= '1';
	end if;
    rf_wren <= '1';
    next_state <= FETCH1;
  elsif (current_state = R_OP) then
	if (opx(2 downto 0) /= "010") then
		sel_b <= '1';
	end if;
    rf_wren <= '1';
    sel_rC <='1';
    next_state <= FETCH1;
  elsif (current_state = LOAD1) then
    sel_addr <= '1';
    read <= '1';
    imm_signed <= '1';
    next_state <= LOAD2;
  elsif (current_state = LOAD2) then
    rf_wren <= '1';
    sel_mem <= '1';
    next_state <= FETCH1;
  elsif (current_state = STORE) then
    sel_addr <= '1';
    write <= '1';
    imm_signed <= '1';
    next_state <= FETCH1;
  elsif (current_state = BREAK) then
    next_state <= BREAK;
  elsif (current_state = BRANCH) then
    pc_add_imm <= '1';
    sel_b <= '1';
    branch_op <= '1';
    next_state <= FETCH1;
  elsif (current_state = CALL) then
    pc_en <= '1';
    if (("00"&opx) = x"1D")  then
      pc_sel_a <= '1';
    else
      pc_sel_imm <= '1';
    end if;
    rf_wren <= '1';
    sel_pc <= '1';
    sel_ra <= '1';
    next_state <= FETCH1;
  elsif (current_state = JMP) then
    pc_en <= '1';
    if (("00"&op) = x"3A") then --RTYPE
	  pc_sel_imm <= '0';
      pc_sel_a <= '1';
    else --itype
      pc_sel_imm <= '1';
    end if ; 
	next_state <= FETCH1;
  end if;


  end process;







  opAlu : process(op,opx, current_state)
  begin
    if(("00"&op) = x"3A") then -- RType
		if(opx(2 downto 0) = "110") then -- logical
			op_alu <= "100"&opx(5 downto 3);
		elsif(opx(2 downto 0) = "011") then -- shift rotate
			op_alu <= "110"&opx(5 downto 3);
		elsif(opx(2 downto 0) = "010") then -- shift rotate bis
			op_alu <= "110"&opx(5 downto 3);
		elsif(opx(2 downto 0) = "000") then -- comparison
			op_alu <= "011"&opx(5 downto 3);
		elsif(opx = "110001") then -- add
			op_alu <= "000"&opx(5 downto 3);
		elsif(opx = "111001") then -- sub
			op_alu <= "001"&opx(5 downto 3);
		else
			op_alu <= "000000"; -- other cases 
		end if;
    elsif(("00"&op) = x"06") then -- unconditionnal branch
      op_alu <= "011100"; -- down below now IType 
	elsif(op(2 downto 0) = "110") then -- branch with comparison
		op_alu <= "011" & op(5 downto 3);
	elsif(op(2 downto 0) = "000") then -- comparison
		op_alu <= "011" & op(5 downto 3);
	elsif(op(2 downto 0) = "100") then -- and/or/xor  AND add
		if(op = "000100") then -- Here we exclude the add 
			op_alu <= "000000";
		else
			op_alu <= "100" & op(5 downto 3);
		end if;
    else
      op_alu <= "000000"; -- default ITYPE
    end if;
  end process;





end synth;
