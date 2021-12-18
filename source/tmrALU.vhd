library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mipsLib;
use mipsLib.all;

entity tmrALU is
    generic
    (
        g_bitwidth : integer := 32;
        g_redundancy : integer := 3;
        g_fault      : integer := 0
    );
    port
    (
        i_ALUOp : in std_logic_vector(3 downto 0);
        i_in1   : in std_logic_vector(g_bitwidth-1 downto 0);
        i_in2   : in std_logic_vector(g_bitwidth-1 downto 0);
        
        o_out  : out std_logic_vector(g_bitwidth-1 downto 0);
        o_zero : out std_logic
    );
end entity tmrALU;

architecture rtl of tmrALU is    
    signal alu_out : mips_types.tmr_alu_out_t;
    signal alu_zero : mips_types.tmr_alu_zero_t;
begin

    aluEnt0 : entity mipsLib.ALU
    generic map(
        g_bitwidth => g_bitwidth,
        g_fault    => g_fault
    )
    port map(
        i_ALUOp => i_ALUOp,
        i_in1   => i_in1,
        i_in2   => i_in2,
        o_out   => alu_out(0),
        o_zero  => alu_zero(0)
    );

    aluEnt1 : entity mipsLib.ALU
    generic map(
        g_bitwidth => g_bitwidth
    )
    port map(
        i_ALUOp => i_ALUOp,
        i_in1   => i_in1,
        i_in2   => i_in2,
        o_out   => alu_out(1),
        o_zero  => alu_zero(1)
    );

    aluEnt2 : entity mipsLib.ALU
    generic map(
        g_bitwidth => g_bitwidth
    )
    port map(
        i_ALUOp => i_ALUOp,
        i_in1   => i_in1,
        i_in2   => i_in2,
        o_out   => alu_out(2),
        o_zero  => alu_zero(2)
    );

    voter : process (all)
    begin
        if alu_out(0) = alu_out(1) then
            o_out <= alu_out(0);
        elsif alu_out(0) = alu_out(2) then
            o_out <= alu_out(0);
        elsif alu_out(1) = alu_out(2) then
            o_out <= alu_out(1);
        else -- All outputs disagree
            o_out <= alu_out(0); -- For now assume 0 is correct
        end if;
        
        if alu_zero(0) = alu_zero(1) then
            o_zero <= alu_zero(0);
        elsif alu_zero(0) = alu_zero(2) then
            o_zero <= alu_zero(0);
        elsif alu_zero(1) = alu_zero(2) then
            o_zero <= alu_zero(1);
        else -- All outputs disagree
            o_zero <= alu_zero(0); -- For now assume 0 is correct
        end if;
    end process;

end rtl ; -- rtl
