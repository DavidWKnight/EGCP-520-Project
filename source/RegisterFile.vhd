library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mipsLib;
use mipsLib.all;

entity registerFile is
    generic
    (
        g_bitwidth : integer := 32;
        g_regwidth : integer := 5
    );
    port
    (
        i_reset : in std_logic;
        i_clk : in std_logic;

        i_rr1 : in std_logic_vector(g_regwidth-1 downto 0);
        i_rr2 : in std_logic_vector(g_regwidth-1 downto 0);
        
        i_we : in std_logic;
        i_wr : in std_logic_vector(g_regwidth-1 downto 0);
        i_wd : in std_logic_vector(g_bitwidth-1 downto 0);

        o_rd1 : out std_logic_vector(g_bitwidth-1 downto 0);
        o_rd2 : out std_logic_vector(g_bitwidth-1 downto 0)
    );
end entity registerFile;

architecture rtl of registerFile is
    signal registers : mips_types.registerFileRegs;
begin

    read : process(all)
    begin
        if (i_reset = '1') then
            o_rd1 <= (others => '0');
            o_rd2 <= (others => '0');
        else
            o_rd1 <= registers(to_integer(unsigned(i_rr1)));
            o_rd2 <= registers(to_integer(unsigned(i_rr2)));
        end if;
    end process;

    write : process(i_reset, i_clk)
    begin
        if (i_reset = '1') then
            for i in 0 to 2**g_regwidth-1 loop
                registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(i_clk) then
            if (i_we = '1') then 
                registers(to_integer(unsigned(i_wr))) <= i_wd;
            end if;
        end if;
    end process;

end rtl ; -- rtl
