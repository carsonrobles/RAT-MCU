
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: sseg decoder           --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- decodes 4 bit value to seven segment display
entity sseg_dcdr is
    port (
        dig : in  std_logic_vector (3 downto 0);        -- val input

        seg : out std_logic_vector (7 downto 0)         -- sseg output
    );
end sseg_dcdr;

architecture sseg_dcdr_arc of sseg_dcdr is
begin
    -- decode digits 1, 2, 3, 4; others are blank (invalid)
    with dig select
        seg <= "11111001" when "0000",
               "10100100" when "0001",
               "10110000" when "0010",
               "10011001" when "0011",
               "11000111" when "0100",
               "11000000" when "0101",
               "10010010" when "0110",
               "10000110" when "0111",
               "10100001" when "1000",
               "11111110" when "1001",
               "11110111" when "1010",
               "11001111" when "1011",
               "11111111" when others;
end sseg_dcdr_arc;

