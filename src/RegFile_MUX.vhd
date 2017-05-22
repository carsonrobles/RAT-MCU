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

entity RegFile_MUX is
    Port ( IN_PORT      : in  STD_LOGIC_VECTOR (7 downto 0);
           B            : in  STD_LOGIC_VECTOR (7 downto 0);
           Scratch_DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           ALU_RESULT   : in  STD_LOGIC_VECTOR (7 downto 0);
           MUX_SEL      : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout         : out STD_LOGIC_VECTOR (7 downto 0));
end RegFile_MUX;

architecture Behavioral of RegFile_MUX is

    --signal interrupt : std_logic_vector (9 downto 0) := "1111111111";

begin

    with MUX_SEL select
        Dout <= ALU_Result when "00",
                Scratch_DATA when "01",
                B when "10",
                IN_PORT  when "11",
                x"00" when others;

end Behavioral;
