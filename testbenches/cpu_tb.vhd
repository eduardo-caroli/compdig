library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ram_pkg.byte_array_t;

entity composition_tb is
end entity;

architecture tb of composition_tb is

    constant CLK_PERIOD : time := 20 ns;
    constant RAM_PRELOAD_LEN : integer := 1;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    signal zero_f     : std_logic;
    signal equal_f    : std_logic;
    signal greater_f  : std_logic;
    signal smaller_f  : std_logic;
    signal overflow_f : std_logic;

    signal ram_preload : byte_array_t(0 to RAM_PRELOAD_LEN-1) :=
    (
        others => x"00"
    );

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    dut : entity work.composition
        generic map (
            ram_preload_len => RAM_PRELOAD_LEN
        )
        port map (
            clk         => clk,
            reset       => reset,
            ram_preload => ram_preload,

            zero_f      => zero_f,
            equal_f     => equal_f,
            greater_f   => greater_f,
            smaller_f   => smaller_f,
            overflow_f  => overflow_f
        );

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------
    stim : process
    begin
        reset <= '1';
        wait for 2*CLK_PERIOD;

        reset <= '0';

        -- Let the CPU execute forever
        wait;
    end process;

end architecture;
