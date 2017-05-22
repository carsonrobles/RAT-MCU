----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2017 11:43:43 AM
-- Design Name: 
-- Module Name: FlagMux - Behavioral
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

entity FlagMux is
    Port ( INPUT  : in  STD_LOGIC; --flag input from ALU
           SHADOW : in  STD_LOGIC; --flag input from shadow
           SEL    : in  STD_LOGIC := '0'; --chooses which flag input to load
           F_IN   : out STD_LOGIC := '0'); --flag input being loaded
end FlagMux;

architecture Behavioral of FlagMux is

begin

with SEL select
    F_IN <= INPUT  when '0',
            SHADOW when '1',
            '0'    when others;

end Behavioral;
