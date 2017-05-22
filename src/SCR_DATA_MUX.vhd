----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2017 11:27:46 AM
-- Design Name: 
-- Module Name: PC_MUX - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SCR_MUX2 is
    Port ( DX_OUT   : in  STD_LOGIC_VECTOR (7 downto 0);
           PC_COUNT : in  STD_LOGIC_VECTOR (9 downto 0);
           MUX_SEL  : in  STD_LOGIC;
           Dout     : out STD_LOGIC_VECTOR (9 downto 0));
end SCR_MUX2;

architecture Behavioral of SCR_MUX2 is

begin

    with MUX_SEL select
        Dout <= "00" & DX_OUT   when '0',
                PC_COUNT        when '1',
                (others => '0') when others;

end Behavioral;
