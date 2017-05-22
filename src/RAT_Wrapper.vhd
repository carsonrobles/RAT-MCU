----------------------------------------------------------------------------------
-- Company:  RAT Technologies (a subdivision of Cal Poly CENG)
-- Engineer:  Various RAT rats
--
-- Create Date:    02/03/2017
-- Module Name:    RAT_wrapper - Behavioral
-- Target Devices:  Basys3
-- Description: Wrapper for RAT CPU. This model provides a template to interfaces
--    the RAT CPU to the Basys3 development board.  --
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
entity RAT_wrapper is
    Port ( LEDS      : out   STD_LOGIC_VECTOR (7 downto 0);
           SWITCHES  : in    STD_LOGIC_VECTOR (7 downto 0);
           RST       : in    STD_LOGIC;
           CLK       : in    STD_LOGIC;
           INT_LEFT  : in    STD_LOGIC;
           INT_RIGHT : in    STD_LOGIC;
           ANODE     : out   std_logic_vector (3 downto 0);
           SEV_SEG   : out   std_logic_vector (7 downto 0);
           vgaRed    : out   std_logic_vector (3 downto 0);
           vgaBlue   : out   std_logic_vector (3 downto 0);
           vgaGreen  : out   std_logic_vector (3 downto 0);
           Hsync     : out   std_logic;
           Vsync     : out   std_logic
    );
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"40";
   -------------------------------------------------------------------------------

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_CPU
       Port ( IN_PORT   : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT  : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID   : out STD_LOGIC_VECTOR (7 downto 0);
              RST       : in  STD_LOGIC;
              IO_STRB   : out STD_LOGIC;
              INT_IN  : in STD_LOGIC;
              CLK       : in  STD_LOGIC);
   end component RAT_CPU;
   -------------------------------------------------------------------------------
  component clk_div2 is
      Port ( CLK     : in  STD_LOGIC;
            sclk : out STD_LOGIC);
  end component clk_div2;

    component lfsr_rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (5 downto 0)
    );
    end component lfsr_rand;

    component sseg_dec_uni is
        Port (       COUNT1 : in std_logic_vector(13 downto 0); 
                    COUNT2 : in std_logic_vector(7 downto 0);
                        SEL : in std_logic_vector(1 downto 0);
						    dp_oe : in std_logic;
                        dp : in std_logic_vector(1 downto 0); 					  
                        CLK : in std_logic;
						    SIGN : in std_logic;
						    VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                SEGMENTS : out std_logic_vector(7 downto 0));
    end component sseg_dec_uni;
   
   -- Declare Debounce -----------------------------------------------------------
   component db_1shot_FSM is
       Port ( A    : in STD_LOGIC;
              CLK  : in STD_LOGIC;
              A_DB : out STD_LOGIC);
   end component db_1shot_FSM;
   --------------------------------------------------------------------------------
   
   component MOVE_Wrapper is
       Port ( INT_LEFT    : in  STD_LOGIC; --left interrupt
              INT_RIGHT   : in  STD_LOGIC; --right interrupt
              MOVE_OUT    : in  STD_LOGIC_VECTOR (1 downto 0);
              MOVE_STATUS : out STD_LOGIC_VECTOR (1 downto 0);
              CLK         : in  STD_LOGIC);
   end component MOVE_Wrapper;

    component static_VGA_wrapper is
        Port (  CLK_100    : in  STD_LOGIC;
                ROW        : in  STD_LOGIC_VECTOR (4 downto 0);
                COLUMN     : in  STD_LOGIC_VECTOR (5 downto 0);
                COLOR_8BIT : in  STD_LOGIC_VECTOR (7 downto 0);
                W_ENABLE   : in  STD_LOGIC;
                R_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
                G_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
                B_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
                HSYNC      : out STD_LOGIC;
                VSYNC      : out STD_LOGIC;
                CLOCK_debug_out  : out STD_LOGIC;
                HSYNC_debug_out  : out STD_LOGIC;
                VSYNC_debug_out  : out STD_LOGIC);
    end component static_VGA_wrapper;

   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port      : std_logic_vector (7 downto 0);
   signal s_interrupt       : std_logic;
   signal s_reset           : std_logic;
   signal s_output_port     : std_logic_vector (7 downto 0);
   signal s_port_id         : std_logic_vector (7 downto 0);
   signal s_load            : std_logic;
   
   signal s_interrupt_left    : std_logic;
   signal s_interrupt_right   : std_logic;

   
   -- Register definitions for output devices ------------------------------------
   -- add signals for any added outputs
   signal r_LEDS        : std_logic_vector (7 downto 0);
   -------------------------------------------------------------------------------

   -- sseg
   CONSTANT cnt1_l_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"41";
   CONSTANT cnt1_u_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"42";
   signal   s_cnt1_u        : std_logic_vector (5 downto 0) := (others => '0');
   signal   s_cnt1_l        : std_logic_vector (7 downto 0) := (others => '0');
   signal   s_cnt1          : std_logic_vector (13 downto 0);

    -- vga
    CONSTANT VGA_COL       : STD_LOGIC_VECTOR (7 downto 0) := X"43";
    CONSTANT VGA_ROW       : STD_LOGIC_VECTOR (7 downto 0) := X"44";
    CONSTANT VGA_CLR       : STD_LOGIC_VECTOR (7 downto 0) := X"45";
    CONSTANT VGA_WE        : STD_LOGIC_VECTOR (7 downto 0) := X"46";
    signal s_row : std_logic_vector (4 downto 0) := (others => '0');
    signal s_col : std_logic_vector (5 downto 0) := (others => '0');
    signal s_colr : std_logic_vector (7 downto 0);
    signal s_we   : std_logic;
    signal clk_db_out : std_logic;
    signal hs_db_out : std_logic;
    signal vs_db_out : std_logic;
    
    signal sclk : std_logic := '0';
    
    CONSTANT LFSR_ID : STD_LOGIC_VECTOR (7 downto 0) := X"21";
    signal lfsr_o : std_logic_vector (5 downto 0);
    
    CONSTANT MOVE_ID : STD_LOGIC_VECTOR (7 downto 0) := X"47";
    signal s_move_st : std_logic_vector (1 downto 0) := "00";
    signal s_move_lr : std_logic_vector (1 downto 0) := "00";
    CONSTANT MOVE_OUT_ID : STD_LOGIC_VECTOR (7 downto 0) := X"48";
begin

  clk_div : clk_div2 port map (
      clk  => clk,
      sclk => sclk
    );

    s_interrupt <= s_interrupt_left or s_interrupt_right;

   -- Instantiate RAT_CPU --------------------------------------------------------
   CPU: RAT_CPU
   port map(  IN_PORT   => s_input_port,
              OUT_PORT  => s_output_port,
              PORT_ID   => s_port_id,
              RST       => RST,
              IO_STRB   => s_load,
              INT_IN => s_interrupt,
              CLK       => SCLK);
   -------------------------------------------------------------------------------

    --- RAND ---
    rand : lfsr_rand port map (
        clk => clk,
        num => lfsr_o
    );

    --- VGA ---
    VGA : static_vga_wrapper port map (
        clk_100    => clk,
        row        => s_row,
        column     => s_col,
        color_8bit => s_colr,
        w_enable   => s_we,
        r_out      => vgaRed,
        g_out      => vgaBlue,
        b_out      => vgaGreen,
        hsync      => hsync,
        vsync      => vsync,
        clock_debug_out => clk_db_out,
        hsync_debug_out => hs_db_out,
        vsync_debug_out => vs_db_out
    );

   -- Instantiate Debounce ------------------------------------------------------
   DB_left : db_1shot_FSM
   port map ( A    => INT_LEFT,
              CLK  => SCLK,
              A_DB => s_interrupt_left);
   ------------------------------------------------------------------------------
       
   -- Instantiate Debounce ------------------------------------------------------
   DB_right : db_1shot_FSM
   port map ( A    => INT_RIGHT,
              CLK  => SCLK,
              A_DB => s_interrupt_right);
   ------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- MUX for selecting what input to read ---------------------------------------
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, switches, lfsr_o, s_move_st)
   begin
      if (s_port_id = SWITCHES_ID) then
         s_input_port <= switches;
      elsif (s_port_id = LFSR_ID) then
         s_input_port <= "00" & lfsr_o;
      elsif (s_port_id = MOVE_ID) then
         s_input_port <= "000000" & s_move_st;
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   outputs: process(CLK)
   begin
      if (rising_edge(CLK)) then
         if (s_load = '1') then
            -- the register definition for the LEDS
            if (s_port_id = LEDS_ID) then
               r_LEDS <= s_output_port;
            elsif (s_port_id = CNT1_L_ID) then
                s_cnt1_l <= s_output_port;
            elsif (s_port_id = CNT1_U_ID) then
                s_cnt1_u <= s_output_port(5 downto 0);
            elsif (s_port_id = VGA_COL) then
                s_col <= s_output_port(5 downto 0);
            elsif (s_port_id = VGA_ROW) then
                s_row <= s_output_port(4 downto 0);
            elsif (s_port_id = VGA_CLR) then
                s_colr <= s_output_port;
            elsif (s_port_id = VGA_WE) then
                s_we <= s_output_port(0);
            elsif (s_port_id = MOVE_OUT_ID) then
                s_move_lr <= s_output_port(1 downto 0);
            end if;
           
         end if;
      end if; end process outputs;
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   -- add all outputs that you added to this design

    s_cnt1 <= s_cnt1_u & s_cnt1_l;
--s_cnt1 <= "00000000" & s_col;
    leds <= r_leds;
    
    -- SSEG
    sseg: sseg_dec_uni port map (
        count1   => s_cnt1,
        count2   => "00000000",
        sel      => "00",
        dp_oe    => '0',
        dp       => "00",
        clk      => clk,
        sign     => '0',
        valid    => '1',
        disp_en  => anode,
        segments => sev_seg
    );
    
    MW : MOVE_Wrapper port map (
        int_left    => s_interrupt_left,
        int_right   => s_interrupt_right,
        MOVE_OUT    => s_move_lr,
        MOVE_STATUS => s_move_st,
        CLK         => SCLK
    );

end Behavioral;
