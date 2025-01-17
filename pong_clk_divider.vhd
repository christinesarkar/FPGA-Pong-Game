-- reset_divider.vhd
-- This is a clock divider. It takes as input a signal
-- of 50 MHz and generates an output as signal with a frequency
-- of about 1 Hz.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pong_clk_divider is
  Port ( 
    reset_IN : in STD_LOGIC;
    reset_OUT : out STD_LOGIC
  );
end pong_clk_divider;

architecture Behavioral of pong_clk_divider is

constant TIMECONST : integer := 71;
signal count0, count1, count2, count3 : integer range 0 to 1000;
signal D : std_logic := '0';
begin

process (reset_IN, D)
begin
	if (reset_IN'event and reset_IN = '1') then
		count0 <= count0 + 1;
		if count0 = TIMECONST then
			count0 <= 0;
			count1 <= count1 + 1;
		elsif count1 = TIMECONST then
			count1 <= 0;
			count2 <= count2 + 1;
		elsif count2 = TIMECONST then
			count2 <= 0;
			count3 <= count3 + 1;
		elsif count3 = TIMECONST then
			count3 <= 0;
			D <= not D;
		end if;
	end if;
	reset_OUT <= D;
end process;

end Behavioral;