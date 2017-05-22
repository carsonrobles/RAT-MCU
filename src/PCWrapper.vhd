----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2017 11:34:09 AM
-- Design Name: 
-- Module Name: PCWrapper - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCWrapper is
    Port (
        FROM_STACK : in  std_logic_vector (9 downto 0);
        FROM_IMMED : in  std_logic_vector (9 downto 0);
        MUX_SEL    : in  std_logic_vector (1 downto 0);
        PC_LD      : in  std_logic;
        PC_INC     : in  std_logic;
        rst        : in  std_logic;
        clk        : in  std_logic;
        
        PC_COUNT   : out std_logic_vector (9 downto 0);
        IR         : out std_logic_vector (17 downto 0)
    );
end PCWrapper;

architecture Behavioral of PCWrapper is
    component ProgramCounter is
        port (
            Din      : in  std_logic_vector (9 downto 0);
            PC_LD    : in  std_logic;
            PC_INC   : in  std_logic;
            RST      : in  std_logic;
            clk      : in  std_logic;
            
            PC_COUNT : out std_logic_vector (9 downto 0)
        );
    end component ProgramCounter;
    
    component PC_MUX is
        Port (
            FROM_IMMED : in  STD_LOGIC_VECTOR (9 downto 0);
            FROM_STACK : in  STD_LOGIC_VECTOR (9 downto 0);
            MUX_SEL    : in  STD_LOGIC_VECTOR (1 downto 0);
            Dout       : out STD_LOGIC_VECTOR (9 downto 0)
         );
    end component PC_MUX;

    component prog_rom is 
       port (     ADDRESS : in std_logic_vector(9 downto 0); 
              INSTRUCTION : out std_logic_vector(17 downto 0); 
                      CLK : in std_logic);  
    end component prog_rom;

    signal data : std_logic_vector (9 downto 0);
    signal tmp_cnt : std_logic_vector (9 downto 0);
begin

    MUX : PC_MUX port map (
        FROM_IMMED => FROM_IMMED,
        FROM_STACK => FROM_STACK,
        MUX_SEL    => MUX_SEL,
        Dout       => data
    );

    PC : ProgramCounter port map (
        Din      => data,
        PC_LD    => PC_LD,
        PC_INC   => PC_INC,
        RST      => RST,
        CLK      => clk,
        PC_COUNT => tmp_cnt
    );

    rom : prog_rom port map (
        ADDRESS     => tmp_cnt,
        INSTRUCTION => IR,
        CLK         => CLK
    );

    PC_COUNT <= tmp_cnt;

end Behavioral;
