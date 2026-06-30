library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        --Sinais de controle
        clk: STD_LOGIC;
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
        overflow_f: out STD_LOGIC;
    );
end entity alu;

architecture rtl of alu is
    signal a_latch: in STD_LOGIC_VECTOR(7 downto 0);
    signal b_latch: in STD_LOGIC_VECTOR(7 downto 0);
    signal cmd_latch: in STD_LOGIC_VECTOR(3 downto 0);

    ------------ CARRY E SAIDA POR SINAL ------------
    ---- 8 BIT FULL ADDER
    signal o_adder: STD_LOGIC_VECTOR(7 downto 0);
    signal cout_adder: STD_LOGIC;

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
            a=>a_latch,
            b=>b_latch,
            cin=>cin,
            o=>o_adder,
            cout=>cout_adder
        );

    ---- LOGIC UNIT
    logic_unit : entity work.logic_unit
        generic map(
            n => 8
        )
        port map(
            a => a_latch,
            b => b_latch,
            cmd => cmd,
            o => o_logic
        );

    process(clk)
        --definindo latches
        if cmd = "0010" or cmd = "0011" then --inc ou dec: operando b = 1
            b_latch <= "00000001";
        else
            b_latch <= b;
        end if;
        a_latch <= a;
        cmd_latch <= cmd;

    begin
    end process;
    --Mux saida 
    with cmd select
        o <= o_adder    when cmd < "0010",                  -- RX + RY e RX + 1
             o_logic    when "0100" <= cmd and cmd < "1010" -- OPS LOGICAS
             (others => '0') when others;

    --Mux Carry Out
    with cmd select
        cout <= cout_adder when cmd < "0010",
                '0'        when others; 

    --Definindo flags
    zero_f <= '1' when a_latch = (others => '0') else '0';
    equal_f <= '1' when a_latch = b_latch else '0';
    greater_f <= '1' when a_latch > b_latch else '0';
    smaller_f <= '1' when a_latch < b_latch else '0';

end architecture rtl;
