----------------------------------------------------------------------------------
--
-- Engineer: Carson Robles, Jacob Butler
-- 
-- Create Date: 01/11/2017 11:27:46 AM
-- Module Name: PC_MUX - Behavioral
-- Description: Multiplexor to select data input for load line of PC
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_MUX is
    Port ( FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
           MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
           Dout : out STD_LOGIC_VECTOR (9 downto 0));
end PC_MUX;

architecture Behavioral of PC_MUX is

    signal interrupt : std_logic_vector (9 downto 0) := "1111111111";

begin

    with MUX_SEL select
        Dout <= FROM_IMMED when "00",
                FROM_STACK when "01",
                interrupt  when "10",
                (others => '0') when others;

end Behavioral;
