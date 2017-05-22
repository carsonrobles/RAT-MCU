----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2017 10:46:53 AM
-- Design Name: FLIPPIDY_FLOPPIDY
-- Module Name: FLIP_FLOP - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

entity FLIP_FLOP is
    Port ( SET : in  STD_LOGIC; --set the flag to '1'
           CLR : in  STD_LOGIC; --clear the flag to '0'
           Q   : out STD_LOGIC;
           CLK : in STD_LOGIC); 
end FLIP_FLOP;

architecture Behavioral of FLIP_FLOP is
signal q_temp : std_logic := '0';
begin
Q <= q_temp;
proc1 : process(SET, CLR, CLK)
begin
if (rising_edge(CLK)) then
    if (SET = '1') then
        q_temp <= '1';
    elsif (CLR = '1') then 
        q_temp <= '0';
    else
        q_temp <= q_temp;
    end if;
end if;
end process proc1;

end Behavioral;
