-- Realiza as operações lógicas
-- AND, OR, NOT, XOR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_unit is
    generic (
        n: integer := 4
    );
    port (
        a: in STD_LOGIC_VECTOR(n-1 downto 0);
        b: in STD_LOGIC_VECTOR(n-1 downto 0);
        cmd: in STD_LOGIC_VECTOR(3 downto 0);

        o: out STD_LOGIC_VECTOR(n-1 downto 0)
    );
end entity logic_unit;

architecture rtl of logic_unit is
begin
    with cmd select
        o <= (a and b) when "0100",                   -- RX & RY
             (a or b) when "0101",                   -- RX | RY
             not a when "0110",                   -- ~RX
             (a xor b) when "0111",                   -- RX ^ RY
             (a(n-2 downto 0) & a(n-1)) when "1000",  -- RX[6..0] RX[7]
             (a(0) & a(n-1 downto 1)) when "1001",    -- RX[0] RX[7..1]        
             (a(n-2 downto 0) & '0') when "1010",     -- RX[6..0] 0
             '0' & (a(n-1 downto 1)) when "1011",     -- 0 RX[7..1]
             (others => '0') when others;

end architecture rtl;
