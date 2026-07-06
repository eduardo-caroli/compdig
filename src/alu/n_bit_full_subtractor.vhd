library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_bit_full_subtractor is
    generic (
        n: integer := 4
    );
    port (
        a: in STD_LOGIC_VECTOR(n-1 downto 0);
        b: in STD_LOGIC_VECTOR(n-1 downto 0);
        bin: in STD_LOGIC;
        o: out STD_LOGIC_VECTOR(n-1 downto 0);
        bout: out STD_LOGIC
    );
end entity n_bit_full_subtractor;

architecture rtl of n_bit_full_subtractor is
    signal bs: STD_LOGIC_VECTOR(n-1 downto 0);

    component full_subtractor is
        port (
            a: in STD_LOGIC;
            b: in STD_LOGIC;
            bin: in STD_LOGIC;
            o: out STD_LOGIC;
            bout: out STD_LOGIC
        );
    end component;
begin
    full_subtractor_zero: full_subtractor port map(
        a => a(0),
        b => b(0),
        bin => bin, 
        o => o(0),
        bout => bs(0)
    );
    GEN_FULL_ADDERS: for i in 1 to n-1 generate
        full_subtractor_i: full_subtractor port map(
            a => a(i),
            b => b(i),
            bin => bs(i-1), 
            o => o(i),
            bout => bs(i)
        );
    end generate GEN_FULL_ADDERS;
    bout <= bs(n-1);
end architecture rtl;
