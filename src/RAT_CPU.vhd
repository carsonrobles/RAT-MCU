
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RAT_CPU is
    Port ( IN_PORT : in  STD_LOGIC_VECTOR (7 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           INT_IN : in  STD_LOGIC;
           IO_STRB : OUT STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out  STD_LOGIC_VECTOR (7 downto 0));
end RAT_CPU;



architecture Behavioral of RAT_CPU is


    component PCWrapper is
        Port (
            FROM_STACK : in  std_logic_vector (9 downto 0); FROM_IMMED : in  std_logic_vector (9 downto 0);
            MUX_SEL    : in  std_logic_vector (1 downto 0);
            PC_LD      : in  std_logic;
            PC_INC     : in  std_logic;
            rst        : in  std_logic;
            clk        : in  std_logic;

            PC_COUNT   : out std_logic_vector (9 downto 0);
            IR         : out std_logic_vector (17 downto 0)
        );
    end component PCWrapper;

   component ALU
       Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
              B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
              C : out  STD_LOGIC;
              Z : out  STD_LOGIC;
              RES : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

    component control_unit IS
        PORT (
            CLK          : IN STD_LOGIC;

            C_FLAG       : IN STD_LOGIC;
            Z_FLAG       : IN STD_LOGIC;

            INT          : IN STD_LOGIC;
            RESET        : IN STD_LOGIC;

            OPCODE_HI_5  : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            OPCODE_LO_2  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

            RST          : OUT STD_LOGIC;
            PC_LD        : OUT STD_LOGIC;
            PC_INC       : OUT STD_LOGIC;
            PC_MUX_SEL   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

            SP_LD        : OUT STD_LOGIC;
            SP_INCR      : OUT STD_LOGIC;
            SP_DECR      : OUT STD_LOGIC;

            RF_WR        : OUT STD_LOGIC;
            RF_WR_SEL    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

            ALU_OPY_SEL  : OUT STD_LOGIC;
            ALU_SEL      : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

            SCR_WE       : OUT STD_LOGIC;
            SCR_ADDR_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            SCR_DATA_SEL : OUT STD_LOGIC;

            FLAG_LD_SEL  : OUT STD_LOGIC;
            FLAG_SHAD_LD : OUT STD_LOGIC;
            FLAG_C_LD    : OUT STD_LOGIC;
            FLAG_C_SET   : OUT STD_LOGIC;
            FLAG_C_CLR   : OUT STD_LOGIC;
            FLAG_Z_LD    : OUT STD_LOGIC;

            I_SET        : OUT STD_LOGIC;
            I_CLR        : OUT STD_LOGIC;

            IO_STRB      : OUT STD_LOGIC);
    END component control_unit;

   component RegisterFile
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WE     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;

    component ALU_MUX is
        Port ( DY_OUT     : in  STD_LOGIC_VECTOR (7 downto 0);
               FROM_IMMED : in  STD_LOGIC_VECTOR (7 downto 0);
               MUX_SEL    : in  STD_LOGIC;
               Dout       : out STD_LOGIC_VECTOR (7 downto 0));
    end component ALU_MUX;

    component RegFile_MUX is
        Port ( IN_PORT      : in  STD_LOGIC_VECTOR (7 downto 0);
               B            : in  STD_LOGIC_VECTOR (7 downto 0);
               Scratch_DATA : in  STD_LOGIC_VECTOR (7 downto 0);
               ALU_RESULT   : in  STD_LOGIC_VECTOR (7 downto 0);
               MUX_SEL      : in  STD_LOGIC_VECTOR (1 downto 0);
               Dout         : out STD_LOGIC_VECTOR (7 downto 0));
    end component RegFile_MUX;

    component InterruptWrapper is
        Port (
            INT_I   : in  STD_LOGIC; --external interrupt
            I_SET   : in  STD_LOGIC; --allows interrupt signals
            I_CLR   : in  STD_LOGIC; --masks interrupt signals
            CLK     : in  STD_LOGIC; --system clock
            INT_OUT : out STD_LOGIC); --Interrupt output
    end component InterruptWrapper;
    
    component FlagWrapper is
        Port (
            C_IN    : in  STD_LOGIC; --flag input
            Z_IN    : in  STD_LOGIC; --flag input
            C_LD    : in  STD_LOGIC; --load the out_flag with the in_flag value
            Z_LD    : in  STD_LOGIC; --load the out_flag with the in_flag value
            SHAD_LD : in  STD_LOGIC; --load the out_flag with the in_flag value
            LD_SEL  : in  STD_LOGIC; --selects shadow or input as flag input
            C_SET   : in  STD_LOGIC; --set the flag to '1'
            C_CLR   : in  STD_LOGIC; --clear the flag to '0'
            CLK     : in  STD_LOGIC; --system clock
            C_OUT   : out STD_LOGIC := '0'; --flag output
            Z_OUT   : out STD_LOGIC := '0'); --flag output
    end component FlagWrapper;
    
    component StackPointer is
        Port ( 
            RST      : in  STD_LOGIC;
            LD       : in  STD_LOGIC;
            INCR     : in  STD_LOGIC;
            DECR     : in  STD_LOGIC;
            CLK      : in  STD_LOGIC;
            DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
            DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
    end component StackPointer;
    
    component ScratchRam is
        Port ( D_IN   : in     STD_LOGIC_VECTOR (9 downto 0);
               D_OUT  : out    STD_LOGIC_VECTOR (9 downto 0);
               ADDR   : in     STD_LOGIC_VECTOR (7 downto 0);
               WE     : in     STD_LOGIC;
               CLK    : in     STD_LOGIC);
    end component ScratchRam;
    
    component SCR_MUX is
        Port ( DY_OUT     : in  STD_LOGIC_VECTOR (7 downto 0);
               FROM_IMMED : in  STD_LOGIC_VECTOR (7 downto 0);
               SP_DATA    : in  STD_LOGIC_VECTOR (7 downto 0);
               MUX_SEL    : in  STD_LOGIC_VECTOR (1 downto 0);
               ADDR       : out STD_LOGIC_VECTOR (7 downto 0));
    end component SCR_MUX;
    
    component SCR_MUX2 is
        Port ( DX_OUT   : in  STD_LOGIC_VECTOR (7 downto 0);
               PC_COUNT : in  STD_LOGIC_VECTOR (9 downto 0);
               MUX_SEL  : in  STD_LOGIC;
               Dout     : out STD_LOGIC_VECTOR (9 downto 0));
    end component SCR_MUX2;
    
    component MOVE_Wrapper is
        Port ( INT_LEFT    : in  STD_LOGIC; --left interrupt
               INT_RIGHT   : in  STD_LOGIC; --right interrupt
               IO_STROBE   : in  STD_LOGIC; 
               PORT_ID     : in  STD_LOGIC_VECTOR (7 downto 0);
               MOVE_OUT    : in  STD_LOGIC_VECTOR (1 downto 0);
               CLK         : in  STD_LOGIC; --system clock
               MOVE_STATUS : out STD_LOGIC_VECTOR (1 downto 0));
    end component MOVE_Wrapper;

   -- intermediate signals ----------------------------------
   signal s_pc_ld :std_logic := '0';
   signal s_pc_inc: std_logic := '0';
   signal s_pc_mux_sel: std_logic_vector(1 downto 0) := "00";
   signal s_pc_count :std_logic_vector(9 downto 0) := (others => '0');
   signal s_inst_reg : std_logic_vector(17 downto 0) := (others => '0');

   signal s_dx_out : std_logic_vector (7 downto 0) := (others => '0');
   signal s_dy_out : std_logic_vector (7 downto 0) := (others => '0');
   signal s_mux_to_ALU : std_logic_vector (7 downto 0) := (others => '0');
   signal s_alu_res : std_logic_vector (7 downto 0) := (others => '0');
   signal s_alu_sel : std_logic_vector (3 downto 0) := (others => '0');
   signal s_alu_opy_sel : std_logic:='0';

   signal s_rf_wr  : std_logic                     := '0';
   signal s_rf_sel : std_logic_vector (1 downto 0) := (others => '0');
   signal s_rf_din : std_logic_vector (7 downto 0) := (others => '0');

   signal s_cf_in  : std_logic := '0';
   signal s_cf_ld  : std_logic := '0';
   signal s_cf_set : std_logic := '0';
   signal s_cf_clr : std_logic := '0';
   signal s_cf_out : std_logic := '0';

   signal s_zf_in  : std_logic := '0';
   signal s_zf_ld  : std_logic := '0';
   signal s_zf_out : std_logic := '0';
   
   signal s_sh_ld  : std_logic := '0';
   signal s_ld_sel : std_logic := '0';
   
   signal s_if_set : std_logic := '0';
   signal s_if_clr : std_logic := '0';
   signal s_if_out : std_logic := '0';
   
   signal s_sp_ld   : std_logic := '0';
   signal s_sp_incr : std_logic := '0';
   signal s_sp_decr : std_logic := '0';
   signal s_sp_data : std_logic_vector (7 downto 0) := (others => '0');

   signal s_scr_we  : std_logic := '0';
   signal s_scr_data_sel : std_logic := '0';
   signal s_scr_addr_sel : std_logic_vector (1 downto 0) := (others => '0');
   signal s_scr_data     : std_logic_vector (9 downto 0) := (others => '0');
   signal s_scr_addr     : std_logic_vector (7 downto 0) := (others => '0');
   signal s_scr_data_out : std_logic_vector (9 downto 0) := (others => '0');

   signal s_rst : std_logic := '0';
   signal s_int : std_logic := '0';

   -- helpful aliases ------------------------------------------------------------------
   alias s_ir_immed_bits : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3);

begin

    out_port    <= s_dx_out;
    port_id     <= s_inst_reg (7 downto 0);
    s_int       <= INT_IN;


    pc : PCWrapper port map (
        FROM_STACK => s_scr_data_out,          
        FROM_IMMED => s_ir_immed_bits,
        MUX_SEL    => s_pc_mux_sel,
        PC_LD      => s_pc_ld,
        PC_INC     => s_pc_inc,
        rst        => s_rst,
        clk        => clk,
        PC_COUNT   => s_pc_count,
        IR         => s_inst_reg
    );

    mux_rf : RegFile_MUX port map (
            IN_PORT      => IN_PORT,
            B            => s_sp_data, 
            Scratch_DATA => s_scr_data_out(7 downto 0), 
            ALU_RESULT   => s_alu_res,
            MUX_SEL      => s_rf_sel,
            Dout         => s_rf_din
    );

   my_regfile: RegisterFile port map (
        D_IN   => s_rf_din,
        DX_OUT => s_dx_out,
        DY_OUT => s_dy_out,
        ADRX   => s_inst_reg (12 downto 8),
        ADRY   => s_inst_reg ( 7 downto 3),
        WE     => s_rf_wr,
        CLK    => CLK
   );

    mux1 : alu_mux port map (
        DY_OUT     => s_dy_out,
        FROM_IMMED => s_inst_reg (7 downto 0),
        MUX_SEL    => s_ALU_OPY_SEL,
        Dout       => s_mux_to_ALU
    );

    my_alu: ALU port map ( 
        A => s_dx_out,
        B => s_mux_to_ALU,
        Cin => s_cf_out,
        SEL => s_alu_sel,
        C => s_cf_in,
        Z => s_zf_in,
        RES => s_alu_res);
              
    Flags : FlagWrapper port map (
        C_IN    => s_cf_in,
        Z_IN    => s_zf_in,
        C_LD    => s_cf_ld,
        Z_LD    => s_zf_ld,
        SHAD_LD => s_sh_ld,
        LD_SEL  => s_ld_sel,
        C_SET   => s_cf_set,
        C_CLR   => s_cf_clr,
        CLK     => clk,
        C_OUT   => s_cf_out,
        Z_OUT   => s_zf_out);

    interrupt : InterruptWrapper port map (
        INT_I   => s_int,
        I_SET   => s_if_set,
        I_CLR   => s_if_clr,
        clk     => clk,
        INT_OUT => s_if_out
    );

    cu : control_unit port map (
        CLK          => clk,

        C_FLAG       => s_cf_out,
        Z_FLAG       => s_zf_out,

        INT          => s_if_out,
        RESET        => RST,

        OPCODE_HI_5  => s_inst_reg (17 downto 13),
        OPCODE_LO_2  => s_inst_reg ( 1 downto  0),

        RST          => s_rst,
        PC_LD        => s_pc_ld,
        PC_INC       => s_pc_inc,
        PC_MUX_SEL   => s_pc_mux_sel,

        SP_LD        => s_sp_ld,  
        SP_INCR      => s_sp_incr,   
        SP_DECR      => s_sp_decr,   

        RF_WR        => s_rf_wr,
        RF_WR_SEL    => s_rf_sel,

        ALU_OPY_SEL  => s_alu_opy_sel,
        ALU_SEL      => s_alu_sel,

        SCR_WE       => s_scr_we,
        SCR_ADDR_SEL => s_scr_addr_sel,
        SCR_DATA_SEL => s_scr_data_sel,

        FLAG_LD_SEL  => s_ld_sel,       
        FLAG_SHAD_LD => s_sh_ld,       
        FLAG_C_LD    => s_cf_ld,
        FLAG_C_SET   => s_cf_set,
        FLAG_C_CLR   => s_cf_clr,
        FLAG_Z_LD    => s_zf_ld,

        I_SET        => s_if_set,       
        I_CLR        => s_if_clr,      

        IO_STRB      => IO_STRB
    );
    
    SP : StackPointer port map (
        RST      => s_rst,          
        LD       => s_sp_ld,
        INCR     => s_sp_incr,
        DECR     => s_sp_decr,
        CLK      => clk,
        DATA_IN  => s_dx_out,
        DATA_OUT => s_sp_data
    );
        
    SCRMUX1 : SCR_MUX port map (
        DY_OUT     => s_dy_out,          
        FROM_IMMED => s_inst_reg(7 downto 0),
        SP_DATA    => s_sp_data,
        MUX_SEL    => s_scr_addr_sel,
        ADDR       => s_scr_addr
    );
            
    SCRMUX2 : SCR_MUX2 port map (
        DX_OUT   => s_dx_out,         
        PC_COUNT => s_pc_count,
        MUX_SEL  => s_scr_data_sel,
        Dout     => s_scr_data
    );
                
    SCR : ScratchRam port map (
        D_IN => s_scr_data,         
        D_OUT => s_scr_data_out,
        ADDR    => s_scr_addr,
        WE      => s_scr_we,
        CLK     => clk
    );

end Behavioral;

