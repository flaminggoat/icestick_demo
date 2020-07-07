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
  port (
    clk_raw : in std_logic;
    led1, led2, led3, led4, led5 : out std_logic;
    uart_tx : out std_logic;
    uart_rx : in std_logic);

end demo;

architecture behav of demo is
  signal clk : std_logic;
  signal nrst, rst : std_logic := '0';
  signal leds : std_ulogic_vector (1 to 5);

  signal uart_tx_data : std_logic_vector(7 downto 0);
  signal uart_tx_send, uart_tx_ready : std_logic;
  signal uart_rx_full : std_logic;

  signal rom_addr : unsigned(2 downto 0);

  component pll is
    port (
      clock_in : in std_logic;
      clock_out : out std_logic;
      locked : out std_logic
    );
  end component pll;
begin

  pll_inst : pll
  port map(
    clock_in => clk_raw,
    clock_out => clk,
    locked => open
  );

  uart_inst : entity work.uart
    generic map(
      baud => 115200,
      clock_frequency => 60000000
    )
    port map(
      -- general
      clock => clk,
      reset => rst,
      data_stream_in => uart_tx_data,
      data_stream_in_stb => uart_tx_send,
      data_stream_in_ack => uart_tx_ready,
      data_stream_out => open,
      data_stream_out_stb => uart_rx_full,
      tx => uart_tx,
      rx => uart_rx
    );

  rom_inst : entity work.rom
    port map(
      -- general
      clk => clk,
      addr => std_logic_vector(rom_addr),
      q => uart_tx_data
    );

  -- Reset signal generation
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

  -- Send ROM contents over uart when rx received
  process (clk)
    variable state : natural range 0 to 1;
  begin
    if rst = '1' then
      uart_tx_send <= '0';
      rom_addr <= "000";
      state := 0;
    elsif rising_edge(clk) then
      if state = 0 then
        if uart_rx_full = '1' then
          uart_tx_send <= '1';
          state := 1;
        end if;
      elsif state = 1 then
        if uart_tx_ready = '1' then
          if rom_addr = "110" then
            uart_tx_send <= '0';
            rom_addr <= "000";
            state := 0;
          else
            rom_addr <= rom_addr + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  (led1, led2, led3, led4, led5) <= leds;

  leds(1) <= uart_tx_send;

  rst <= not nrst;

end behav;