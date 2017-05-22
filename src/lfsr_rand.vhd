
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/16/2016 11:59:00 AM --
-- Description: random number gen.     --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lfsr_rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (5 downto 0)
    );
end lfsr_rand;

architecture rand_arc of lfsr_rand is

-- shift reg, start with any non 0 value
signal lfsr : std_logic_vector (7 downto 0) := x"cd";

begin
    lfsr_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            lfsr <= lfsr(6 downto 0) & (lfsr(3) xor (lfsr(4) xor (lfsr(5) xor lfsr(7))));
        end if;
    end process lfsr_proc;

    num <= '0' & lfsr(3 downto 0) & '0';
    
   -- limit: process (lfsr)
       -- begin
        --    if(lfsr(5 downto 0) > "100111") then
       --         num <= '0' & lfsr(4 downto 0);
      --      else 
     --           num <= lfsr(5 downto 0);
     --       end if;
            
    --    end process limit; 
end rand_arc;

