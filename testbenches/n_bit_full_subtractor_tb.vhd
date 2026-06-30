library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_bit_full_subtractor_tb is
end entity;

architecture sim of n_bit_full_subtractor_tb is

    component n_bit_full_subtractor
        generic (
            n : integer
        );
        port (
            a : in  std_logic_vector(3 downto 0);
            b : in  std_logic_vector(3 downto 0);
            bin: in STD_LOGIC;
            o : out std_logic_vector(3 downto 0);
            bout: out STD_LOGIC
        );
    end component;

    signal a, b : std_logic_vector(3 downto 0);
    signal cin, cout: std_logic;
    signal y    : std_logic_vector(3 downto 0);

begin

    DUT : n_bit_full_subtractor
        generic map (
            n => 4
        )
        port map (
            a => a,
            b => b,
            bin => cin,
            o => y,
            bout => cout
        );

    process
    begin

        a <= "0000";
        b <= "0000";
        cin <= '0';
        wait for 10 ns;
        assert y = "0000";
        assert cout = '0';
        wait for 10 ns;

        a <= "0010";
        b <= "0010";
        cin <= '0';
        wait for 10 ns;
        assert y = "0000";
        assert cout = '0';
        wait for 10 ns;

        a <= "1001";
        b <= "1000";
        cin <= '0';
        wait for 10 ns;
        assert y = "0001";
        assert cout = '0';
        wait for 10 ns;

        report "==> ALL FULL_SUBTRACTOR TESTS PASSED";
        wait;
    end process;

end architecture;
