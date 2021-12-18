----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2021 04:20:45 AM
-- Design Name: 
-- Module Name: tb_mips - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library mipsLib;
use mipsLib.all;

entity tb_mips is
--  Port ( );
end tb_mips;

architecture Behavioral of tb_mips is    
    signal aclk : std_logic;
    signal reset : std_logic;
    
    type cpu_std_logic_t is array(mips_types.c_numLockstepCPUs-1 downto 0) of std_logic;
    signal regDst : cpu_std_logic_t;
    
    --alias registers is << signal .tb_mips.uut.genALU[0].mipsEnt.RF.registers : mips_types.registerFileRegs >>;
    --alias alu0_in1 is << signal .tb_mips.uut.mipsEnt0.tmrSel.aluEnt.aluEnt0.i_in1 : std_logic_vector(mips_types.c_bitwidth-1 downto 0) >>;
begin

    --for i in 0 to mips_types.c_numLockstepCPUs-1 generate
    --    regDst(i) <= 
    --end generate;

    test : process
        --alias R0 is << signal .tb_mips.uut.RF.registers : mips_types.registerFileRegs >>(0);
    begin
        reset <= '1';
        for i in 0 to 5 loop
            wait until rising_edge(aclk);
        end loop;
        reset <= '0';

        wait until rising_edge(aclk);
        wait until rising_edge(aclk);
        wait until rising_edge(aclk);
        
        --alu0_in1 <= force x"FFFFFFFF";
        
        wait until rising_edge(aclk);
        wait until rising_edge(aclk);
        wait until rising_edge(aclk);
                
        --wait until rising_edge(aclk);
        --assert rf_regs(0) = x"0000001D" report "Load R0 Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(1) = x"0000000D" report "Load R1 Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(2) = x"0000000D" report "AND Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(3) = x"0000001D" report "OR Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(4) = x"00000010" report "XOR Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(5) = x"0000002A" report "ADD Failed" severity error;
        --wait until rising_edge(aclk);
        --assert rf_regs(6) = x"00000010" report "SUB Failed" severity error;
       -- wait until rising_edge(aclk);
        --assert rf_regs(7) = x"00000179" report "MUL Failed" severity error;

        wait;
    end process;

    uut : entity mipsLib.mipsLockstep
    generic map(
        g_bitwidth        => mips_types.c_bitwidth,
        g_memwidth        => mips_types.c_memwidth,
        g_regwidth        => mips_types.c_regwidth,
        g_tmrEnable       => 0,
        g_numLockstepCPUs => 2,
        g_tmr_fault       => 0,
        g_lockstep_fault  => 1
    )
    port map(
        i_clk   => aclk,
        i_reset => reset
    );

    clk_gen : process
    begin
        aclk <= '0';
        wait for 10ns;
        aclk <= '1';
        wait for 10ns;
    end process;
end Behavioral;
