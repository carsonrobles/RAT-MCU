----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/23/2017 10:22:35 AM
-- Design Name: 
-- Module Name: scratch_ram - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScratchRam is
    Port ( D_IN   : in     STD_LOGIC_VECTOR (9 downto 0);
           D_OUT  : out    STD_LOGIC_VECTOR (9 downto 0);
           ADDR   : in     STD_LOGIC_VECTOR (7 downto 0);
           WE     : in     STD_LOGIC;
           CLK    : in     STD_LOGIC);
end ScratchRam;

architecture Behavioral of ScratchRam is
	TYPE memory is array (0 to 255) of std_logic_vector(9 downto 0);
	SIGNAL REG: memory := (others =>(others => '0'));
begin

	process(clk)
	begin
		if (rising_edge(clk)) then
	          if (WE = '1') then
			REG(conv_integer(ADDR)) <= D_IN;
		  end if;
		end if;
	end process;

	D_OUT <= REG(conv_integer(ADDR));
	
end Behavioral;