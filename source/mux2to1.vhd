library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2to1 is
    generic
    (
        g_bitwidth : integer := 1
    );
    port
    (
        i1 : in std_logic_vector(g_bitwidth-1 downto 0);
        i2 : in std_logic_vector(g_bitwidth-1 downto 0);
        s : in std_logic;
        o : out std_logic_vector(g_bitwidth-1 downto 0)
    );
end entity mux2to1;

architecture rtl of mux2to1 is

begin

    mux : process (all) is
    begin
        if (s = '0') then
            o <= i1;
        else
            o <= i2;
        end if;
    end process mux;

end rtl ; -- rtl
