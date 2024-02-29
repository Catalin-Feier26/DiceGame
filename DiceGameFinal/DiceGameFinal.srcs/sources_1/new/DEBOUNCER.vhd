library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Debouncer is
Port (
       clk: in std_logic;
        btn: in std_logic;
        en: out std_logic);
end Debouncer;

architecture Behavioral of Debouncer is
    signal counter: std_logic_vector(16 downto 0):=(others=>'0');
    signal Q1, Q2, Q3: std_logic;
begin
    en <= not(Q3) and Q2;
    process(clk)
        begin
            if rising_edge(clk) then
                counter<= counter+1;
                if counter ="1111111111111111" then
                    Q1<=btn;
               end if;
               Q2<=Q1;
               Q3<=Q2;
         end if;
   end process;

end Behavioral;