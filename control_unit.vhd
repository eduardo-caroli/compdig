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

    --REGISTRADORES AUXILIARES
    signal virtual_instruction: STD_LOGIC_VECTOR(4 downto 0);

    --FLAGS
    signal zero_f:  STD_LOGIC;
    signal equal_f:  STD_LOGIC;
    signal greater_f:  STD_LOGIC;
    signal smaller_f:  STD_LOGIC;
    signal overflow_f:  STD_LOGIC;

    ------------ CONTROLE DA RAM ------------
    --CONTROLE DA ALU
    signal we:          STD_LOGIC;
    signal mar_u:       UNSIGNED(7 downto 0);
    --SAIDA DA RAM
    signal ram_data_in: STD_LOGIC_VECTOR(7 downto 0);
    signal ram_data_out: STD_LOGIC_VECTOR(7 downto 0);

    ------------ CONTROLE DA ALU ------------
    --REGISTER MUX
    signal rx_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal ry_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal rx:      STD_LOGIC_VECTOR(7 downto 0);
    signal ry:      STD_LOGIC_VECTOR(7 downto 0);
    signal alu_out: STD_LOGIC_VECTOR(7 downto 0);
    --COMANDO
    signal alu_cmd: STD_LOGIC_VECTOR(3 downto 0);
    --SAIDA DA ALU
    signal zero_f_out: STD_LOGIC;
    signal equal_f_out: STD_LOGIC;
    signal greater_f_out: STD_LOGIC;
    signal smaller_f_out: STD_LOGIC;
    signal overflow_f_out: STD_LOGIC;

    ------------ ESTADOS ------------
    --FI: Fetch Instruction
    --DI: Decode Instruction
    --CO: Calculate Operand
    --FO: Fetch Operand
    --EI: Execute Instruction
    --WO: Write Operand
    type    cpu_state   is  (FI, DI, CO, FO, EI, WO);
    signal  curr_state  :   cpu_state;
begin
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

    ------------ RAM ------------
    --INSTANCIACAO
     ram : entity work.ram
         port map(
             clk => clk,
             we  => we,
             data => ram_data_in,
             addr => mar_u,
             data_out => ram_data_out
         );

     mar_u <= unsigned(mar);

    ------------ PROCESSO ------------
     process(clk, reset)
        variable opcode: STD_LOGIC_VECTOR(3 downto 0);
        variable suffix: STD_LOGIC_VECTOR(1 downto 0);
        variable offset: UNSIGNED(4 downto 0);
        variable invalid_state: boolean;
        variable multi_suffix_instruction: boolean;
     begin
         if reset = '1' then
            curr_state <= FI;
            --INICIALIZANDO REGISTRADORES E FLAGS
            a <= (others => '0');
            b <= (others => '0');
            c <= (others => '0');
            d <= (others => '0');
            pc <= (others => '0');
            ir <= (others => '0');
            sp <= (others => '0');
            mbr <= (others => '0');
            mar <= (others => '0');
            zero_f <= '0';
            equal_f <= '0';
            greater_f <= '0';
            smaller_f <= '0';
            overflow_f <= '0';
         elsif rising_edge(clk) then
            -------------------------------------------------------------
            -- ESTADO :: Fetch Instruction
             if curr_state = FI then
                we <= '0';
                mar <= pc;
                pc <= std_logic_vector(1 + unsigned(pc));
            -------------------------------------------------------------
            --|
            -------------------------------------------------------------
            -- ESTADO :: Decode Instruction
             elsif curr_state = DI then
                ir <= ram_data_out;
                opcode := ram_data_out(7 downto 4);
                suffix := ram_data_out(1 downto 0);
                offset := (others => '0');
                -- Determinando offset
                if opcode > "0010" then offset := offset + 2 - 1; end if;
                if opcode > "0111" then offset := offset + 4 - 1; end if;
                if opcode > "1000" then offset := offset + 4 - 1; end if;
                if opcode > "1100" then offset := offset + 4 - 1; end if;
                if opcode > "1101" then offset := offset + 4 - 1; end if;
             invalid_state := (
                (opcode = "0010" and (suffix > "01"))
                or (opcode = "0101" and not (suffix = "00"))
                or (opcode = "1110" and (suffix > "01"))
                or (opcode = "1111" and not (ram_data_out = "11110000"))
             );
             multi_suffix_instruction := (
                (opcode = "0010") or (opcode = "0111")
                or (opcode = "1000") or (opcode = "1100")
                or (opcode = "1101") or (opcode = "1110")
             );

             if multi_suffix_instruction then
                offset := offset + resize(unsigned(suffix), 5);
             end if;

             if invalid_state then
                virtual_instruction <= (others => '1');
             else
                virtual_instruction <= std_logic_vector(
                    resize(unsigned(opcode), 5) + offset
                );
             end if;
            -------------------------------------------------------------
            --|
            -------------------------------------------------------------
            -- ESTADO :: Calculate Operand
             elsif curr_state = CO then
            -------------------------------------------------------------
             elsif curr_state = FO then
             elsif curr_state = EI then
             elsif curr_state = WO then
             end if;
         end if;
     end process;

end architecture rtl;
