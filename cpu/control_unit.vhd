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
    signal sp_p_1:  STD_LOGIC_VECTOR(7 downto 0);
    signal mbr:     STD_LOGIC_VECTOR(7 downto 0);
    signal mar:     STD_LOGIC_VECTOR(7 downto 0);

    --FLAGS
    signal zero_f:  STD_LOGIC;
    signal equal_f:  STD_LOGIC;
    signal greater_f:  STD_LOGIC;
    signal smaller_f:  STD_LOGIC;
    signal overflow_f:  STD_LOGIC;

    ------------ CONTROLE DA RAM ------------
    --CONTROLE DA RAM
    signal clk_fwd:     STD_LOGIC;
    signal we:          STD_LOGIC;
    signal mar_u:       UNSIGNED(7 downto 0);
    --SAIDA DA RAM
    signal ram_data_in: STD_LOGIC_VECTOR(7 downto 0);
    signal ram_data_out: STD_LOGIC_VECTOR(7 downto 0);

    ------------ CONTROLE DA ALU ------------
    --REGISTER MUX
    signal rx:      STD_LOGIC_VECTOR(7 downto 0); --Durante "leitura da instrucao", valor de RX
    signal rx_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal ry:      STD_LOGIC_VECTOR(7 downto 0); --e de RY
    signal ry_sel:  STD_LOGIC_VECTOR(1 downto 0);
    signal alu_a:   STD_LOGIC_VECTOR(7 downto 0); --Entrada A da ALU
    signal alu_b:   STD_LOGIC_VECTOR(7 downto 0); --Entrada B da ALU
    signal alu_out: STD_LOGIC_VECTOR(7 downto 0);
    --COMANDO
    signal alu_cmd: STD_LOGIC_VECTOR(3 downto 0);
    --SAIDA DA ALU
    signal zero_f_out: STD_LOGIC;
    signal equal_f_out: STD_LOGIC;
    signal greater_f_out: STD_LOGIC;
    signal smaller_f_out: STD_LOGIC;
    signal overflow_f_out: STD_LOGIC;

    ------------ VIRTUAL INSTRUCTION DECODER ------------
    --ENTRADAS
    signal curr_instruction        : STD_LOGIC_VECTOR(7 downto 0);
    --SAIDAS
    signal virtual_instruction: STD_LOGIC_VECTOR(4 downto 0);
    signal is_two_step_instruction: STD_LOGIC;
    signal is_arith_logic_instruction: STD_LOGIC;

    ------------ CONTROLE INTERNO -------------
    type    cpu_state   is  (FETCH_FIRST_INSTRUCTION, CYCLE_ONE, CYCLE_TWO);
    signal  curr_state  :   cpu_state;
    type    instruction_t is(
            INST_ADD,INST_SUB,INST_INC,INST_DEC,INST_AND,
            INST_OR,
            INST_NOT,
            INST_XOR,
            INST_ROL,
            INST_ROR,
            INST_LSL,
            INST_LSR,
            INST_PUSH,
            INST_POP,
            INST_ST,
            INST_LD,
            INST_LDR,
            INST_STR,
            INST_MOV,
            INST_JMP,
            INST_JMPR,
            INST_BZ,
            INST_BNZ,
            INST_BCS,
            INST_BCC,
            INST_BEQ,
            INST_BNEQ,
            INST_BGT,
            INST_BLT,
            INST_HALT,
            INVALID
      );
    signal  instruction_type : instruction_t;


begin
    ------------ VIRTUAL INSTRUCTION DECODER ------------
    --INSTANCIACAO
    vi_decoder : entity work.virtual_instruction_decoder
        port map(
            opcode => curr_instruction(7 downto 4),
            suffix => curr_instruction(1 downto 0),
            rx     => curr_instruction(3 downto 2),
            virtual_instruction => virtual_instruction,
            is_two_step => is_two_step_instruction,
            is_arith_logic_instruction => is_arith_logic_instruction
        );

    ------------- ALU ------------
    --INSTANCIACAO
    alu : entity work.alu
        port map(
            cin => overflow_f,
            a => alu_a,
            b => alu_b,
            cmd => alu_cmd,

            o => alu_out,

            zero_f => zero_f_out,
            equal_f => equal_f_out,
            greater_f => greater_f_out,
            smaller_f => smaller_f_out,
            overflow_f => overflow_f_out
        );

    ------------ RAM ------------
    --INSTANCIACAO
     ram : entity work.ram
         port map(
             clk => clk_fwd,
             we  => we,
             data => ram_data_in,
             addr => mar_u,
             data_out => ram_data_out
         );

     mar_u <= unsigned(mar);

    ------------ PROCESSO ------------
     process(clk, reset)
        variable result: STD_LOGIC_VECTOR(7 downto 0);
        variable pc_p_1: STD_LOGIC_VECTOR := (others => '0');

        ------------ PROCEDURES ------------
        procedure update_pc_with_variable(
            variable new_pc: in   STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            --Buscar instrucao
            mar <= new_pc;
            we <= '0';
            --Atualizando SP: Incrementar
            alu_cmd <= "0010";
            alu_a <= new_pc;
            pc <= new_pc;
        end procedure update_pc_with_variable;

        procedure update_pc_with_signal(
            signal new_pc: in   STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            --Buscar instrucao
            mar <= new_pc;
            we <= '0';
            --Atualizando SP: Incrementar
            alu_cmd <= "0010";
            alu_a <= new_pc;
            pc <= new_pc;
        end procedure update_pc_with_signal;

        procedure update_register(
            signal r_sel: in STD_LOGIC_VECTOR(1 downto 0);
            signal value: in STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            if r_sel = "00" then
               a <= value;
            elsif r_sel = "01" then
               b <= value;
            elsif r_sel = "10" then
               c <= value;
            else
               d <= value;
             end if;
        end procedure update_register;

        procedure write_to_ram(
            signal data: STD_LOGIC_VECTOR(7 downto 0);
            signal address: STD_LOGIC_VECTOR(7 downto 0)
        ) is
        begin
            we <= '1';
            mar <= address;
            ram_data_in <= data;
        end procedure write_to_ram;


     begin
         if reset = '1' then
            curr_state <= FETCH_FIRST_INSTRUCTION;
            --INICIALIZANDO REGISTRADORES E FLAGS
            a <= (others => '0');
            b <= (others => '0');
            c <= (others => '0');
            d <= (others => '0');
            pc <= (others => '0');
            ir <= (others => '0');
            sp <= (0 => '0', others => '1');
            sp_p_1 <= (0 => '0', others => '1');
            mbr <= (others => '0');
            mar <= (others => '0');
            zero_f <= '0';
            equal_f <= '0';
            greater_f <= '0';
            smaller_f <= '0';
            overflow_f <= '0';
         elsif rising_edge(clk) then
            if curr_state = FETCH_FIRST_INSTRUCTION then
                update_pc_with_signal(pc);
                curr_state <= CYCLE_ONE;
            elsif curr_state = CYCLE_ONE then
                --Atualizando IR com a instrução atual
                ir <= ram_data_out;
                --Zerando we para evitar escritas espurias
                --caso we = '1' no fim do ciclo passado
                we <= '0';
                --Ao final de uma instrucao sempre atualizamos pc_p_1
                pc_p_1 := alu_out;
                if is_two_step_instruction = '0' then
                    if instruction_type = INST_STR THEN
                        write_to_ram(rx, ry);
                    elsif instruction_type = INST_MOV THEN
                        update_register(rx_sel, ry);
                    end if;
                    --Setamos pc aqui porque as outras instrucoes (que alteram o valor 
                    --do sinal) poderao sobrescreve-las
                    --Abaixo desta linha todas as instrucoes que podem alterar o valor de pc
                    --Abaixo implementamos todas as instruções de jump
                    if instruction_type = INST_HALT then
                        update_pc_with_signal(pc);
                    else
                        update_pc_with_variable(pc_p_1);
                    end if;
                    if (
                        (instruction_type = INST_JMPR) or (instruction_type = INST_BZ and zero_f= '1') or
                        (instruction_type = INST_BNZ and zero_f = '0') or (instruction_type = INST_BCC and overflow_f = '0') or
                        (instruction_type = INST_BCS and overflow_f = '1') or (instruction_type =  INST_BEQ and equal_f = '1') or
                        (instruction_type = INST_BNEQ and equal_f = '0') or (instruction_type = INST_BGT and greater_f = '1') or
                        (instruction_type = INST_BLT and smaller_f = '1')
                    ) then
                        update_pc_with_signal(rx);
                    end if;
                    curr_state <= CYCLE_ONE; -- NAO MUDA
                else --Instrucao deve ser executada em dois ciclos
                    if is_arith_logic_instruction = '1'then
                       alu_a <= rx;
                       alu_b <= ry;
                       alu_cmd <= virtual_instruction(3 downto 0);
                       curr_state <= CYCLE_TWO;
                    elsif instruction_type = INST_PUSH then
                        --No acso do PUSH, precisamos  atualizar SP.
                        alu_cmd <= "0011"; --DEC
                        alu_a <= sp;
                        sp_p_1 <= sp;
                        --e escrever algo na pilha.
                        write_to_ram(rx, sp);
                    --Se entra qui, a instrucao exige acesso a memoria (leitura)
                    --Aqui definimos o endereco de acesso, apenas.
                    --Caso push ou pop, tambem precisamos incrementar / decrementar
                    --SP.
                    elsif instruction_type = INST_POP then
                        mar <= sp_p_1;
                        we <= '0';
                        --Atualizando SP: Incrementar
                        alu_cmd <= "0010";
                        alu_a <= sp_p_1;
                        sp <= sp_p_1;
                    --Nas 2 instrucoes abaixo atualizamos parcialmente PC
                    --Porque no segundo ciclo soma-se apenas 1
                    --e a instrucao exige pc <= pc + 2
                    elsif instruction_type = INST_ST then
                        pc <= pc_p_1;
                        alu_a <= pc_p_1;
                        alu_cmd <= "0010";
                    elsif instruction_type = INST_LD then
                        pc <= pc_p_1;
                        alu_a <= pc_p_1;
                        alu_cmd <= "0010";
                        mar <= pc_p_1;
                        we <= '0';
                    elsif instruction_type = INST_LDR then
                        mar <= ry;
                        we <= '0';
                    elsif instruction_type = INST_JMP then
                        mar <= pc_p_1;
                        we <= '0';
                    end if;
                end if;
            elsif curr_state = CYCLE_TWO then
                if is_arith_logic_instruction = '1' then
                    --Atualizamos o registrador com o resultado da ALU
                    update_register(rx_sel, alu_out);
                    --Atualizamos as flags
                    zero_f <= zero_f_out;
                    equal_f <= equal_f_out;
                    overflow_f <= overflow_f_out;
                    greater_f <= greater_f_out;
                    smaller_f <= smaller_f_out;
                    --E atualizamos PC
                    update_pc_with_variable(pc_p_1);
                elsif instruction_type = INST_PUSH then
                    --Atualizamos SP
                    sp <= alu_out;
                    --E atualizamos pc
                    update_pc_with_variable(pc_p_1);
                elsif instruction_type = INST_POP then
                    --Atualizamos SP+1
                    sp_p_1 <= alu_out;
                    --Escrevemos MEM[SP+1] em RX
                    update_register(rx_sel, ram_data_out);
                    update_pc_with_variable(pc_p_1);
                elsif instruction_type = INST_ST then
                    --Atualizamos pc_p_1 com (PC + 1)+1
                    pc_p_1 := alu_out;
                    --Aqui, sp já é sp+1. escrevemos RX para MEM[SP+1]
                    write_to_ram(rx, pc);
                    --E atualizamos pc <- PC + 2
                    update_pc_with_variable(pc_p_1);
                elsif instruction_type = INST_LD then
                    --Atualizamos pc_p_1 com (PC + 1)+1
                    pc_p_1 := alu_out;
                    --Atualizamos RX com o valor buscado da memória
                    update_register(rx_sel, ram_data_out);
                    --Atualizar PC <- PC+2
                    update_pc_with_variable(pc_p_1);
                 elsif instruction_type = INST_LDR then
                    --Escrevemos o valor MEM[RY] em RX
                    update_register(rx_sel, ram_data_out);
                    --E atualizamos PC <- PC + 1
                    update_pc_with_variable(pc_p_1);
                elsif instruction_type = INST_JMP then
                    update_pc_with_signal(ram_data_out);
                end if;
            end if;
         end if;
     end process;

     clk_fwd <= not clk;

    rx_sel <= curr_instruction(3 downto 2);

    ry_sel <= curr_instruction(1 downto 0);

     with rx_sel select rx <=
        a when "00",
        b when "01",
        c when "10",
        d when others;

     with ry_sel select ry <=
        a when "00",
        b when "01",
        c when "10",
        d when others;

    with curr_state select curr_instruction <=
        ram_data_out when CYCLE_ONE,
        ir           when CYCLE_TWO,
        (others => '0') when others;

    with virtual_instruction select
        instruction_type <=
            INST_ADD  when "00000",
            INST_SUB  when "00001",
            INST_INC  when "00010",
            INST_DEC  when "00011",
            INST_AND  when "00100",
            INST_OR   when "00101",
            INST_NOT  when "00110",
            INST_XOR  when "00111",
            INST_ROL  when "01000",
            INST_ROR  when "01001",
            INST_LSL  when "01010",
            INST_LSR  when "01011",
            INST_PUSH when "01100",
            INST_POP  when "01101",
            INST_ST   when "01110",
            INST_LD   when "01111",
            INST_LDR  when "10000",
            INST_STR  when "10001",
            INST_MOV  when "10010",
            INST_JMP  when "10011",
            INST_JMPR when "10100",
            INST_BZ   when "10101",
            INST_BNZ  when "10110",
            INST_BCS  when "10111",
            INST_BCC  when "11000",
            INST_BEQ  when "11001",
            INST_BNEQ when "11010",
            INST_BGT  when "11011",
            INST_BLT  when "11100",
            INST_HALT when "11101",
            INVALID   when others;

end architecture rtl;
