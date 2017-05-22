--
-- A flip-flop to store the the zero, carry, and interrupt flags.
-- To be used in the RAT CPU.
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FlagWrapper is
    Port ( C_IN     : in  STD_LOGIC; --flag input
           Z_IN     : in  STD_LOGIC; --flag input
           C_LD     : in  STD_LOGIC; --load the out_flag with the in_flag value
           Z_LD     : in  STD_LOGIC; --load the out_flag with the in_flag value
           SHAD_LD  : in  STD_LOGIC; --load the out_flag with the in_flag value
           LD_SEL   : in  STD_LOGIC; --selects shadow or input as flag input
           C_SET    : in  STD_LOGIC; --set the flag to '1'
           C_CLR    : in  STD_LOGIC; --clear the flag to '0'
           CLK      : in  STD_LOGIC; --system clock
           C_OUT    : out STD_LOGIC := '0'; --flag output
           Z_OUT    : out STD_LOGIC := '0'); --flag output
end FlagWrapper;


architecture Behavioral of FlagWrapper is

    component FlagReg is
        Port ( IN_FLAG  : in  STD_LOGIC; --flag input
               LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
               SET      : in  STD_LOGIC; --set the flag to '1'
               CLR      : in  STD_LOGIC; --clear the flag to '0'
               CLK      : in  STD_LOGIC; --system clock
               OUT_FLAG : out STD_LOGIC := '0'); --flag output
    end component FlagReg;
    
    component FlagMux is
            Port ( INPUT  : in  STD_LOGIC; --flag input from ALU
                   SHADOW : in  STD_LOGIC; --flag input from shadow
                   SEL    : in  STD_LOGIC := '0'; --chooses which flag input to load
                   F_IN   : out STD_LOGIC := '0'); --flag input being loaded
    end component FlagMux;
    
----------intermediate signals-------------
    signal s_cf_in  : std_logic := '0';
    signal s_cf_out : std_logic := '0';
    signal s_cf_sh  : std_logic := '0';
 
    signal s_zf_in  : std_logic := '0';
    signal s_zf_out : std_logic := '0';
    signal s_zf_sh  : std_logic := '0';

begin
    C_OUT <= s_cf_out;
    Z_OUT <= s_zf_out;

    CMUX : FlagMux port map (
        INPUT  => C_IN,
        SHADOW => s_cf_sh,
        SEL    => LD_SEL,
        F_IN   => s_cf_in
    );
    
    ZMUX : FlagMux port map (
        INPUT  => Z_IN,
        SHADOW => s_zf_sh,
        SEL    => LD_SEL,
        F_IN   => s_zf_in
    );

    cf : FlagReg port map (
        IN_FLAG  => s_cf_in,
        LD       => C_LD,
        SET      => C_SET,
        CLR      => C_CLR,
        clk      => CLK,
        OUT_FLAG => s_cf_out
    );

    zf : FlagReg port map (
        IN_FLAG  => s_zf_in,
        LD       => Z_LD,
        SET      => '0',
        CLR      => '0',
        clk      => CLK,
        OUT_FLAG => s_zf_out
    );
    
    csf : FlagReg port map (
        IN_FLAG  => s_cf_out,
        LD       => SHAD_LD,
        SET      => '0',
        CLR      => '0',
        clk      => CLK,
        OUT_FLAG => s_cf_sh
    );
        
    zsf : FlagReg port map (
        IN_FLAG  => s_zf_out,
        LD       => SHAD_LD,
        SET      => '0',
        CLR      => '0',
        clk      => CLK,
        OUT_FLAG => s_zf_sh
    );

end Behavioral;
