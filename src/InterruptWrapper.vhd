
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InterruptWrapper is
    Port ( INT_I   : in  STD_LOGIC; --external interrupt
           I_SET   : in  STD_LOGIC; --allows interrupt signals
           I_CLR   : in  STD_LOGIC; --masks interrupt signals
           CLK     : in  STD_LOGIC; --system clock
           INT_OUT : out STD_LOGIC); --Interrupt output
end InterruptWrapper;

architecture Behavioral of InterruptWrapper is

component FlagReg is
    Port ( IN_FLAG  : in  STD_LOGIC; --flag input
           LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
           SET      : in  STD_LOGIC; --set the flag to '1'
           CLR      : in  STD_LOGIC; --clear the flag to '0'
           CLK      : in  STD_LOGIC; --system clock
           OUT_FLAG : out STD_LOGIC := '1'); --flag output
end component FlagReg;

----------intermediate signals-------------
    signal s_if_out  : std_logic := '0';
    
begin
    
intf : FlagReg port map (
    IN_FLAG  => '0',
    LD       => '0',
    SET      => I_SET,
    CLR      => I_CLR,
    clk      => CLK,
    OUT_FLAG => s_if_out
);

INT_OUT <= INT_I and s_if_out;

end Behavioral;
