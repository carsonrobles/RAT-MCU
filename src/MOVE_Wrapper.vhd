

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MOVE_Wrapper is
    Port ( int_left    : in  STD_LOGIC; --left interrupt
           int_right   : in  STD_LOGIC; --right interrupt
           MOVE_OUT    : in  STD_LOGIC_VECTOR (1 downto 0);
           MOVE_STATUS : out STD_LOGIC_VECTOR (1 downto 0);
           CLK         : in  STD_LOGIC);
end MOVE_Wrapper;

architecture Behavioral of MOVE_Wrapper is

component FLIP_FLOP is
    Port ( SET : in  STD_LOGIC; --set the flag to '1'
           CLR : in  STD_LOGIC; --clear the flag to '0'
           Q   : out STD_LOGIC;
           CLK : in  STD_LOGIC);
end component FLIP_FLOP;

component MOVE_CNTRL is
    Port ( MOVE_OUT  : in  STD_LOGIC_VECTOR (1 downto 0);
           CLR_SIG   : out STD_LOGIC_VECTOR (1 downto 0)); 
end component MOVE_CNTRL;

----------intermediate signals-------------
    signal s_clr_sig  : std_logic_vector (1 downto 0) := "00";
    signal s_move_l   : std_logic := '0';
    signal s_move_r   : std_logic := '0';
    
begin
    
left_flip : FLIP_FLOP port map (
    SET => int_left,
    CLR => s_clr_sig(0),
    Q   => s_move_l,
    CLK => CLK
);

right_flop : FLIP_FLOP port map (
    SET => int_right,
    CLR => s_clr_sig(1),
    Q   => s_move_r,
    CLK => CLK
);

CNTRL : MOVE_CNTRL port map (
    MOVE_OUT  => MOVE_OUT,
    CLR_SIG   => s_clr_sig
);

MOVE_STATUS <= (s_move_l & s_move_r);

end Behavioral;
