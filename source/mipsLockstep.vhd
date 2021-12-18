library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mipsLib;
use mipsLib.all;

entity mipsLockstep is
    generic
    (
        g_bitwidth        : integer := mips_types.c_bitwidth;
        g_memwidth        : integer := mips_types.c_memwidth;
        g_regwidth        : integer := mips_types.c_regwidth;
        g_tmrEnable       : integer := mips_types.c_tmrEnable;
        g_numLockstepCPUs : integer := mips_types.c_numLockstepCPUs;
        g_tmr_fault       : integer := 0;
        g_lockstep_fault  : integer := 0
    );
    port
    (
        i_clk   : in std_logic;
        i_reset : in std_logic;

        o_lockstep_reset : out std_logic
    );
end entity mipsLockstep;

architecture rtl of mipsLockstep is

    type lockstep_PC_t        is array(g_numLockstepCPUs-1 downto 0) of unsigned(31 downto 0);
    type lockstep_regDst_t    is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_branch_t    is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_memRead_t   is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_memToReg_t  is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_ALUop_t     is array(g_numLockstepCPUs-1 downto 0) of std_logic_vector(3 downto 0);
    type lockstep_memWrite_t  is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_ALUSrc_t    is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_regWrite_t  is array(g_numLockstepCPUs-1 downto 0) of std_logic;
    type lockstep_alu_in1_t   is array(g_numLockstepCPUs-1 downto 0) of std_logic_vector(g_bitwidth-1 downto 0);
    type lockstep_alu_in2_t   is array(g_numLockstepCPUs-1 downto 0) of std_logic_vector(g_bitwidth-1 downto 0);
    type lockstep_alu_out_t   is array(g_numLockstepCPUs-1 downto 0) of std_logic_vector(g_bitwidth-1 downto 0);
    type lockstep_alu_zero_t  is array(g_numLockstepCPUs-1 downto 0) of std_logic;

    signal lockstep_PC       : lockstep_PC_t;
    signal lockstep_regDst   : lockstep_regDst_t;
    signal lockstep_branch   : lockstep_branch_t;
    signal lockstep_memRead  : lockstep_memRead_t;
    signal lockstep_memToReg : lockstep_memToReg_t;
    signal lockstep_ALUop    : lockstep_ALUop_t;
    signal lockstep_memWrite : lockstep_memWrite_t;
    signal lockstep_ALUSrc   : lockstep_ALUSrc_t;
    signal lockstep_regWrite : lockstep_regWrite_t;
    signal lockstep_alu_in1  : lockstep_alu_in1_t;
    signal lockstep_alu_in2  : lockstep_alu_in2_t;
    signal lockstep_alu_out  : lockstep_alu_out_t;
    signal lockstep_alu_zero : lockstep_alu_zero_t;

    signal PC_out_of_step       : std_logic;
    signal regDst_out_of_step   : std_logic;
    signal branch_out_of_step   : std_logic;
    signal memRead_out_of_step  : std_logic;
    signal memToReg_out_of_step : std_logic;
    signal ALUop_out_of_step    : std_logic;
    signal memWrite_out_of_step : std_logic;
    signal ALUSrc_out_of_step   : std_logic;
    signal regWrite_out_of_step : std_logic;
    signal alu_in1_out_of_step  : std_logic;
    signal alu_in2_out_of_step  : std_logic;
    signal alu_out_out_of_step  : std_logic;
    signal alu_zero_out_of_step : std_logic;

    signal out_of_step          : std_logic;
    signal reset                : std_logic;
begin

    mipsEnt0 : entity mipsLib.mips
    generic map(
        g_bitwidth       => g_bitwidth,
        g_memwidth       => g_memwidth,
        g_regwidth       => g_regwidth,
        g_tmrEnable      => g_tmrEnable,
        g_tmr_fault      => g_tmr_fault,
        g_lockstep_fault => g_lockstep_fault
    )
    port map(
        i_clk   => i_clk,
        i_reset => reset,

        -- Subset of signals checked by top level lockstep controller
        o_lockstep_PC    => lockstep_PC(0),
        
        o_lockstep_regDst   => lockstep_regDst(0),
        o_lockstep_branch   => lockstep_branch(0),
        o_lockstep_memRead  => lockstep_memRead(0),
        o_lockstep_memToReg => lockstep_memToReg(0),
        o_lockstep_ALUop    => lockstep_ALUop(0),
        o_lockstep_memWrite => lockstep_memWrite(0),
        o_lockstep_ALUSrc   => lockstep_ALUSrc(0),
        o_lockstep_regWrite => lockstep_regWrite(0),

        o_lockstep_alu_in1  => lockstep_alu_in1(0),
        o_lockstep_alu_in2  => lockstep_alu_in2(0),
        o_lockstep_alu_out  => lockstep_alu_out(0),
        o_lockstep_alu_zero => lockstep_alu_zero(0)
    );

    mipsEnt1 : entity mipsLib.mips
    generic map(
        g_bitwidth       => g_bitwidth,
        g_memwidth       => g_memwidth,
        g_regwidth       => g_regwidth,
        g_tmrEnable      => g_tmrEnable
    )
    port map(
        i_clk   => i_clk,
        i_reset => reset,

        -- Subset of signals checked by top level lockstep controller
        o_lockstep_PC    => lockstep_PC(1),
        
        o_lockstep_regDst   => lockstep_regDst(1),
        o_lockstep_branch   => lockstep_branch(1),
        o_lockstep_memRead  => lockstep_memRead(1),
        o_lockstep_memToReg => lockstep_memToReg(1),
        o_lockstep_ALUop    => lockstep_ALUop(1),
        o_lockstep_memWrite => lockstep_memWrite(1),
        o_lockstep_ALUSrc   => lockstep_ALUSrc(1),
        o_lockstep_regWrite => lockstep_regWrite(1),

        o_lockstep_alu_in1  => lockstep_alu_in1(1),
        o_lockstep_alu_in2  => lockstep_alu_in2(1),
        o_lockstep_alu_out  => lockstep_alu_out(1),
        o_lockstep_alu_zero => lockstep_alu_zero(1)
    );

    process (i_clk) is
    begin
        if rising_edge(i_clk) then
            if lockstep_PC(0) = lockstep_PC(1) then
                PC_out_of_step <= '0';
            else
                PC_out_of_step <= '1';
            end if;

            if lockstep_regDst(0) = lockstep_regDst(1) then
                regDst_out_of_step <= '0';
            else
                regDst_out_of_step <= '1';
            end if;

            if lockstep_branch(0) = lockstep_branch(1) then
                branch_out_of_step <= '0';
            else
                branch_out_of_step <= '1';
            end if;

            if lockstep_memRead(0) = lockstep_memRead(1) then
                memRead_out_of_step <= '0';
            else
                memRead_out_of_step <= '1';
            end if;

            if lockstep_memToReg(0) = lockstep_memToReg(1) then
                memToReg_out_of_step <= '0';
            else
                memToReg_out_of_step <= '1';
            end if;

            if lockstep_ALUop(0) = lockstep_ALUop(1) then
                ALUop_out_of_step <= '0';
            else
                ALUop_out_of_step <= '1';
            end if;

            if lockstep_memWrite(0) = lockstep_memWrite(1) then
                memWrite_out_of_step <= '0';
            else
                memWrite_out_of_step <= '1';
            end if;

            if lockstep_ALUSrc(0) = lockstep_ALUSrc(1) then
                ALUSrc_out_of_step <= '0';
            else
                ALUSrc_out_of_step <= '1';
            end if;

            if lockstep_regWrite(0) = lockstep_regWrite(1) then
                regWrite_out_of_step <= '0';
            else
                regWrite_out_of_step <= '1';
            end if;

            if lockstep_alu_in1(0) = lockstep_alu_in1(1) then
                alu_in1_out_of_step <= '0';
            else
                alu_in1_out_of_step <= '1';
            end if;

            if lockstep_alu_in2(0) = lockstep_alu_in2(1) then
                alu_in2_out_of_step <= '0';
            else
                alu_in2_out_of_step <= '1';
            end if;

            if lockstep_alu_out(0) = lockstep_alu_out(1) then
                alu_out_out_of_step <= '0';
            else
                alu_out_out_of_step <= '1';
            end if;

            if lockstep_alu_zero(0) = lockstep_alu_zero(1) then
                alu_zero_out_of_step <= '0';
            else
                alu_zero_out_of_step <= '1';
            end if;

        end if;
    end process;

    out_of_step <= PC_out_of_step or
                    regDst_out_of_step or
                    branch_out_of_step or
                    memRead_out_of_step or
                    memToReg_out_of_step or
                    ALUop_out_of_step or
                    memWrite_out_of_step or
                    ALUSrc_out_of_step or
                    regWrite_out_of_step or
                    alu_in1_out_of_step or
                    alu_in2_out_of_step or
                    alu_out_out_of_step or
                    alu_zero_out_of_step;

    process (i_reset, out_of_step) is
    begin
        if i_reset = '1' then
            reset <= '1';
            o_lockstep_reset <= '0';
        else
            reset <= out_of_step;
            o_lockstep_reset <= out_of_step;
        end if;
    end process;

end rtl ; -- rtl
