
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 

entity RAT_wrapper is
    Port (
      LEDS      : out   STD_LOGIC_VECTOR (7 downto 0);
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

begin

end Behavioral;
