

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.all;


entity MAIN is
  Port (    btnc: in std_logic;                             -- button to go forward
            rst:  in std_logic;                             -- master reset button
            clk:  in std_logic;                             -- clock of 100Mhz
            in_p1:  in    std_logic_vector(2 downto 0);     -- player 1 input
            in_p2:  in    std_logic_vector(2 downto 0);     -- player 2 input
            an:   out std_logic_vector(7 downto 0);         -- anode
            cat:  out std_logic_vector(6 downto 0)          -- cathode
             );
end MAIN;

architecture Behavioral of MAIN is

    -- The new clocks of 1sec and 01sec    
    signal      clk1s: std_logic;
    signal      clk01s: std_logic;
    
    --The input to be saved from the USERS
    signal  p1: std_logic_vector(2 downto 0):="000";
    signal  p2: std_logic_vector(2 downto 0):="000";
    
    --The initial sequence!
    signal seq: std_logic_vector(3 downto 0):="ZZZZ";
    
    -- USED COUNTERS FOR THE FSM
    signal  CNT1: INTEGER:=0;   -- counter transition
    signal  CNT2: INTEGER:=0;   -- counter animation
    --The randomNr!
    signal randNr: std_logic_vector(2 downto 0); -- It is constantly generated at every 10 nanosecs
    signal rand_nr: std_logic_vector(2 downto 0); -- It is saved at a state
    
    --Send signals for each afis in SSD
     signal send0: std_logic_vector(4 downto 0);
     signal send1: std_logic_vector(4 downto 0);
     signal send2: std_logic_vector(4 downto 0);
     signal send3: std_logic_vector(4 downto 0);
     signal send4: std_logic_vector(4 downto 0);
     signal send5: std_logic_vector(4 downto 0);
     signal send6: std_logic_vector(4 downto 0);
     signal send7: std_logic_vector(4 downto 0);
     
     -- Signals to check who is the winner!
    signal ok1: std_logic:='0'; -- For player1
    signal ok2: std_logic:='0'; -- For player2
    
    --Declaring the STATEs of the project
    type states is(start, input, displayIn, dice, displaynr, check, displayWin, ed);
    signal current_state: states:= start; -- Initialize the states
    signal next_state:    states:= start;
   
    --The debounced buttons for BTNC and RST
   signal dbtnc: std_logic;
   signal drst:  std_logic; 
begin
    -- Getting the debounced button BTNC and RST
    deb1: entity WORK.debouncer port map
    (
        clk=>clk,
        btn=>btnc,
        en=>dbtnc
    );
    deb2: entity WORK.debouncer port map
    (  
        clk=>clk,
        btn=>rst,
        en=>drst
     );
     
     --Getting the 2 new CLOCKS!! 1s and 0.1s
     fdiv1: entity WORK.FDiv1s port map
     (
        clk=>clk,
        rst=>drst,
        new_clk=>clk1s
     );
     fdiv01: entity WORK.FDiv01s port map
     (
        clk=>clk,
        rst=>drst,
        new_clk=>clk01s
     );
     -- GETTING THE RANDOM NUMBER, VIA THE PSEUDO-RANDOM-NR-GENERATOR
    rannr: entity WORK.randomNr port map
    (
        clk=>clk,                       -- USE the 10 NS clock so we get the random nr more random...
        reset=>rst,
        ranNr=>randNr
    );
    -- MAKING THE CONNECTION TO THE SSD BLACK BOX :)
    ses: entity WORK.SSD port map
    (
        clk=>clk,
        AFIS0=>SEND0,
        AFIS1=>SEND1,
        AFIS2=>SEND2,
        AFIS3=>SEND3,
        AFIS4=>SEND4,
        AFIS5=>SEND5,
        AFIS6=>SEND6,
        AFIS7=>SEND7,
        AN=>AN,
        CAT=>CAT
    );
    
    -- THE CHANGING STATES PROCESS
    process(clk,drst) 
        begin
        if drst='1' then
            current_state<=start;
        elsif rising_edge(clk) then
            current_state<=next_state;
            end if;
    end process;
   
    -- The process of transition of states, using the state diagram 
    process(current_state,dbtnc,ok1,ok2,cnt1)
    begin
        case current_state is
        when start =>
            if dbtnc='1' then next_state<=input;
                        else next_state<=start; end if;
        when input =>
            if dbtnc='1' then next_state<=displayIn;
                        else next_state<=input; end if;
        when displayIn =>
            if dbtnc='1' then next_state<=dice;
                        else next_state<=displayin; end if;
       when dice =>
            if cnt1 > 4 then next_state<=displaynr;
                        else next_state<=dice;      end if;
       when displaynr => if dbtnc='1' then next_state<=check;
                        else next_state<=displaynr; end if;
       when check => if ok1='1' or ok2='1' then next_state<= displaywin;
                     else   next_state<=dice; end if;
       when displaywin => if dbtnc='1' then next_state<=ed;
                          else next_state<=displaywin; end if;
       when ed => if dbtnc='1' then next_state<=start;
                    else next_state<=ed; end if;
       when others => next_state<= start;
    end case;
    end process;                   

    -- The counter which helps to make the transition between dice and displayNr
    process(clk1s) is
    begin
         if rising_edge(clk1s) then
            if current_state=DICE then
                if cnt1>5 then
                cnt1<=0;
                else
                cnt1<=cnt1+1;
           end if;
         end if;
         end if;
   end process;
   
   -- The counter that will make the numbers and dice animation stay on 0,1 sec eac so it gives a fast impression
   process(clk01s)
   begin
         if rising_edge(clk01s) then 
            if  current_state=DICE then
                if cnt2>6 then
                    cnt2<=0;
                 else
                 cnt2<=cnt2+1;
                 end if;
            end if;
        end if;
    end process;
   --The process of what to do in each state!
   process(current_state)is
   begin
        case current_state is
        WHEN START=>
                    SEND0<="11111";
                    SEND1<="11111";
                    SEND2<="11111";
                    SEND3<="00001";
                    SEND4<="00011";
                    SEND5<="00010";
                    SEND6<="00001";
                    SEND7<="00000";
        WHEN INPUT=>
                    SEND0<="11111"; -- nothING
                    SEND1<="01001"; -- ?
                    SEND2<="01000"; -- =
                    SEND3<="00001"; -- T
                    SEND4<="00111"; -- U
                    SEND5<="00110"; -- P
                    SEND6<="00101"; -- N
                    SEND7<="00100"; -- I
        WHEN DISPLAYIN=>
                if p2(0)='0' then
                        SEND0<="01010";
                    else SEND0<="00111"; end if;
                if p2(1)='0' then
                        SEND1<="01010";
                    else
                        send1<="00111"; end if;
               if  p2(2)='0' then
                        send2<="01010";
                    else send2<="00111"; end if;
                    
                    SEND3<="11111";
                    SEND4<="11111";
                    
               if  p1(0)='0' then
                    SEND5<="01010";
                else SEND6<="00111"; end if;
              if p1(1)='0' then
                    SEND6<="01010";
                else SEND6<="00111"; end if;
              if p1(2)='0' then
                    SEND7<="01010";
                 else SEND7<="00111"; end if;
        WHEN DICE=>
                   case cnt2 is
                   when 0 => send7<="01011";      send0<="10001";
                   when 1 => send7<="01100";      send0<="00111";
                   when 2 => send7<="01101";      send0<="00111";
                   when 3 => send7<="01110";      send0<="10100";
                   when 4 => send7<="01111";      send0<="10011";
                   when 5 => send7<="10000";      send0<="10010";
                   when others => send7<="10000"; send0<="10001";
                   end case;
                   
                   SEND1<="11111";
                   SEND2<="11111";
                   SEND3<="11111";
                   SEND4<="11111";
                   SEND5<="11111";
                   SEND6<="11111";
                   
        WHEN DISPLAYNR=>
                    case rand_nr is
                    when "001" => send7<="01011"; send6<="01010";
                    when "010" => send7<="01100"; send6<="01010";
                    when "011" => send7<="01101"; send6<="01010";
                    when "100" => send7<="01110"; send6<="00111";
                    when "101" => send7<="01111"; send6<="00111";
                    when "110" => send7<="10000"; send6<="00111";
                    when others => send7<="11111"; send6<="11111";
                    end case;
                    send5<="11111";
                    send4<="11111";
                    if seq(3) = '1' then
                        send3<="00111";
                        elsif seq(3)='0' then
                        send3<="01010";
                        else send3<="11111";
                        end if;
                    if seq(2) = '1' then
                        send2<="00111";
                        elsif seq(2)='0' then
                        send2<="01010";
                        else send2<="11111";
                        end if;
                    if seq(1) = '1' then
                        send1<="00111";
                        elsif seq(1)='0' then
                        send1<="01010";
                        else send1<="11111";
                        end if;
                    if seq(0) = '1' then
                        send0<="00111";
                        elsif seq(0)='0' then
                        send0<="01010";
                        else send0<="11111";
                        end if;
        WHEN CHECK=>
                    if( seq(2 downto 0)=p1) then
                        ok1<='1';
                        ok2<='0';
                     end if;
                    if(seq(2 downto 0)= p2) then
                        ok2<='1';
                        ok1<='0';
                    end if;
        WHEN DISPLAYWIN=>
                    if ok1='1' then
                        send7<="01011";
                    elsif ok2='1' then
                        send7<="01100";
                    end if;
                    send6<="00111";
                    send5<="00111";
                    send4<="00100";
                    send3<="00101";
                    send2<="00101";
                    send1<="10101";
                    send0<="00011";
        WHEN ED=>
                    send7<="10101";
                    send6<="00101";
                    send5<="01010";
                    
                    SEND0<="11111";
                    SEND1<="11111";
                    SEND2<="11111";
                    SEND3<="11111";
                    SEND4<="11111";
        WHEN OTHERS=>
                    SEND0<="11111";
                    SEND1<="11111";
                    SEND2<="11111";
                    SEND3<="11111";
                    SEND4<="11111";
                    SEND5<="11111";
                    SEND6<="11111";
                    SEND7<="11111";
        END CASE;
END PROCESS;
       
    --Getting the player inputs
    process(clk)
    begin
        if rising_edge(clk) then
            if current_state<=input then
                p1<=in_p1;
                p2<=in_p2;
            end if;
        end if;
    end process;
    
    -- Getting the random NR at the DICE state;
    process(clk)
        begin
        if rising_edge(clk) and current_state=dice then
            if cnt1=5 then
                rand_nr<=randnr;
            end if;
        end if;        
    end process;
    
    -- Modifying the current sequence!
    process(clk)
        begin
        if rising_edge(clk) and current_state=dice then
            if cnt1=5 then
                seq(3 downto 1)<=seq(2 downto 0);
                if(rand_nr="001" or rand_nr="010" or rand_nr="011") then
                    seq(0)<='0';
                elsif(rand_nr="100" or rand_nr="101" or rand_nr="110") then
                    seq(0)<='1';
                else
                    seq(0)<='U';
                end if;
           end if;
      end if;
     end process;
end Behavioral;
