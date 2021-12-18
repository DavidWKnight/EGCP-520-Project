library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic
    (
        g_bitwidth : integer := 32;
        g_fault    : integer := 0
    );
    port
    (
        i_ALUOp : in std_logic_vector(3 downto 0);
        i_in1   : in std_logic_vector(g_bitwidth-1 downto 0);
        i_in2   : in std_logic_vector(g_bitwidth-1 downto 0);

        o_out  : out std_logic_vector(g_bitwidth-1 downto 0);
        o_zero : out std_logic
    );
end entity ALU;

architecture rtl of ALU is

begin

    process (all) is
    begin
        if g_fault = 1 then
            o_out <= x"A5A5A5A5";
        else
            case i_ALUOp is
                when "0000" => o_out <= i_in1 and i_in2; -- AND
                when "0001" => o_out <= i_in1 or i_in2; -- OR
                when "0010" => o_out <= i_in1 xor i_in2; -- XOR
                when "0011" => o_out <= std_logic_vector(signed(i_in1) + signed(i_in2)); -- ADD
                when "0100" => o_out <= std_logic_vector(signed(i_in1) - signed(i_in2)); -- SUB
                when "0101" => o_out <= std_logic_vector(resize(signed(i_in1) * signed(i_in2), g_bitwidth)); -- MUL
                when others => o_out <= i_in1;
            end case;
        end if;
    end process;

    process(all) is
    begin
        if (unsigned(o_out) = 0) then
            o_zero <= '1';
        else
            o_zero <= '0';
        end if;
    end process;

end rtl ; -- rtl
