LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY SSD IS
    PORT(   CLK: IN    STD_LOGIC;               -- STANDARD CLOCK OF 100 MHZ
            -- ON AFIS WILL BE STORED WHAT WILL BE DISPLAYED ON EACH ANODE
            AFIS0:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS1:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS2:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS3:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS4:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS5:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS6:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AFIS7:  IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            AN:     OUT STD_LOGIC_VECTOR    (7 DOWNTO 0);
            CAT:    OUT STD_LOGIC_VECTOR    (6 DOWNTO 0)
           );
END SSD;

ARCHITECTURE BHV OF SSD IS
    
    -- SIGNAL DECLARATION
    SIGNAL COUNT: STD_LOGIC_VECTOR(16 DOWNTO 0) := (16 DOWNTO 0 => '0');
    SIGNAL INPUT_DECODER: STD_LOGIC_VECTOR  (4 DOWNTO 0);
    
BEGIN
    
    -- THE COUNTER
    PROCESS(CLK)
    BEGIN
    IF  CLK='1' AND CLK'EVENT THEN
        COUNT<=COUNT+1;
    END IF;
    END PROCESS;
    
    -- SELECTING THE ANODES
    -- AND WHAT NEEDS TO BE DISLPAYED ON EACH OF THEM CONSEQUENTIELLY 
    PROCESS(COUNT)
    BEGIN
    CASE(COUNT (16 DOWNTO 14)) IS
        WHEN "000" => AN<="11111110";
                      INPUT_DECODER<=AFIS0;   -- SELECT ANODE 0
        WHEN "001" => AN<="11111101";
                      INPUT_DECODER<=AFIS1;   -- SELECT ANODE 1 
        WHEN "010" => AN<="11111011";
                      INPUT_DECODER<=AFIS2;    -- SELECT ANODE 2    
        WHEN "011" => AN<="11110111";
                      INPUT_DECODER<=AFIS3;   -- SELECT ANODE 3     
        WHEN "100" => AN<="11101111";
                      INPUT_DECODER<=AFIS4;   -- SELECT ANODE 4     
        WHEN "101" => AN<="11011111";
                      INPUT_DECODER<=AFIS5;   -- SELECT ANODE 5
        WHEN "110" => AN<="10111111";
                      INPUT_DECODER<=AFIS6;   -- SELECT ANODE 6
        WHEN OTHERS => AN<="01111111";
                        INPUT_DECODER<=AFIS7;   -- SELECT ANODE 7
    END CASE;
    END PROCESS;

    -- WHAT WILL THE CATODES BE FOR EVERY CASE, THE NUMBER OF DISPLAYS I HAVE!!
    -- they are encoded in this order each abcdefg
    PROCESS(INPUT_DECODER)
    BEGIN
        CASE    INPUT_DECODER IS  
            when "00000" =>  cat<="0100100"; -- S                   1
            when "00001" =>  cat<="1110000"; -- t                   2
            when "00010" =>  cat<="0001000"; -- A                   3
            when "00011" =>  cat<="1111010"; -- r                   4
            when "00100" =>  cat<="1001111"; -- I                   5
            when "00101" =>  cat<="1101010"; -- n                   6
            when "00110" =>  cat<="0011000"; -- P                   7
            when "00111" =>  cat<="1000001"; -- U                   8
            when "01000" =>  cat<="1110110"; -- =                   9
            when "01001" =>  cat<="0011010"; -- ?                   10
            when "01010" =>  cat<="1000010"; -- d                   11
            when "01011" =>  cat<="1001111"; -- 1                   12
            when "01100" =>  cat<="0010010"; -- 2                   13
            when "01101" =>  cat<="0000110"; -- 3                   14
            when "01110" =>  cat<="1001100"; -- 4                   15
            when "01111" =>  cat<="0100100"; -- 5                   16
            when "10000" =>  cat<="0100000"; -- 6                   17
            when "10001" =>  cat<="1100010"; -- full dice           18
            when "10010" =>  cat<="1110010"; -- c                   19
            when "10011" =>  cat<="1101010"; -- u intors            20
            when "10100" =>  cat<="1100110"; -- ]                   21
            when "10101" =>  cat<="0110000"; -- E                   22
            when others =>   cat<="1111111"; -- display nothing     23
         
        END CASE;
    END PROCESS;

END BHV;