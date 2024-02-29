-- Frequency Divider From 100MHz to 1Hz=1sec

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity FDiv1s is
 Port ( clk: in std_logic;
        rst: in std_logic;
        new_clk: out std_logic
 );
end FDiv1s;

architecture Behavioral of FDiv1s is
    signal clk_div: std_logic:='0';
    signal count: INTEGER:=0;
begin
    process(clk)
        begin
            if rst='1' then
                clk_div <='0';
                elsif rising_edge(clk) then
                    if count<49999999 then
                        count<=count+1;
                    else
                        count<=0;
                        clk_div<=not(clk_div);
                    end if;
            end if;
       end process;
       new_clk<=clk_div;

end Behavioral;
