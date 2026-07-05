library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    port(
        clk:        in      STD_LOGIC;
        we:         in      STD_LOGIC;
        data:       in      STD_LOGIC_VECTOR(7 downto 0);
        addr:       in      UNSIGNED(7 downto 0);

        data_out:   out     STD_LOGIC_VECTOR(7 downto 0)
    );
end entity ram;

architecture rtl of ram is
    signal memory: STD_LOGIC_VECTOR(256*8 - 1 downto 0); --256 posicoes de 8 bits
begin
    process(clk)
        variable    addr_int: integer;
    begin
        if rising_edge(clk) then
            addr_int := to_integer(addr);
            if we = '1' then
                memory(8*addr_int + 7 downto 8*addr_int) <= data;
                data_out <= data;
            else
                data_out <= memory(addr_int + 7 downto addr_int);
            end if;
        end if;
    end process;
end architecture rtl;
