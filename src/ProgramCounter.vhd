----------------------------------------------------------------------------------
--
-- Engineer: Carson Robles, Jacob Butler
--
-- Create Date: 01/11/2017 11:20:13 AM
-- Module Name: ProgramCounter - Behavioral
-- Description: PC for the RAT MCU, indicates address of current instruction
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ProgramCounter is
    port (
        Din      : in  std_logic_vector (9 downto 0);
        PC_LD    : in  std_logic;
        PC_INC   : in  std_logic;
        RST      : in  std_logic;
        clk      : in  std_logic;

        PC_COUNT : out std_logic_vector (9 downto 0)
    );
end ProgramCounter;

architecture pc_arch of ProgramCounter is
    signal tmp_cnt : std_logic_vector (9 downto 0) := (others => '0');
begin

    process (clk, rst, PC_LD, PC_INC)
    begin
        if (rising_edge (clk)) then
            if (rst = '1')       then tmp_cnt <= (others => '0');
            elsif (PC_LD = '1')  then tmp_cnt <= Din;
            elsif (PC_INC = '1') then tmp_cnt <= tmp_cnt + '1';
            end if;
        end if;
    end process;

    PC_COUNT <= tmp_cnt;

end pc_arch;
