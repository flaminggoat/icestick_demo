library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	port (
		clk : in std_logic;
		addr : in std_logic_vector(2 downto 0);
		q : out std_logic_vector(7 downto 0)
	);

end entity;

architecture rtl of rom is

	type mem_arr is array (0 to 6) of std_logic_vector(7 downto 0);
	constant my_Rom : mem_arr :=
	(x"48", x"45", x"4C", x"4C", x"4F", x"0A", x"0D"
	);

begin
	process (clk)
	begin
		if (rising_edge(clk)) then
			q <= my_Rom(to_integer(unsigned(addr)));
		end if;
	end process;
end rtl;