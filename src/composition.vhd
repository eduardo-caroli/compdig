library ieee;

use ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;

library work;
use work.ram_pkg.byte_array_t;

entity composition is
    generic(
        ram_preload_len: integer
    );
    port (
        clk     :       in      STD_LOGIC;
        reset   :       in      STD_LOGIC;
        ram_preload:    in      byte_array_t(ram_preload_len-1 downto 0);

        zero_f  :       out     STD_LOGIC;
        equal_f :       out     STD_LOGIC;
        greater_f   :   out     STD_LOGIC;
        smaller_f   :   out     STD_LOGIC;
        overflow_f  :   out     STD_LOGIC;
        ref_data    :   out     STD_LOGIC_VECTOR(7 downto 0);

        --DEBUG
        a_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        b_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        c_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        d_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        pc_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        ir_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        mar_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        sp_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        sp_p_1_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        mbr_out       :   out     STD_LOGIC_VECTOR(7 downto 0);
        is_two_step_instruction_out: out STD_LOGIC;
        we:     out STD_LOGIC
    );
end entity;

architecture compositional of composition is
    ------------ ALU ------------
    signal alu_a        :       STD_LOGIC_VECTOR(7 downto 0);
    signal alu_b        :       STD_LOGIC_VECTOR(7 downto 0);
    signal alu_cmd      :       STD_LOGIC_VECTOR(3 downto 0);
    signal alu_out      :       STD_LOGIC_VECTOR(7 downto 0);
    signal zero_f_alu		    :		STD_LOGIC;
    signal equal_f_alu		    :		STD_LOGIC;
    signal greater_f_alu		:		STD_LOGIC;
    signal smaller_f_alu		:		STD_LOGIC;
    signal overflow_f_alu		:		STD_LOGIC;

    ------------ RAM ------------
    signal clk_fwd      :       STD_LOGIC;
    signal ram_we       :       STD_LOGIC;
    signal ram_data_in  :       STD_LOGIC_VECTOR(7 downto 0);
    signal ram_addr     :       UNSIGNED(7 downto 0);
    signal ram_data_out :       STD_LOGIC_VECTOR(7 downto 0);

    ------------ INTERNAL CONTROL ------------
    type state is (LOAD_PRESET, RUNNING);
    signal curr_state : state;
    signal preset_ctr : UNSIGNED(ram_preload_len - 1 downto 0);
begin
    cpu : entity work.control_unit
        port map(
            clk => clk,
            reset => reset,

            we => ram_we,
            mar_u => ram_addr,
            ram_data_in => ram_data_in,
            ram_data_out => ram_data_out,

            alu_a => alu_a,
            alu_b => alu_b,
            alu_out => alu_out,
            alu_cmd => alu_cmd,
            zero_f_out => zero_f_alu,
            equal_f_out => equal_f_alu,
            greater_f_out => greater_f_alu,
            smaller_f_out => smaller_f_alu,
            overflow_f_out => overflow_f_alu,

            --DEBUG
            a_out => a_out,
            b_out => b_out,
            c_out => c_out,
            d_out => d_out,
            pc_out => pc_out,
            ir_out => ir_out,
            mar_out => mar_out,
            sp_out => sp_out,
            sp_p_1_out => sp_p_1_out,
            mbr_out => mbr_out,
            is_two_step_instruction_out => is_two_step_instruction_out
        );

    alu : entity work.alu
        port map(
            cin => overflow_f_alu,
            a => alu_a,
            b => alu_b,
            cmd => alu_cmd,

            o => alu_out,
            zero_f => zero_f_alu,
            equal_f => equal_f_alu,
            greater_f => greater_f_alu,
            smaller_f => smaller_f_alu,
            overflow_f => overflow_f_alu
        );

    ram : entity work.ram
        port map(
            clk => clk_fwd,
            we  => ram_we,
            data => ram_data_in,
            addr => ram_addr,
            data_out => ram_data_out,
            ref_out => ref_data
        );

    clk_fwd <= not clk;
    we <= ram_we;
end architecture;
