library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_bit_full_adder_tb is
end entity;

architecture sim of n_bit_full_adder_tb is

    component n_bit_full_adder
        generic (
            n : integer
        );
        port (
            a : in  std_logic_vector(3 downto 0);
            b : in  std_logic_vector(3 downto 0);
            cin: in STD_LOGIC;
            o : out std_logic_vector(3 downto 0);
            cout: out STD_LOGIC
        );
    end component;

    signal a, b : std_logic_vector(3 downto 0);
    signal cin, cout: std_logic;
    signal y    : std_logic_vector(3 downto 0);

begin

    DUT : n_bit_full_adder
        generic map (
            n => 4
        )
        port map (
            a => a,
            b => b,
            cin => cin,
            o => y,
            cout => cout
        );

    process
    begin

        a <= "0000";
        b <= "0001";
        cin <= '0';
        wait for 10 ns;
        assert y = "0001";
        assert cout = '0';
        wait for 10 ns;

        a <= "0000";
        b <= "0001";
        cin <= '1';
        wait for 10 ns;
        assert y = "0010";
        assert cout = '0';
        wait for 10 ns;

        a <= "1000";
        b <= "1000";
        cin <= '0';
        wait for 10 ns;
        assert y = "0000";
        assert cout = '1';
        wait for 10 ns;

        report "==> ALL FULL_ADDER TESTS PASSED";
        wait;
    end process;

end architecture;
