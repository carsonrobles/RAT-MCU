----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2017 10:46:11 AM
-- Design Name: 
-- Module Name: MOVE_CONTROLLA - Behavioral
-- Project Name: 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MOVE_CNTRL is
    Port ( MOVE_OUT  : in  STD_LOGIC_VECTOR (1 downto 0);
           CLR_SIG   : out STD_LOGIC_VECTOR (1 downto 0)); 
end MOVE_CNTRL;

architecture Behavioral of MOVE_CNTRL is

CONSTANT BUTTON_LEFT  : STD_LOGIC_VECTOR (7 downto 0) := X"20";
CONSTANT BUTTON_RIGHT : STD_LOGIC_VECTOR (7 downto 0) := X"21";

signal tmp_clr : std_logic_vector(1 downto 0) := "00";
 
begin

CLR_SIG <= tmp_clr;
input_list: process(MOVE_OUT)
begin

        if (MOVE_OUT = "01") then
            tmp_clr <= "01";
        elsif (MOVE_OUT = "10") then
            tmp_clr <= "10";
        else
            tmp_clr <= "00";
        end if;
end process input_list;

end Behavioral;
