LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY PCWrapperTestBench IS
END PCWrapperTestBench;
 
ARCHITECTURE behavior OF PCWrapperTestBench IS
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PCWrapper
    PORT(
         FROM_STACK : IN   std_logic_vector(9 downto 0);
         FROM_IMMED : IN   std_logic_vector(9 downto 0);
         MUX_SEL    : IN   std_logic_vector(1 downto 0);
         PC_LD      : IN   std_logic;
         PC_INC     : IN   std_logic;
         RST        : IN   std_logic;
         CLK        : IN   std_logic;
         PC_COUNT   : OUT  std_logic_vector(9 downto 0);
         IR         : OUT  std_logic_vector(17 downto 0)
        );
    END COMPONENT;
   
 
   --Inputs
   signal FROM_IMMED_tb : std_logic_vector(9 downto 0) := "0011001100"; --x0CC
   signal FROM_STACK_tb : std_logic_vector(9 downto 0) := "0110101010"; --x1AA
   signal PC_MUX_SEL_tb : std_logic_vector(1 downto 0) := (others => '0');
   signal PC_LD_tb      : std_logic := '0';
   signal PC_INC_tb     : std_logic := '0';
   signal RST_tb        : std_logic := '0';
   signal CLK_tb        : std_logic := '0';
 
    --Outputs
   signal PC_COUNT_tb : std_logic_vector(9 downto 0);
   signal IR_tb       : std_logic_vector(17 downto 0);
 
   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: PCWrapper PORT MAP (
          FROM_STACK => FROM_STACK_tb,
          FROM_IMMED => FROM_IMMED_tb,
          MUX_SEL    => PC_MUX_SEL_tb,
          PC_LD      => PC_LD_tb,
          PC_INC     => PC_INC_tb,
          RST        => RST_tb,
          CLK        => CLK_tb,
          PC_COUNT   => PC_COUNT_tb,
          IR         => IR_tb
        );
 
   -- Clock process definitions
   CLK_process : process
   begin
        CLK_tb <= '0';
        wait for CLK_period/2;
        CLK_tb <= '1';
        wait for CLK_period/2;
   end process;
 
 
   -- Stimulus process
   stim_proc: process
   begin
        PC_LD_tb      <= '1';
        PC_INC_tb     <= '0';
        PC_MUX_SEL_tb <= "00";
        FROM_IMMED_tb <= "0000010000";
        RST_tb        <= '0';
        wait for 10 ns;

        PC_LD_tb      <= '0';
        PC_INC_tb     <= '1';
        wait for 45 ns;

        RST_tb        <= '1';
        wait for 20 ns;

        PC_MUX_SEL_tb <= "01";
        FROM_STACK_tb <= "0011001101";
        wait for 10 ns;

        RST_tb        <= '0';
        PC_LD_tb      <= '1';
        wait for 10 ns;

        PC_LD_tb      <= '0';
        wait for 20 ns;

        PC_MUX_SEL_tb <= "10";
        PC_LD_tb      <= '1';
        wait;
   end process;
 
END;
