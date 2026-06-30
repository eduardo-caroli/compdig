library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
        clk:    in      STD_LOGIC;
        reset:  in      STD_LOGIC
    );
end entity control_unit;

architecture rtl of control_unit is
    --REGISTRADORES
    signal a:       STD_LOGIC_VECTOR(7 downto 0);
    signal b:       STD_LOGIC_VECTOR(7 downto 0);
    signal c:       STD_LOGIC_VECTOR(7 downto 0);
    signal d:       STD_LOGIC_VECTOR(7 downto 0);

    --REGISTRADORES DE CONTROLE
    signal pc:      STD_LOGIC_VECTOR(7 downto 0);
    signal ir:      STD_LOGIC_VECTOR(7 downto 0);
    signal sp:      STD_LOGIC_VECTOR(7 downto 0);
    signal mbr:     STD_LOGIC_VECTOR(7 downto 0);
    signal mar:     STD_LOGIC_VECTOR(7 downto 0);

    --FLAGS
    signal zero_f:  STD_LOGIC;
    signal equal_f:  STD_LOGIC;
    signal greater_f:  STD_LOGIC;
    signal smaller_f:  STD_LOGIC;
    signal overflow_f:  STD_LOGIC;
    --SAIDA DA ALU
    signal zero_f_out: STD_LOGIC;
    signal equal_f_out: STD_LOGIC;
    signal greater_f_out: STD_LOGIC;
    signal smaller_f_out: STD_LOGIC;
    signal overflow_f_out: STD_LOGIC;

    ------------ CONTROLE DA ALU ------------
    --REGISTER MUX
    signal rx_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal ry_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal rx:      STD_LOGIC_VECTOR(7 downto 0);
    signal ry:      STD_LOGIC_VECTOR(7 downto 0);
    signal alu_out: STD_LOGIC_VECTOR(7 downto 0);
    --COMANDO
    signal alu_cmd: STD_LOGIC_VECTOR(3 downto 0);
begin
--   ram : entity work.ram
--       port map(
--           clk => clk,
--           we  => we,
--           data => mbr,
--           addr => mar,
--           data_out => mbr
--       );
    ------------- ALU ------------
    --INSTANCIACAO
    alu : entity work.alu
        port map(
            cin => zero_f,
            a => rx,
            b => ry,
            cmd => alu_cmd,

            o => alu_out,

            zero_f => zero_f_out,
            equal_f => equal_f_out,
            greater_f => greater_f_out,
            smaller_f => smaller_f_out,
            overflow_f => overflow_f_out
        );

    --CONTROLE DA ALU
    alu_cmd <= ir(7 downto 4);

    with alu_cmd(3 downto 2) select
        rx <= a when "00",
              b when "01",
              c when "10",
              d when others;

    with alu_cmd(3 downto 2) select
        ry <= a when "00",
              b when "01",
              c when "10",
              d when others;

end architecture rtl;
