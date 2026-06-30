
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity;

architecture sim of alu_tb is

    signal reset       : std_logic := '0';
    signal cin         : std_logic := '0';
    signal a           : std_logic_vector(7 downto 0);
    signal b           : std_logic_vector(7 downto 0);
    signal cmd         : std_logic_vector(3 downto 0);

    signal o           : std_logic_vector(7 downto 0);

    signal zero_f      : std_logic;
    signal equal_f     : std_logic;
    signal greater_f   : std_logic;
    signal smaller_f   : std_logic;
    signal overflow_f  : std_logic;

begin

    dut : entity work.alu
    port map(
        reset => reset,
        cin => cin,
        a => a,
        b => b,
        cmd => cmd,
        o => o,
        zero_f => zero_f,
        equal_f => equal_f,
        greater_f => greater_f,
        smaller_f => smaller_f,
        overflow_f => overflow_f
    );

    process
    begin

        --------------------------------------------------------------------
        -- ADD
        --------------------------------------------------------------------
        cin <= '0';
        cmd <= "0000";

        a <= x"05"; b <= x"03"; wait for 10 ns;
        assert o = x"08" report "ADD caso 1 falhou" severity error;

        a <= x"FF"; b <= x"01"; wait for 10 ns;
        assert o = x"00" report "ADD caso 2 falhou" severity error;
        assert overflow_f = '1' report "ADD carry falhou" severity error;

        a <= x"7F"; b <= x"01"; wait for 10 ns;
        assert o = x"80" report "ADD caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- SUB
        --------------------------------------------------------------------
        cmd <= "0001";

        a <= x"08"; b <= x"03"; wait for 10 ns;
        assert o = x"05" report "SUB caso 1 falhou" severity error;

        a <= x"00"; b <= x"01"; wait for 10 ns;
        assert o = x"FF" report "SUB caso 2 falhou" severity error;

        a <= x"55"; b <= x"55"; wait for 10 ns;
        assert o = x"00" report "SUB caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- INC
        --------------------------------------------------------------------
        cmd <= "0010";

        a <= x"00"; wait for 10 ns;
        assert o = x"01" report "INC caso 1 falhou" severity error;

        a <= x"0F"; wait for 10 ns;
        assert o = x"10" report "INC caso 2 falhou" severity error;

        a <= x"FF"; wait for 10 ns;
        assert o = x"00" report "INC caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- DEC
        --------------------------------------------------------------------
        cmd <= "0011";

        a <= x"05"; wait for 10 ns;
        assert o = x"04" report "DEC caso 1 falhou" severity error;

        a <= x"01"; wait for 10 ns;
        assert o = x"00" report "DEC caso 2 falhou" severity error;

        a <= x"00"; wait for 10 ns;
        assert o = x"FF" report "DEC caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- AND
        --------------------------------------------------------------------
        cmd <= "0100";

        a <= x"F0"; b <= x"0F"; wait for 10 ns;
        assert o = x"00" report "AND caso 1 falhou" severity error;

        a <= x"AA"; b <= x"CC"; wait for 10 ns;
        assert o = x"88" report "AND caso 2 falhou" severity error;

        a <= x"FF"; b <= x"55"; wait for 10 ns;
        assert o = x"55" report "AND caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- OR
        --------------------------------------------------------------------
        cmd <= "0101";

        a <= x"F0"; b <= x"0F"; wait for 10 ns;
        assert o = x"FF" report "OR caso 1 falhou" severity error;

        a <= x"AA"; b <= x"55"; wait for 10 ns;
        assert o = x"FF" report "OR caso 2 falhou" severity error;

        a <= x"80"; b <= x"01"; wait for 10 ns;
        assert o = x"81" report "OR caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- NOT
        --------------------------------------------------------------------
        cmd <= "0110";

        a <= x"00"; wait for 10 ns;
        assert o = x"FF" report "NOT caso 1 falhou" severity error;

        a <= x"FF"; wait for 10 ns;
        assert o = x"00" report "NOT caso 2 falhou" severity error;

        a <= x"AA"; wait for 10 ns;
        assert o = x"55" report "NOT caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- XOR
        --------------------------------------------------------------------
        cmd <= "0111";

        a <= x"AA"; b <= x"55"; wait for 10 ns;
        assert o = x"FF" report "XOR caso 1 falhou" severity error;

        a <= x"FF"; b <= x"FF"; wait for 10 ns;
        assert o = x"00" report "XOR caso 2 falhou" severity error;

        a <= x"F0"; b <= x"0F"; wait for 10 ns;
        assert o = x"FF" report "XOR caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- ROL
        --------------------------------------------------------------------
        cmd <= "1000";

        a <= "10000001"; wait for 10 ns;
        assert o = "00000011" report "ROL caso 1 falhou" severity error;

        a <= "01010101"; wait for 10 ns;
        assert o = "10101010" report "ROL caso 2 falhou" severity error;

        a <= "11110000"; wait for 10 ns;
        assert o = "11100001" report "ROL caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- ROR
        --------------------------------------------------------------------
        cmd <= "1001";

        a <= "10000001"; wait for 10 ns;
        assert o = "11000000" report "ROR caso 1 falhou" severity error;

        a <= "01010100"; wait for 10 ns;
        assert o = "00101010" report "ROR caso 2 falhou" severity error;

        a <= "11110000"; wait for 10 ns;
        assert o = "01111000" report "ROR caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- LSL
        --------------------------------------------------------------------
        cmd <= "1010";

        a <= "00000001"; wait for 10 ns;
        assert o = "00000010" report "LSL caso 1 falhou" severity error;

        a <= "10000000"; wait for 10 ns;
        assert o = "00000000" report "LSL caso 2 falhou" severity error;

        a <= "10101010"; wait for 10 ns;
        assert o = "01010100" report "LSL caso 3 falhou" severity error;

        --------------------------------------------------------------------
        -- LSR
        --------------------------------------------------------------------
        cmd <= "1011";

        a <= "00000010"; wait for 10 ns;
        assert o = "00000001" report "LSR caso 1 falhou" severity error;

        a <= "00000001"; wait for 10 ns;
        assert o = "00000000" report "LSR caso 2 falhou" severity error;

        a <= "10101010"; wait for 10 ns;
        assert o = "01010101" report "LSR caso 3 falhou" severity error;

        report "Todos os testes passaram." severity note;
        wait;

    end process;

end architecture;
