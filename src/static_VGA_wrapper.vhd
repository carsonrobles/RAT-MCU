----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Gerfen
-- 
-- Create Date: 12/06/2016 10:39:31 AM
-- Design Name: 
-- Module Name: static_VGA_wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 

--This project implements a stand-alone implementation of the VGA module for the Basys3 
--board.  It has this configuration:

--Switches 15, 14, and 13 turn on RED, GREEN, and BLUE respectively.  Coding 000 into the 
--switches will set a pixel to black.  Coding 111 into the switches will create white.

--Switches 12 and 11 are unused.

--Switches 10, 9, 8, 7, 6, and 5 control the column.  Coding 100111 into the switches will 
--put the pixel at column 39.  Coding 000000 into the switches will set the column to 0.

--Switches 4, 3, 2, 1, and 0 control the row.  Coding 11101 into the switches will set the 
--row at 29.  Coding 00000 into the switches will set the row to 0.

--Pressing the center button will activate WE and effectively change a pixel. 

--The divide by 16 clock (100 MHz / 16 = 6.25 MHz) can be observed on pin 2 of the JA PMOD.
--Horizontal Sync can be observed on pin3 of the same connector.  Vertical Sync can be 
--observed on pin4 of the same connector.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity static_VGA_wrapper is
    Port ( CLK_100    : in  STD_LOGIC;
           ROW        : in  STD_LOGIC_VECTOR (4 downto 0);
           COLUMN     : in  STD_LOGIC_VECTOR (5 downto 0);
          -- COLOR_3BIT : in  STD_LOGIC_VECTOR (2 downto 0);
           COLOR_8BIT : in  STD_LOGIC_VECTOR (7 DOWNTO 0);
           W_ENABLE   : in  STD_LOGIC;
           R_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
           G_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
           B_OUT      : out STD_LOGIC_VECTOR (3 downto 0);
           HSYNC      : out STD_LOGIC;
           VSYNC      : out STD_LOGIC;
           CLOCK_debug_out  : out STD_LOGIC;
           HSYNC_debug_out  : out STD_LOGIC;
           VSYNC_debug_out  : out STD_LOGIC);
end static_VGA_wrapper;

architecture Behavioral of static_VGA_wrapper is

   -- signals for clock division to view on inexpensive oscilloscope
   signal CLK_50_sig        : std_logic := '0';
   signal CLK_25_sig        : std_logic := '0';
   signal CLK_12point5_sig  : std_logic := '0';
   signal CLK_6point25_sig  : std_logic := '0';   
   
   signal VGA_RAM_ADDRESS_sig : std_logic_vector(10 downto 0) := "00000000000";
   signal COLOR_8BIT_sig : std_logic_vector(7 downto 0) := "00000000";
   
   signal HSYNC_sig : std_logic := '0';
   signal VSYNC_sig : std_logic := '0';   

   component clk_div2 is
      Port (  clk : in std_logic;
             sclk : out std_logic);
   end component;   

   component vgaDriverBuffer is
      Port ( CLK     : in  std_logic;
             we      : in  std_logic;
             wa      : in  std_logic_vector (10 downto 0);
             wd      : in  std_logic_vector (7 downto 0);
             Rout    : out std_logic_vector(2 downto 0);
             Gout    : out std_logic_vector(2 downto 0);
             Bout    : out std_logic_vector(1 downto 0);
             HS      : out std_logic;
             VS      : out std_logic;
             pixelData : out std_logic_vector(7 downto 0)
);
   end component;
   
begin
   
   -- DRIVE BOTTOM BITS OF BASYS3 VGA
   R_OUT(0) <= '1';
   G_OUT(0) <= '1';
   B_OUT(1) <= '1';
   B_OUT(0) <= '1';
   
   CLOCK_debug_out  <= CLK_6point25_sig;   
   
   VGA_RAM_ADDRESS_sig <= ROW & COLUMN;
   
  -- COLOR_8BIT_sig <= COLOR_3BIT(2) & COLOR_3BIT(2) & COLOR_3BIT(2) &   -- RRR
    --                 COLOR_3BIT(1) & COLOR_3BIT(1) & COLOR_3BIT(1) &   -- GGG
      --               COLOR_3BIT(0) & COLOR_3BIT(0) ;                   --  BB

   COLOR_8BIT_sig <= COLOR_8BIT;
   HSYNC_debug_out <= HSYNC_sig;
   VSYNC_debug_out <= VSYNC_sig;
   HSYNC <= HSYNC_sig;
   VSYNC <= VSYNC_sig;
   
   clk_divider_1 : clk_div2 port map ( clk => CLK_100,
                                       sclk => CLK_50_sig);
                                       
   clk_divider_2 : clk_div2 port map ( clk => CLK_50_sig,
                                      sclk => CLK_25_sig);

   clk_divider_3 : clk_div2 port map ( clk => CLK_25_sig,
                                      sclk => CLK_12point5_sig);
                                      
   clk_divider_4 : clk_div2 port map ( clk => CLK_12point5_sig,
                                      sclk => CLK_6point25_sig);
 
   VGA_module : vgaDriverBuffer port map ( CLK   => CLK_50_sig,
                                           we    => W_ENABLE,
                                           wa    => VGA_RAM_ADDRESS_sig,
                                           wd    => COLOR_8BIT_sig,
                                           Rout  => R_OUT(3 downto 1),
                                           Gout  => G_OUT(3 downto 1),
                                           Bout  => B_OUT(3 downto 2),
                                           HS    => HSYNC_sig,
                                           VS    => VSYNC_sig);

   
end Behavioral;
