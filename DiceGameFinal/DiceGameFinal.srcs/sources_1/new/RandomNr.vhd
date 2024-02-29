library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity randomNr is
    Port ( clk   : in std_logic;
           reset : in std_logic;
           ranNr : out std_logic_vector (2 downto 0)
         );
end randomNr;

architecture Behavioral of randomNr is
    signal nr    : integer :=129;
    constant x : integer := 1664525;
    constant y : integer := 2147483647; -- 2^31-1
    constant z : integer := 1442243407;
begin
    process(clk, reset)
        variable tmp : integer;
    begin
        if reset = '1' then
            nr <= 129;
        elsif rising_edge(clk) then
            tmp := (x * nr + z) mod y;
            nr <= tmp;
        end if;
    end process;
    ranNr<=std_logic_vector(to_unsigned(( nr mod 6) + 1,3));
    
end Behavioral;