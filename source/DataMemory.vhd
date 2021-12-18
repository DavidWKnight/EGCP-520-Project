library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataMemory is
    generic
    (
        g_bitwidth : integer := 32;
        g_memwidth : integer := 32
    );
    port
    (
        i_reset : in std_logic;
        i_clk : in std_logic;
        i_we : in std_logic;
        i_re : in std_logic;

        i_address : in std_logic_vector(g_memwidth-1 downto 0);
        i_wd : in std_logic_vector(g_bitwidth-1 downto 0);

        o_rd : out std_logic_vector(g_bitwidth-1 downto 0)
    );
end entity dataMemory;

architecture rtl of dataMemory is
    type memory is array(2**g_memwidth-1 downto 0) of std_logic_vector(g_bitwidth-1 downto 0);
    signal ram : memory;
begin

    read : process(all)
    begin
        if (i_re = '1') then
            o_rd <= ram(to_integer(unsigned(i_address)));
        else
            o_rd <= (others => '0');
        end if;
    end process;

    write : process(i_reset, i_clk)
    begin
        if (i_reset = '1') then
            ram(0) <= x"0000001D";
            ram(1) <= x"0000000D";
            for i in 2 to 2**g_memwidth-1 loop
                ram(i) <= (others => '0');
            end loop;
        elsif rising_edge(i_clk) then
            if (i_we = '1') then 
                ram(to_integer(unsigned(i_address))) <= i_wd;
            end if;
        end if;
    end process;

end rtl ; -- rtl