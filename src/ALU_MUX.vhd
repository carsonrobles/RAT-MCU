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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_MUX is
    Port ( DY_OUT     : in  STD_LOGIC_VECTOR (7 downto 0);
           FROM_IMMED : in  STD_LOGIC_VECTOR (7 downto 0);
           MUX_SEL    : in  STD_LOGIC;
           Dout       : out STD_LOGIC_VECTOR (7 downto 0));
end ALU_MUX;

architecture Behavioral of ALU_MUX is

    --signal interrupt : std_logic_vector (9 downto 0) := "1111111111";

begin

    with MUX_SEL select
        Dout <= DY_OUT when '0',
                FROM_IMMED when '1',
                x"00" when others;

end Behavioral;
