library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        --Sinais de controle
        reset: STD_LOGIC;

        --Entradas
        cin: in STD_LOGIC;
        a: in STD_LOGIC_VECTOR(7 downto 0);
        b: in STD_LOGIC_VECTOR(7 downto 0);
        cmd: in STD_LOGIC_VECTOR(3 downto 0); --12 instrucoes possiveis

        --Saida
        o: out STD_LOGIC_VECTOR(7 downto 0);

        --Flags
        zero_f: out STD_LOGIC;
        equal_f: out STD_LOGIC;
        greater_f: out STD_LOGIC;
        smaller_f: out STD_LOGIC;
        overflow_f: out STD_LOGIC
    );
end entity alu;

architecture rtl of alu is
    signal b_latch: STD_LOGIC_VECTOR(7 downto 0);

    ------------ CARRY E SAIDA POR SINAL ------------
    ---- 8 BIT FULL ADDER
    signal o_adder: STD_LOGIC_VECTOR(7 downto 0);
    signal cout_adder: STD_LOGIC;

    ---- 8 BIT FULL SUBTRACTOR
    signal o_subtractor: STD_LOGIC_VECTOR(7 downto 0);
    signal cout_subtractor: STD_LOGIC;

    --- LOGIC UNIT
    signal o_logic: STD_LOGIC_VECTOR(7 downto 0);
begin

    ------------ SUBCIRCUITOS
    ---- 8 BIT FULL ADDER
    eight_bit_full_adder : entity work.n_bit_full_adder
        generic map(
            n => 8
        )
        port map(
            a=>a,
            b=>b_latch,
            cin=>cin,
            o=>o_adder,
            cout=>cout_adder
        );

    eight_bit_full_subtractor : entity work.n_bit_full_subtractor
        generic map(
            n => 8
        )
        port map(
            a=>a,
            b=>b_latch,
            bin=>cin,
            o=>o_subtractor,
            bout=>cout_subtractor
        );

    ---- LOGIC UNIT
    logic_unit : entity work.logic_unit
        generic map(
            n => 8
        )
        port map(
            a => a,
            b => b_latch,
            cmd => cmd,
            o => o_logic
        );
    -- B Latch - Quando inc ou dec, b_latch = 1. cc, b_latch = b
    with cmd select
        b_latch <= "00000001" when "0010", --inc
                   "00000001" when "0011", --dec
                   b   when others;
                    

    --Mux saida 
    with cmd select
        o <=    o_adder when "0000",
                o_subtractor when "0001",
                o_adder when "0010",
                o_subtractor when "0011",
                o_logic when "0100",
                o_logic when "0101",
                o_logic when "0110",
                o_logic when "0111",
                o_logic when "1000",
                o_logic when "1001",
                o_logic when "1010",
                o_logic when "1011",
                (others => '0') when others;

    --Mux Carry Out
    with cmd select
        overflow_f <=   cout_adder when "0000",
                        cout_subtractor when "0001",
                        cout_adder when "0010",
                        cout_subtractor when "0011",
                        '0' when others;

    --Definindo flags
    zero_f <= '1' when a = (others => '0') else '0';
    equal_f <= '1' when a = b_latch else '0';
    greater_f <= '1' when a > b_latch else '0';
    smaller_f <= '1' when a < b_latch else '0';

end architecture rtl;
