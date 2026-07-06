library ieee;
use ieee.std_logic_1164.all;

entity virtual_instruction_decoder is
    port (
        opcode              : in  std_logic_vector(3 downto 0);
        suffix              : in  std_logic_vector(1 downto 0);
        rx                  : in  std_logic_vector(1 downto 0);
        virtual_instruction : out std_logic_vector(4 downto 0);
        is_two_step         : out std_logic;
        is_arith_logic_instruction : out std_logic
    );
end entity;

architecture rtl of virtual_instruction_decoder is

    type opcode_type_t is (
        OP_ADD,
        OP_SUB,
        OP_INC,
        OP_AND,
        OP_OR,
        OP_NOT,
        OP_XOR,
        OP_ROL,
        OP_PUSH,
        OP_LDR,
        OP_STR,
        OP_MOV,
        OP_JMP,
        OP_BCS,
        OP_BGT,
        OP_HALT
    );

    signal opcode_type : opcode_type_t;
    signal vi          : std_logic_vector(4 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Opcode decoder
    ----------------------------------------------------------------------------
    with opcode select
        opcode_type <=
            OP_ADD  when "0000",
            OP_SUB  when "0001",
            OP_INC  when "0010",
            OP_AND  when "0011",
            OP_OR   when "0100",
            OP_NOT  when "0101",
            OP_XOR  when "0110",
            OP_ROL  when "0111",
            OP_PUSH when "1000",
            OP_LDR  when "1001",
            OP_STR  when "1010",
            OP_MOV  when "1011",
            OP_JMP  when "1100",
            OP_BCS  when "1101",
            OP_BGT  when "1110",
            OP_HALT when others;

    ----------------------------------------------------------------------------
    -- Virtual instruction decoder
    ----------------------------------------------------------------------------
    process(opcode_type, suffix)
    begin
        case opcode_type is

            when OP_ADD =>
                vi <= "00000";    -- ADD

            when OP_SUB =>
                vi <= "00001";    -- SUB

            when OP_INC =>
                case suffix is
                    when "00" =>
                        vi <= "00010";    -- INC
                    when "01" =>
                        vi <= "00011";    -- DEC
                    when others =>
                        vi <= "11111";    -- Invalid
                end case;

            when OP_AND =>
                vi <= "00100";    -- AND

            when OP_OR =>
                vi <= "00101";    -- OR

            when OP_NOT =>
                if suffix = "00" then
                    vi <= "00110";    -- NOT
                else
                    vi <= "11111";
                end if;

            when OP_XOR =>
                vi <= "00111";    -- XOR

            when OP_ROL =>
                case suffix is
                    when "00" =>
                        vi <= "01000";    -- ROL
                    when "01" =>
                        vi <= "01001";    -- ROR
                    when "10" =>
                        vi <= "01010";    -- LSL
                    when others =>
                        vi <= "01011";    -- LSR
                end case;

            when OP_PUSH =>
                case suffix is
                    when "00" =>
                        vi <= "01100";    -- PUSH
                    when "01" =>
                        vi <= "01101";    -- POP
                    when "10" =>
                        vi <= "01110";    -- ST
                    when others =>
                        vi <= "01111";    -- LD
                end case;

            when OP_LDR =>
                vi <= "10000";    -- LDR

            when OP_STR =>
                vi <= "10001";    -- STR

            when OP_MOV =>
                vi <= "10010";    -- MOV

            when OP_JMP =>
                case suffix is
                    when "00" =>
                        vi <= "10011";    -- JMP
                    when "01" =>
                        vi <= "10100";    -- JMPR
                    when "10" =>
                        vi <= "10101";    -- BZ
                    when others =>
                        vi <= "10110";    -- BNZ
                end case;

            when OP_BCS =>
                case suffix is
                    when "00" =>
                        vi <= "10111";    -- BCS
                    when "01" =>
                        vi <= "11000";    -- BCC
                    when "10" =>
                        vi <= "11001";    -- BEQ
                    when others =>
                        vi <= "11010";    -- BNEQ
                end case;

            when OP_BGT =>
                case suffix is
                    when "00" =>
                        vi <= "11011";    -- BGT
                    when "01" =>
                        vi <= "11100";    -- BLT
                    when others =>
                        vi <= "11111";    -- Invalid
                end case;

            when OP_HALT =>
                if rx = "00" and suffix = "00" then
                    vi <= "11101";    -- HALT
                else
                    vi <= "11111";
                end if;

        end case;
    end process;

    virtual_instruction <= vi;
    is_two_step <= '1' when
           (vi = "00000") or -- ADD
           (vi = "00001") or -- SUB
           (vi = "00010") or -- INC
           (vi = "00011") or -- DEC
           (vi = "00100") or -- AND
           (vi = "00101") or -- OR
           (vi = "00110") or -- NOT
           (vi = "00111") or -- XOR
           (vi = "01000") or -- ROL
           (vi = "01001") or -- ROR
           (vi = "01010") or -- LSL
           (vi = "01011") or -- LSR
           (vi = "01100") or -- PUSH
           (vi = "01101") or -- POP
           (vi = "01110") or -- ST
           (vi = "01111") or -- LD
           (vi = "10000") or -- LDR
           (vi = "10001") or -- STR
           (vi = "10011")    -- JMP
           else '0';

     is_arith_logic_instruction <= '1' when 
           (vi = "00000") or -- ADD
           (vi = "00001") or -- SUB
           (vi = "00010") or -- INC
           (vi = "00011") or -- DEC
           (vi = "00100") or -- AND
           (vi = "00101") or -- OR
           (vi = "00110") or -- NOT
           (vi = "00111") or -- XOR
           (vi = "01000") or -- ROL
           (vi = "01001") or -- ROR
           (vi = "01010") or -- LSL
           (vi = "01011")    -- LSR
           else '0';
end architecture;
