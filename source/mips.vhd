library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mipsLib;
use mipsLib.all;

entity mips is
    generic
    (
        g_bitwidth       : integer := 32;
        g_memwidth       : integer := 8;
        g_regwidth       : integer := 5;
        g_tmrEnable      : integer := 1;
        g_tmr_fault      : integer := 0;
        g_lockstep_fault : integer := 0
    );
    port
    (
        i_clk   : in std_logic;
        i_reset : in std_logic;

        -- Subset of signals checked by top level lockstep controller
        o_lockstep_PC    : out unsigned(31 downto 0);
        
        o_lockstep_regDst   : out std_logic;
        o_lockstep_branch   : out std_logic;
        o_lockstep_memRead  : out std_logic;
        o_lockstep_memToReg : out std_logic;
        o_lockstep_ALUop    : out std_logic_vector(3 downto 0);
        o_lockstep_memWrite : out std_logic;
        o_lockstep_ALUSrc   : out std_logic;
        o_lockstep_regWrite : out std_logic;

        o_lockstep_alu_in1  : out std_logic_vector(g_bitwidth-1 downto 0);
        o_lockstep_alu_in2  : out std_logic_vector(g_bitwidth-1 downto 0);
        o_lockstep_alu_out  : out std_logic_vector(g_bitwidth-1 downto 0);
        o_lockstep_alu_zero : out std_logic
        
    );
end entity mips;

architecture rtl of mips is
    signal PC     : unsigned(31 downto 0);
    signal PCnext : std_logic_vector(31 downto 0);
    signal PCSrc  : std_logic;

    signal instruction : std_logic_vector(31 downto 0);
    signal opcode      : std_logic_vector(5 downto 0);
    signal rs          : std_logic_vector(4 downto 0);
    signal rt          : std_logic_vector(4 downto 0);
    signal rd          : std_logic_vector(4 downto 0);
    signal shamt       : std_logic_vector(4 downto 0);
    signal funct       : std_logic_vector(5 downto 0);
    signal immediate   : std_logic_vector(15 downto 0);
    signal address     : std_logic_vector(25 downto 0);
    
    signal signExtendImmediate : std_logic_vector(g_bitwidth-1 downto 0);

    signal regDst   : std_logic;
    signal branch   : std_logic;
    signal memRead  : std_logic;
    signal memToReg : std_logic;
    signal ALUop    : std_logic_vector(3 downto 0);
    signal memWrite : std_logic;
    signal ALUSrc   : std_logic;
    signal regWrite : std_logic;

    signal rf_rr1 : std_logic_vector(g_regwidth-1 downto 0);
    signal rf_rr2 : std_logic_vector(g_regwidth-1 downto 0);
    signal rf_we  : std_logic;
    signal rf_wr  : std_logic_vector(g_regwidth-1 downto 0);
    signal rf_wd  : std_logic_vector(g_bitwidth-1 downto 0);
    signal rf_rd1 : std_logic_vector(g_bitwidth-1 downto 0);
    signal rf_rd2 : std_logic_vector(g_bitwidth-1 downto 0);

    signal alu_in1  : std_logic_vector(g_bitwidth-1 downto 0);
    signal alu_in2  : std_logic_vector(g_bitwidth-1 downto 0);
    signal alu_out  : std_logic_vector(g_bitwidth-1 downto 0);
    signal alu_zero : std_logic;

    signal dm_we      : std_logic;
    signal dm_re      : std_logic;
    signal dm_address : std_logic_vector(g_memwidth-1 downto 0);
    signal dm_wd      : std_logic_vector(g_bitwidth-1 downto 0);
    signal dm_rd      : std_logic_vector(g_bitwidth-1 downto 0);

begin
    -- Program Counter
    pcSrcMux : entity mipsLib.mux2to1
    generic map(
        g_bitwidth => g_bitwidth
    )
    port map(
        i1 => std_logic_vector(resize(PC + 1, g_bitwidth)),
        i2 => std_logic_vector(PC + unsigned(signExtendImmediate)),
        s  => PCSrc,
        o  => PCnext
    );

    program_counter : process(i_clk, i_reset) is
    begin
        if (i_reset = '1') then
            PC <= (others => '0');
        elsif rising_edge(i_clk) then
            PC <= unsigned(PCnext);
        end if;
    end process;

    -- Instruction Memory
    IM : entity mipsLib.instructionMemory
    generic map(
        g_bitwidth => g_bitwidth,
        g_memwidth => g_memwidth
    )
    port map(
        i_reset => i_reset,

        i_address     => PC(g_memwidth-1 downto 0),
        o_instruction => instruction
    );

    -- Instruction Decode
    opcode    <= instruction(31 downto 26);
    rs        <= instruction(25 downto 21);
    rt        <= instruction(20 downto 16);
    rd        <= instruction(15 downto 11);
    shamt     <= instruction(10 downto 6);
    funct     <= instruction(5 downto 0);
    immediate <= instruction(15 downto 0);
    address   <= instruction(25 downto 0);

    signExtendImmediate <= std_logic_vector(resize(signed(immediate), g_bitwidth));

    -- Control
    CU : entity mipsLib.control_unit
    generic map(
        g_lockstep_fault => g_lockstep_fault
    )
    port map(
        i_reset  => i_reset,
        i_opcode => opcode,
        i_funct  => funct,
        
        o_regDst   => regDst,
        o_branch   => branch,
        o_memRead  => memRead,
        o_memToReg => memToReg,
        o_ALUop    => ALUop,
        o_memWrite => memWrite,
        o_ALUSrc   => ALUSrc,
        o_regWrite => regWrite
    ); 
    
    -- Register File
    rf_rr1 <= rs;
    rf_rr2 <= rt;
    rf_we  <= regWrite;

    rfWriteAddrMux : entity mipsLib.mux2to1
    generic map(
        g_bitwidth => g_regwidth
    )
    port map(
        i1 => rt,
        i2 => rd,
        s  => regDst,
        o  => rf_wr
    );

    RF : entity mipsLib.registerFile
    generic map(
        g_bitwidth => g_bitwidth,
        g_regwidth => g_regwidth
    )
    port map(
        i_reset => i_reset,
        i_clk   => i_clk,
        i_rr1   => rf_rr1,
        i_rr2   => rf_rr2,
        i_we    => rf_we,
        i_wr    => rf_wr,
        i_wd    => rf_wd,
        o_rd1   => rf_rd1,
        o_rd2   => rf_rd2
    );

    -- ALU
    aluSrcMux : entity mipsLib.mux2to1
    generic map(
        g_bitwidth => g_bitwidth
    )
    port map(
        i1 => rf_rd2,
        i2 => signExtendImmediate,
        s  => ALUSrc,
        o  => alu_in2
    );
    
    tmrSel : if g_tmrEnable = 0 generate
        aluEnt : entity mipsLib.ALU
        generic map(
            g_bitwidth => g_bitwidth,
            g_fault    => g_tmr_fault
        )
        port map(
            i_ALUOp => ALUop,
            i_in1    => alu_in1,
            i_in2    => alu_in2,
            o_out   => alu_out,
            o_zero  => alu_zero
        );
    else generate
        aluEnt : entity mipsLib.tmrALU
        generic map(
            g_bitwidth => g_bitwidth,
            g_fault    => g_tmr_fault
        )
        port map(
            i_ALUOp => ALUop,
            i_in1    => alu_in1,
            i_in2    => alu_in2,
            o_out   => alu_out,
            o_zero  => alu_zero
        );
    end generate;

    -- Data Memory
    dm_we <= memWrite;
    dm_re <= memRead;
    dm_address <= alu_out(7 downto 0);
    dm_wd <= rf_rd2;

    DM : entity mipsLib.dataMemory
    generic map(
        g_bitwidth => g_bitwidth,
        g_memwidth => g_memwidth
    )
    port map(
        i_reset => i_reset,
        i_clk   => i_clk,

        i_we => dm_we,
        i_re => dm_re,

        i_address => dm_address,
        i_wd      => dm_wd,

        o_rd => dm_rd
    );

    rfWriteDataMux : entity mipsLib.mux2to1
    generic map(
        g_bitwidth => g_bitwidth
    )
    port map(
        i1 => alu_out,
        i2 => dm_rd,
        s  => memToReg,
        o  => rf_wd
    );

    -- Other Assignments
    alu_in1 <= rf_rd1;
    PCSrc <= branch and alu_zero;

    -- Lockstep Signals
    o_lockstep_PC       <= PC;
    
    o_lockstep_regDst   <= regDst;
    o_lockstep_branch   <= branch;
    o_lockstep_memRead  <= memRead;
    o_lockstep_memToReg <= memToReg;
    o_lockstep_ALUop    <= ALUop;
    o_lockstep_memWrite <= memWrite;
    o_lockstep_ALUSrc   <= ALUSrc;
    o_lockstep_regWrite <= regWrite;

    o_lockstep_alu_in1  <= alu_in1;
    o_lockstep_alu_in2  <= alu_in2;
    o_lockstep_alu_out  <= alu_out;
    o_lockstep_alu_zero <= alu_zero;
end rtl ; -- rtl
