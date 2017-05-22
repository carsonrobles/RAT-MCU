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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SCR_MUX is
    Port ( DY_OUT     : in  STD_LOGIC_VECTOR (7 downto 0);
           FROM_IMMED : in  STD_LOGIC_VECTOR (7 downto 0);
           SP_DATA    : in  STD_LOGIC_VECTOR (7 downto 0);
           MUX_SEL    : in  STD_LOGIC_VECTOR (1 downto 0);
           ADDR       : out STD_LOGIC_VECTOR (7 downto 0));
end SCR_MUX;

architecture Behavioral of SCR_MUX is

    signal SP_DEC : STD_LOGIC_VECTOR (7 downto 0);

begin

    dec_proc : process (SP_DATA)
    begin
        SP_DEC <= SP_DATA - "00000001";
    end process dec_proc;

    with MUX_SEL select
        ADDR <= DY_OUT          when "00",
                FROM_IMMED      when "01",
                SP_DATA         when "10",
                SP_DEC          when "11",
                (others => '0') when others;

end Behavioral;
