library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    generic
    (
        g_lockstep_fault : integer := 0
    );
    port
    (
        i_reset : in std_logic;
        i_opcode : in std_logic_vector(5 downto 0);
        i_funct : in std_logic_vector(5 downto 0);

        o_regDst : out std_logic;
        o_branch : out std_logic;
        o_memRead : out std_logic;
        o_memToReg : out std_logic;
        o_ALUop    : out std_logic_vector(3 downto 0);
        o_memWrite : out std_logic;
        o_ALUSrc : out std_logic;
        o_regWrite : out std_logic
    );
end entity control_unit;

architecture rtl of control_unit is

begin

    mux : process (all) is
    begin
        if i_reset = '1' then
            o_regDst   <= '0';
            o_branch   <= '0';
            o_memRead  <= '0';
            o_memToReg <= '0';
            o_memWrite <= '0';
            o_ALUSrc   <= '0';
            o_regWrite <= '0';
        else
            case i_opcode is 
                when "000000" => -- R type
                    --o_regDst   <= '1' when g_lockstep_fault = 0 else '0';
                    o_regDst   <= '0' when g_lockstep_fault = 1 else '1';
                    o_branch   <= '0';
                    o_memRead  <= '0';
                    o_memToReg <= '0';
                    o_memWrite <= '0';
                    o_ALUSrc   <= '0';
                    o_regWrite <= '1';
                when "101011" => -- SW
                    o_regDst   <= '-';
                    o_branch   <= '0';
                    o_memRead  <= '0';
                    o_memToReg <= '-';
                    o_memWrite <= '1';
                    o_ALUSrc   <= '-';
                    o_regWrite <= '0';
                when "100011" => -- LW
                    o_regDst   <= '0';
                    o_branch   <= '0';
                    o_memRead  <= '1';
                    o_memToReg <= '1';
                    o_memWrite <= '0';
                    o_ALUSrc   <= '-';
                    o_regWrite <= '1';
                when others =>
                    o_regDst   <= '0';
                    o_branch   <= '0';
                    o_memRead  <= '0';
                    o_memToReg <= '0';
                    o_memWrite <= '0';
                    o_ALUSrc   <= '0';
                    o_regWrite <= '0';
            end case;
        end if;
    end process mux;

    ALU : process(all) is
    begin
        if i_reset = '1' then
            o_ALUop <= (others => '0');
        else
            case i_funct is
                when "100100" => o_ALUop <= "0000"; -- AND
                when "100101" => o_ALUop <= "0001"; -- OR
                when "100110" => o_ALUop <= "0010"; -- XOR
                when "100000" => o_ALUop <= "0011"; -- ADD
                when "100010" => o_ALUop <= "0100"; -- SUB
                when "011000" => o_ALUop <= "0101"; -- MUL
                when others => o_ALUop <= (others => '0');
            end case;
        end if;
    end process ALU;

end rtl ; -- rtl
