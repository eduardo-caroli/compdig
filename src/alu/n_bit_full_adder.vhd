library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_bit_full_adder is
    generic (
        n: integer := 4
    );
    port (
        a: in STD_LOGIC_VECTOR(n-1 downto 0);
        b: in STD_LOGIC_VECTOR(n-1 downto 0);
        cin: in STD_LOGIC;
        o: out STD_LOGIC_VECTOR(n-1 downto 0);
        cout: out STD_LOGIC
    );
end entity n_bit_full_adder;

architecture rtl of n_bit_full_adder is
    signal cs: STD_LOGIC_VECTOR(n-1 downto 0);

    component full_adder is
        port (
            a: in STD_LOGIC;
            b: in STD_LOGIC;
            cin: in STD_LOGIC;
            o: out STD_LOGIC;
            cout: out STD_LOGIC
        );
    end component;
begin
    full_adder_zero: full_adder port map(
        a => a(0),
        b => b(0),
        cin => cin, 
        o => o(0),
        cout => cs(0)
    );
    GEN_FULL_ADDERS: for i in 1 to n-1 generate
        full_adder_i: full_adder port map(
            a => a(i),
            b => b(i),
            cin => cs(i-1), 
            o => o(i),
            cout => cs(i)
        );
    end generate GEN_FULL_ADDERS;
    cout <= cs(n-1);
end architecture rtl;
