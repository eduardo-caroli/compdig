library ieee;
use ieee.std_logic_1164.all;

package ram_pkg is

    subtype byte_t is STD_LOGIC_VECTOR(7 downto 0);
    type byte_array_t is array (natural range <>) of byte_t;

end package;

package body ram_pkg is
end package body;
