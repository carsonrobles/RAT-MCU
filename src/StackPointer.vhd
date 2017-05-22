----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/13/2017 04:58:25 PM
-- Design Name: 
-- Module Name: ScratchPointer - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity StackPointer is
    Port ( RST      : in  STD_LOGIC;
           LD       : in  STD_LOGIC;
           INCR     : in  STD_LOGIC;
           DECR     : in  STD_LOGIC;
           CLK      : in  STD_LOGIC;
           DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
           
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0)
           );
end StackPointer;

architecture Behavioral of StackPointer is

signal tmp_sig : STD_LOGIC_VECTOR(7 downto 0);

begin
    Proc1 : process (RST, LD, INCR, DECR, CLK)
    begin
        if (RST = '1') then
            tmp_sig <= x"00";
        elsif (rising_edge(CLK)) then
            if (LD = '1') then
                tmp_sig <= DATA_IN;
            elsif (INCR = '1') then
                tmp_sig <= tmp_sig + x"01";
            elsif (DECR = '1') then
                tmp_sig <= tmp_sig - x"01";
            else
                tmp_sig <= tmp_sig;
            end if;
        end if;
    end process Proc1;

    DATA_OUT <= tmp_sig;

end Behavioral;
