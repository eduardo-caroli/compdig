library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_subtractor is
    port (
        a: in STD_LOGIC;
        b: in STD_LOGIC;
        bin: in STD_LOGIC;
        o: out STD_LOGIC;
        bout: out STD_LOGIC
    );
end entity full_subtractor;
architecture rtl of full_subtractor is
begin
    o <= bin xor (a xor b);
    bout <= (not (a xor b) and bin)  or ((not a) and b);
end architecture rtl;
