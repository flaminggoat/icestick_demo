library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--  Led positions
--
--  I         D3
--  r
--  D     D2  D5  D4
--  A
--            D1
--
entity demo is
  port (clk : in std_logic;
        led1, led2, led3, led4, led5 : out std_logic;
        uart_tx : out std_logic;
        uart_rx : in std_logic);
  
end demo;

architecture behav of demo is
  signal nrst, rst : std_logic := '0';
  signal leds : std_ulogic_vector (1 to 5);
begin

  uart_inst : entity work.uart
  generic map (
      baud                => 115200,
      clock_frequency     => 12000000
  )
  port map    (  
      -- general
      clock               => clk,
      reset               => rst,
      data_stream_in      => x"41", -- A
      data_stream_in_stb  => '1',
      data_stream_in_ack  => leds(1),
      data_stream_out     => open,
      data_stream_out_stb => leds(2),
      tx                  => uart_tx,
      rx                  => uart_rx
  );

  process (clk)
    variable cnt : unsigned (1 downto 0) := "00";
  begin
    if rising_edge (clk) then
      if cnt = 3 then
        nrst <= '1';
      else
        cnt := cnt + 1;
      end if;
    end if;
  end process;

  (led1, led2, led3, led4, led5) <= leds;

  rst <= not nrst;

end behav;
