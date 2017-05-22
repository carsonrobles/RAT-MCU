------------------------------------------------------------------
-- Engineers: Carson Robles, Jacob Butler
-- Date: Jan 27, 2017
-- module: ALU
-- Description: Arithmetic Logic Unit for RAT MCU
--              executes all math and logic operations for the MCU
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
    port (
        A   : in  std_logic_vector (7 downto 0);
        B   : in  std_logic_vector (7 downto 0);
        SEL : in  std_logic_vector (3 downto 0);
        Cin : in  std_logic;

        C   : out std_logic;
        Z   : out std_logic;
        RES : out std_logic_vector (7 downto 0)
    );
end alu;

architecture alu_arch of alu is

signal res_tmp : std_logic_vector (8 downto 0);

begin
    alu_proc : process (A, B, SEL, Cin)
    begin
        case (SEL) is
            when "0000" => res_tmp <= ('0' & A) + B;                -- ADD
            when "0001" => res_tmp <= ('0' & A) + B + Cin;          -- ADDC
            when "0010" => res_tmp <= ('0' & A) - B;                -- SUB
            when "0011" => res_tmp <= ('0' & A) - B - Cin;          -- SUBC
            when "0100" => res_tmp <= ('0' & A) - B;                -- CMP
            when "0101" => res_tmp <= '0' & (A and B);              -- AND
            when "0110" => res_tmp <= '0' & (A or  B);              -- OR
            when "0111" => res_tmp <= '0' & (A xor B);              -- EXOR
            when "1000" => res_tmp <= '0' & (A and B);              -- TEST
            when "1001" => res_tmp <= A & Cin;                      -- LSL
            when "1010" => res_tmp <= A(0) & Cin & A(7 downto 1);   -- LSR
            when "1011" => res_tmp <= A & A(7);                     -- ROL
            when "1100" => res_tmp <= A(0) & A(0) & A(7 downto 1);  -- ROR
            when "1101" => res_tmp <= A(0) & A(7) & A(7 downto 1);  -- ASR
            when "1110" => res_tmp <= '0' & B;                      -- MOV
            when others => res_tmp <= '0' & x"00";
        end case;
    end process alu_proc;

    C   <= res_tmp(8);
    Z   <= '1' when (res_tmp(7 downto 0) = x"00") else '0';
    RES <= res_tmp(7 downto 0);
end alu_arch;

