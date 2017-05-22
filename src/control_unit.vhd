----------------------------------------------------------------------------------
-- Company: CPE 233
-- -------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY control_unit IS
    PORT (
        CLK          : IN STD_LOGIC;

        C_FLAG       : IN STD_LOGIC;
        Z_FLAG       : IN STD_LOGIC;

        INT          : IN STD_LOGIC;
        RESET        : IN STD_LOGIC;

        OPCODE_HI_5  : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        OPCODE_LO_2  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

        RST          : OUT STD_LOGIC;
        PC_LD        : OUT STD_LOGIC;
        PC_INC       : OUT STD_LOGIC;
        PC_MUX_SEL   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

        SP_LD        : OUT STD_LOGIC;
        SP_INCR      : OUT STD_LOGIC;
        SP_DECR      : OUT STD_LOGIC;

        RF_WR        : OUT STD_LOGIC;
        RF_WR_SEL    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

        ALU_OPY_SEL  : OUT STD_LOGIC;
        ALU_SEL      : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        SCR_WE       : OUT STD_LOGIC;
        SCR_ADDR_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        SCR_DATA_SEL : OUT STD_LOGIC;

        FLAG_LD_SEL  : OUT STD_LOGIC;
        FLAG_SHAD_LD : OUT STD_LOGIC;
        FLAG_C_LD    : OUT STD_LOGIC;
        FLAG_C_SET   : OUT STD_LOGIC;
        FLAG_C_CLR   : OUT STD_LOGIC;
        FLAG_Z_LD    : OUT STD_LOGIC;

        I_SET        : OUT STD_LOGIC;
        I_CLR        : OUT STD_LOGIC;

        IO_STRB      : OUT STD_LOGIC);
    END control_unit;

    ARCHITECTURE Behavioral OF control_unit IS

        TYPE state_type IS (ST_init, ST_fet, ST_exec, ST_int);
        SIGNAL PS, NS       : state_type;
        SIGNAL sig_OPCODE_7 : std_logic_vector (6 DOWNTO 0);

    BEGIN
    -- concatenate the all opcodes into a 7-bit complete opcode for
    -- easy instruction decoding.
    sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

    sync_p: PROCESS (CLK, NS, RESET) BEGIN
        IF (RESET = '1') THEN
            PS <= ST_init;
        ELSIF (rising_edge(CLK)) THEN
            PS <= NS;
        END IF;
    END PROCESS sync_p;

    comb_p: PROCESS (sig_OPCODE_7, PS, C_FLAG, Z_FLAG, INT) BEGIN

        -- This is the default block for all signals set in the STATE cases.  Note that any output values desired
        -- to be different from these values shown below will be assigned in the individual case statements for
        -- each STATE.  Please note that that this "default" set of values must be stated for each individual case
        -- statement.  We have a case statement for CPU states and then an embedded case statement for OPCODE
        -- resolution.

        PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET          <= '0';
        PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
        PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     SCR_WE         <= '0';
        SP_LD          <= '0';     ALU_SEL        <= "0000";    FLAG_Z_LD      <= '0';     SCR_ADDR_SEL   <= "00";
        SP_INCR        <= '0';     IO_STRB        <= '0';       FLAG_LD_SEL    <= '0';     SCR_DATA_SEL   <= '0';
        SP_DECR        <= '0';     RST            <= '0';       FLAG_SHAD_LD   <= '0';

        CASE PS IS
            -- STATE: the init cycle ------------------------------------
            -- Initialize all control outputs to non-active states and reset the PC and SP to all zeros.
            WHEN ST_init =>
                RST <= '1';
                NS <= ST_fet;

            -- STATE: the fetch cycle -----------------------------------
            WHEN ST_fet =>
                PC_INC <= '1';
                NS <= ST_exec;
            
            -- STATE: the interrupt cycle -------------------------------    
            WHEN ST_int =>
                SCR_DATA_SEL <= '1';
                SCR_ADDR_SEL <= "11";
                SCR_WE       <= '1';
                SP_DECR      <= '1';
                PC_MUX_SEL   <= "10";
                PC_LD        <= '1';
                I_CLR        <= '1';
                FLAG_SHAD_LD <= '1';
                NS <= ST_fet;

            -- STATE: the execute cycle ---------------------------------
            WHEN ST_exec =>
                IF (INT = '1') THEN
                    NS <= ST_int;
                ELSE 
                    NS <= ST_fet;
                END IF;

                CASE sig_OPCODE_7 IS
					-- BRN -------------------
                    when "0010000" =>
                        PC_LD      <= '1';              -- set PC to load new value to branch to
                        PC_MUX_SEL <= "00";             -- set PC mux to select immediate value

					-- EXOR reg-reg  --------
                    when "0000010" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "0111";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '0';             -- select register as second argument

					-- EXOR reg-immed  ------
                    when "1001000" | "1001001" | "1001010" | "1001011" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data coming from ALU
                        ALU_SEL     <= "0111";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '1';             -- select immediate value as second argument

                    -- IN
                    when "1100100" | "1100101" | "1100110" | "1100111" =>
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "11";            -- select data coming from in port

                    -- MOV reg-reg ----------
                    when "0001001" =>
                        RF_WR       <= '1';             -- allow writing to reg file
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "1110";          -- specify MOV instruction to ALU
                        ALU_OPY_SEL <= '0';             -- get second operand from register file

                    -- MOV reg-immed --------
                    when "1101100" | "1101101" | "1101110" | "1101111" =>
                        RF_WR       <= '1';             -- allow writing to reg file
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "1110";          -- specify MOV instruction to ALU
                        ALU_OPY_SEL <= '1';             -- get second operand from immediate value

                    -- OUT ------------------
                    when "1101000" | "1101001" | "1101010" | "1101011" =>
                        IO_STRB <= '1';

                    -- START CARSON CU --

                    -- OR reg-reg -----
                    when "0000001" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "0110";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '0';             -- select register as second argument

                    -- OR reg-immed -----
                    when "1000100" | "1000101" | "1000110" | "1000111" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "0110";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '1';             -- select immediate as second argument

                    -- LSL -----
                    when "0100000" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "1001";          -- tell ALU which operation to perform

                    -- ROL -----
                    when "0100010" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "1011";          -- tell ALU which operation to perform

                    -- BREQ -----
                    when "0010010" =>
                        PC_MUX_SEL <= "00";             -- set PC mux to select immediate value

                        if (Z_FLAG = '1') then
                            PC_LD <= '1';               -- set PC to load new value to branch to if Z is set
                        else
                            PC_LD <= '0';               -- otherwise do not load new value
                        end if;

                    -- BRCS -----
                    when "0010100" =>
                        PC_MUX_SEL <= "00";             -- set PC mux to select immediate value

                        if (C_FLAG = '1') then
                            PC_LD <= '1';               -- set PC to load new value to branch to if Z is set
                        else
                            PC_LD <= '0';               -- otherwise do not load new value
                        end if;

                    -- CLC -----
                    when "0110000" =>
                        FLAG_C_CLR <= '1';              -- drive C flag clear line high

                    -- LD - reg-reg -----
                    when "0001010" =>
                        RF_WR        <= '1';            -- allow result to be written to reg file
                        RF_WR_SEL    <= "01";           -- select data to come from scratch RAM
                        SCR_ADDR_SEL <= "00";           -- select address to be chosen from register

                    -- LD - reg-immed -----
                    when "1110000" | "1110001" | "1110010" | "1110011" =>
                        RF_WR        <= '1';            -- allow result to be written to reg file
                        RF_WR_SEL    <= "01";           -- select data to come from scratch RAM
                        SCR_ADDR_SEL <= "01";           -- select address to be chosen from immediate value

                    -- ADDC - reg-reg -----
                    when "0000101" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "0001";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '0';             -- select register as second argument

                    -- ADDC - reg-immed -----
                    when "1010100" | "1010101" | "1010110" | "1010111" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        RF_WR       <= '1';             -- allow result to be written to reg file
                        RF_WR_SEL   <= "00";            -- select data to come from ALU
                        ALU_SEL     <= "0001";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '1';             -- select immediate as second argument

                    -- CMP - reg-reg -----
                    when "0001000" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        ALU_SEL     <= "0100";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '0';             -- select register as second argument

                    -- CMP - reg-immed -----
                    when "1100000" | "1100001" | "1100010" | "1100011" =>
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        ALU_SEL     <= "0100";          -- tell ALU which operation to perform
                        ALU_OPY_SEL <= '1';             -- select immediate as second argument

                    -- PUSH -----
                    when "0100101" =>
                        SP_DECR      <= '1';            -- decrement stack pointer
                        SCR_WE       <= '1';            -- enable writing to RAM
                        SCR_DATA_SEL <= '0';           -- select data to come from register 1
                        SCR_ADDR_SEL <= "11";           -- select address from stack pointer - 1

                    -- WSP -----
                    when "0101000" =>
                        SP_LD <= '1';                   -- drive stack pointer load line high

                    -- RET -----
                    when "0110010" =>
                        SP_INCR      <= '1';            -- increment stack pointer
                        SCR_ADDR_SEL <= "10";           -- select address from current top of stack
                        PC_LD        <= '1';            -- load data in for PC
                        PC_MUX_SEL   <= "01";           -- select load data as from scatch RAM

                    -- SEI -----
                    when "0110100" =>
                        I_SET <= '1';                   -- drive I_SET high to enable interrupts

                    -- RETIE -----
                    when "0110111" =>
                        SP_INCR      <= '1';            -- increment stack pointer
                        SCR_ADDR_SEL <= "10";           -- select address from current top of stack
                        PC_LD        <= '1';            -- load data in for PC
                        PC_MUX_SEL   <= "01";           -- select load data as from scatch RAM
                        I_SET        <= '1';            -- drive I_SET high to enable interrupts
                        FLAG_LD_SEL  <= '1';            -- selects shadow flags to load from
                        FLAG_C_LD    <= '1';            -- allows C flag to be written to
                        FLAG_Z_LD    <= '1';            -- allows Z flag to be written to
                    -- END CARSON CU --

                    -- ADD reg-reg --------
                    when "0000100" =>
                        RF_WR       <= '1';             -- allow writing to reg file
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0000";          -- specify ADD instruction to ALU
                        ALU_OPY_SEL <= '0';             -- get second operand from register file
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        
                    -- ADD reg-immed --------
                    when "1010000" | "1010001" | "1010010" | "1010011" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0000";          -- specify ADD instruction to ALU
                        ALU_OPY_SEL <= '1';             -- get second operand from immediate value
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
         
                    -- AND reg-reg --------
                    when "0000000" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0101";          -- specify AND instruction to ALU
                        ALU_OPY_SEL <= '0';             -- get second operand from register file
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        
                    -- AND reg-immed --------
                    when "1000000" | "1000001" | "1000010" | "1000011" =>                                   
                        RF_WR       <= '1';             -- allow writing to reg file--  
                        RF_WR_SEL   <= "00";            -- take data from ALU                  
                        ALU_SEL     <= "0101";          -- specify AND instruction to ALU   
                        ALU_OPY_SEL <= '1';             -- get second operand from immediate value
                        FLAG_C_LD   <= '1';             -- overwrite C flop       
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                        
                    -- LSR --------
                    when "0100001" =>                                   
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU 
                        ALU_SEL     <= "1010";          -- specify LSR instruction to ALU     
                        FLAG_C_LD   <= '1';             -- overwrite C flop      
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop                        
                        
                    -- ROR --------
                    when "0100011" =>                                   
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU                  
                        ALU_SEL     <= "1100";          -- specify ROR instruction to ALU 
                        FLAG_C_LD   <= '1';             -- overwrite C flop             
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop                        
                        
                    -- ASR --------
                    when "0100100" =>                                   
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU                  
                        ALU_SEL     <= "1101";          -- specify ROR instruction to ALU 
                        FLAG_C_LD   <= '1';             -- overwrite C flop             
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop                        
                        
                    -- BRNE --------
                    when "0010011" => 
                        if (Z_FLAG = '0') then          -- branches if reset flag is cleared  
                            PC_MUX_SEL <= "00";         -- takes PC value from IR
                            PC_LD      <= '1';          -- loads PC value from MUX
                        end if;   
                        
                    -- BRCC --------
                    when "0010101" => 
                        if (C_FLAG = '0') then          -- branches if carry flag is cleared  
                            PC_MUX_SEL <= "00";         -- takes PC value from IR
                            PC_LD      <= '1';          -- loads PC value from MUX
                        end if;                                       
                        
                    -- SEC --------
                    when "0110001" =>                                   
                        FLAG_C_SET  <= '1';             -- sets carry flag                        
                        
                    -- POP --------                        
                    when "0100110" =>
                        SP_INCR      <= '1';            -- increments the stack pointer
                        SCR_ADDR_SEL <= "10";           -- selects SP address for SCR
                        RF_WR        <= '1';            -- allow writing to reg file
                        RF_WR_SEL    <= "01";           -- take data from SCR                               
                        
                    -- CALL --------                        
                    when "0010001" =>
                        SCR_DATA_SEL <= '1';            -- Selects PC to SCR Data Value
                        SCR_WE       <= '1';            -- Allows scrath ram to be written to 
                        SP_DECR      <= '1';            -- decrements the stack pointer
                        SCR_ADDR_SEL <= "11";           -- selects SP-1 address for SCR
                        PC_LD        <= '1';            -- allow writing PC Value
                        PC_MUX_SEL   <= "00";           -- take data from IMMED Value                               

                    -- ST reg-reg --------                        
                    when "0001011" =>
                        SCR_DATA_SEL <= '0';            -- selects ADRX Reg data as data for SCR
                        SCR_ADDR_SEL <= "00";           -- selects ADRY Reg value as address for SCR
                        SCR_WE       <= '1';            -- allow writing to SCR
                        
                    -- ST reg-immed --------                        
                    when "1110100" | "1110101" | "1110110" | "1110111" =>
                        SCR_DATA_SEL <= '0';            -- selects ADRX Reg data as data for SCR
                        SCR_ADDR_SEL <= "01";           -- selects IMMED value as address for SCR
                        SCR_WE       <= '1';            -- allow writing to SCR                             
                       
                    -- SUB reg-reg --------                        
                    when "0000110" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0010";          -- specify SUB instruction to ALU
                        ALU_OPY_SEL <= '0';             -- get second operand from register file
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                             
                    -- SUB reg-immed --------                        
                    when "1011000" | "1011001" | "1011010" | "1011011" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0010";          -- specify SUB instruction to ALU
                        ALU_OPY_SEL <= '1';             -- get second operand from immediate value
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                            
                    -- SUBC reg-reg --------                        
                    when "0000111" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0011";          -- specify SUBC instruction to ALU
                        ALU_OPY_SEL <= '0';             -- get second operand from register file
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop
                    
                    -- SUBC reg-immed --------                        
                    when "1011100" | "1011101" | "1011110" | "1011111" =>
                        RF_WR       <= '1';             -- allow writing to reg file-- 
                        RF_WR_SEL   <= "00";            -- take data from ALU
                        ALU_SEL     <= "0011";          -- specify SUBC instruction to ALU
                        ALU_OPY_SEL <= '1';             -- get second operand from immediate value
                        FLAG_C_LD   <= '1';             -- overwrite C flop
                        FLAG_Z_LD   <= '1';             -- overwrite Z flop

                    -- CLI --------                        
                    when "0110101" =>
                        I_CLR       <= '1';             -- clears the interrupt flag  
                        I_SET       <= '0';             -- ensures interrupt is not set                            
                                                                                                 
                    -- RETID --------                        
                    when "0110110" =>
                        SP_INCR      <= '1';            -- increments the stack pointer
                        I_CLR        <= '1';            -- masks interrupt flag
                        PC_LD        <= '1';            -- Allows PC to be written to
                        PC_MUX_SEL   <= "01";           -- Selects data from SCR to write to PC
                        SCR_ADDR_SEL <= "10";           -- selects SP address for SCR
                        FLAG_LD_SEL  <= '1';            -- selects shadow flags to load from
                        FLAG_C_LD    <= '1';            -- allows C flag to be written to
                        FLAG_Z_LD    <= '1';            -- allows Z flag to be written to

                    -- TEST reg-reg ---------
                    when "0000011" =>
                        FLAG_C_CLR  <= '1';             -- clears carry flag
                        ALU_SEL     <= "0101";          -- selects AND for ALU
                        ALU_OPY_SEL <= '0';             -- takes reg value for ALU
                        FLAG_Z_LD   <= '1';             -- Loads reset flag
                    
                    -- TEST reg-immed -------
                    when "1001100" | "1001101" | "1001110" | "1001111" =>
                        FLAG_C_CLR  <= '1';             -- clears carry flag
                        ALU_SEL     <= "0101";          -- selects AND for ALU
                        ALU_OPY_SEL <= '1';             -- takes immed value for ALU
                        FLAG_Z_LD   <= '1';             -- Loads reset flag


                    WHEN OTHERS =>
                        -- do nothing for this execution
                END CASE;

                

            -- STATE: default any case to reinitialize
            WHEN OTHERS =>
                NS <= ST_init;

       END CASE;

    END PROCESS comb_p;

END Behavioral;
