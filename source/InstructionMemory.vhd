library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructionMemory is
    generic
    (
        g_bitwidth : integer := 32;
        g_memwidth : integer := 32
    );
    port
    (
        i_reset : in std_logic;

        i_address : in unsigned(g_memwidth-1 downto 0);
        o_instruction : out std_logic_vector(g_bitwidth-1 downto 0)
    );
end entity instructionMemory;

architecture rtl of instructionMemory is
    type memory is array(2**g_memwidth-1 downto 0) of std_logic_vector(g_bitwidth-1 downto 0);
    signal mem : memory;
begin

    read : process(all)
    begin
        if i_reset = '1' then
            -- load memory
            mem(0) <= b"100011_00000_00000_0000000000000000";   -- Load 0x00 to R0
            mem(1) <= b"100011_00000_00001_0000000000000001";   -- Load 0x04 to R1
            mem(2) <= b"000000_00000_00001_00010_00000_100100"; -- R2 = R0&R1
            mem(3) <= b"000000_00000_00001_00011_00000_100101"; -- R3 = R0|R1
            mem(4) <= b"000000_00000_00001_00100_00000_100110"; -- R4 = R0^R1
            mem(5) <= b"000000_00000_00001_00101_00000_100000"; -- R5 = R0+R1
            mem(6) <= b"000000_00000_00001_00110_00000_100010"; -- R6 = R0-R1
            mem(7) <= b"000000_00000_00001_00111_00000_011000"; -- R7 = R0*R1
            for i in 8 to 2**g_memwidth-1 loop
                mem(i) <= (others => '0');
            end loop;
        else
            o_instruction <= mem(to_integer(i_address));
        end if;
    end process;

end rtl ; -- rtl