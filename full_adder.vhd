library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
    port (
        a: in STD_LOGIC;
        b: in STD_LOGIC;
        cin: in STD_LOGIC;
        o: out STD_LOGIC;
        cout: out STD_LOGIC
    );
end entity full_adder;

architecture rtl of full_adder is
begin
    o <= cin xor (a xor b);
    cout <= (a and b) or (cin and (a xor b));
end architecture rtl;
