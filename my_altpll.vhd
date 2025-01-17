library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity my_altpll is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic         -- outclk0.clk
	);
end entity my_altpll;

architecture rtl of my_altpll is
	component my_altpll_0002 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component my_altpll_0002;

begin

	my_altpll_inst : component my_altpll_0002
		port map (
			refclk   => refclk,   --  refclk.clk
			rst      => rst,      --   reset.reset
			outclk_0 => outclk_0, -- outclk0.clk
			locked   => open      -- (terminated)
		);

end architecture rtl; 