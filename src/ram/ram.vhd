library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ram_pkg.byte_array_t;

entity ram is
    port(
        clk:        in      STD_LOGIC;
        we:         in      STD_LOGIC;
        data:       in      STD_LOGIC_VECTOR(7 downto 0);
        addr:       in      UNSIGNED(7 downto 0);

        data_out:   out     STD_LOGIC_VECTOR(7 downto 0);
        ref_out:    out     STD_LOGIC_VECTOR(7 downto 0)
    );
end entity ram;

architecture rtl of ram is
    signal memory: byte_array_t(255 downto 0) := (
        0 => x"83",
        1 => x"01", --LD A, 0x01
        2 => x"87",
        3 => x"01", --LD B, 0x01
        4 => x"01", --ADD A, B
        5 => x"8B",
        6 => x"FF", --LD C, 0xFF
        7 => x"A2", --STR A,C
        others => x"00"
    ); --256 posicoes de 8 bits
begin
    process(clk)
        variable    addr_int: integer;
    begin
        if rising_edge(clk) then
            addr_int := to_integer(addr);
            if we = '1' then
                memory(addr_int) <= data;
                data_out <= data;
            else
                data_out <= memory(addr_int);
            end if;
        end if;
    end process;

    ref_out <= memory(255);
end architecture rtl;
