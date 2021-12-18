library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mips_types is
    constant c_bitwidth        : integer := 32;
    constant c_memwidth        : integer := 8;
    constant c_regwidth        : integer := 5;
    constant c_tmrEnable       : integer := 1;
    constant c_numLockstepCPUs : integer := 2;

    constant c_redundancy     : integer := 3;
    
    subtype reg_t is std_logic_vector(c_bitwidth-1 downto 0);
    type registerFileRegs is array(2**c_regwidth-1 downto 0) of reg_t;

    type tmr_alu_out_t is array (c_redundancy-1 downto 0) of std_logic_vector(c_bitwidth-1 downto 0);
    type tmr_alu_zero_t is array (c_redundancy-1 downto 0) of std_logic;
    
end package mips_types;