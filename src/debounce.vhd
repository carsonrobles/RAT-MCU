
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debounce is
    port (
        clk  : in std_logic;

        A    : in  std_logic;
        A_DB : out std_logic
    );
end debounce;

architecture Behavioral of debounce is

type state_t is (rd_st, pul_st, dn_st);

signal fsm   : state_t := rd_st;
signal fsm_d : state_t;

signal tck  : std_logic;
signal cnt  : std_logic_vector (7 downto 0) := (others => '0');

signal crt  : std_logic;
signal pcnt : std_logic_vector (2 downto 0) := (others => '1');
signal sft  : std_logic_vector (3 downto 0) := (others => '0');

begin
    with fsm select
        A_DB <= '1' when pul_st,
                '0' when others;

    with cnt select
        tck <= '1' when "11111111",
               '0' when others;

    with sft select
        crt <= '1' when "1111",
               '0' when others;

    cnt_proc : process (clk) begin
        if (rising_edge(clk)) then
            cnt <= cnt + "00000001";
        end if;
    end process cnt_proc;

    sft_proc : process (clk, A) begin
        if (A = '0') then
            sft <= (others => '0');
        elsif (rising_edge(clk)) then
            if (tck = '1') then
                sft <= sft(2 downto 0) & A;
            end if;
        end if;
    end process sft_proc;

    pcnt_proc : process (clk, fsm) begin
        if (rising_edge(clk)) then
            if (fsm = rd_st) then
                pcnt <= (others => '1');
            else
                pcnt <= pcnt - "001";
            end if;
        end if;
    end process pcnt_proc;

    seq_proc : process (clk, fsm_d) begin
        if (rising_edge(clk)) then
            fsm <= fsm_d;
        end if;
    end process seq_proc;

    comb_proc : process (fsm, crt, pcnt) begin
        case (fsm) is
            when rd_st  =>
                if (crt = '1') then
                    fsm_d <= pul_st;
                else
                    fsm_d <= rd_st;
                end if;
            when pul_st =>
                if (pcnt = "00") then
                    fsm_d <= dn_st;
                else
                    fsm_d <= pul_st;
                end if;
            when dn_st  =>
                if (crt = '0') then
                    fsm_d <= rd_st;
                else
                    fsm_d <= dn_st;
                end if;
        end case;
    end process comb_proc;

end Behavioral;
