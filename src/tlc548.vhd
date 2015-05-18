-- i/o clock maximum frequency is 2.048 Mhz (488 ns)
-- time between sample must be at least 17 us
-- time between when we set cs to low and we read data must be at leat 1.4 us

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tlc548 is
generic( CLK_PERIOD: integer := 20 -- in ns
      );
port( clk: in std_logic;
      data_in: in std_logic; -- connected to the data_out pin of the adc
      cs: out std_logic;
      io_clock: out std_logic;
      value: out unsigned(7 downto 0)
    );
end tlc548; 

architecture tlc548_arch of tlc548 is

type t_State is (
    BETWEEN_SAMPLE,
    SETUP,
    IO_CLOCK_HIGH,
    IO_CLOCK_LOW
);

constant IO_CLOCK_CYCLES: integer := (488/CLK_PERIOD/2) + 1;
constant BETWEEN_SAMPLE_CYCLES: integer := (17000/CLK_PERIOD) + 1;
constant SETUP_CYCLES: integer := (1400/CLK_PERIOD) + 1;

-- TODO: the size of the conter should vary depending on CLK_PERIOD
signal cnt: unsigned(9 downto 0) := to_unsigned(0, 10);
signal state: t_State := BETWEEN_SAMPLE;
signal value_tmp: unsigned(7 downto 0);
signal bit_read: unsigned(2 downto 0); -- the number of bit read - 1

begin

process (clk) is
begin
    if rising_edge(clk) then
       cnt <= cnt + 1;
       case(state) is
       when BETWEEN_SAMPLE =>
            cs <= '1';
            io_clock <= '0';
            if cnt = BETWEEN_SAMPLE_CYCLES then
                state <= SETUP;
                cnt <= to_unsigned(0, 10);
            end if;
       when SETUP =>
            cs <= '0';
            io_clock <= '0';
            if cnt = SETUP_CYCLES then
                state <= IO_CLOCK_HIGH;
                cnt <= to_unsigned(0, 10);
                value_tmp <= value_tmp(6 downto 0) & data_in;
                bit_read <= to_unsigned(0, 3);
            end if;
       when IO_CLOCK_HIGH =>
            cs <= '0';
            io_clock <= '1';
            if cnt = IO_CLOCK_CYCLES then
                if bit_read = 7 then
                    state <= BETWEEN_SAMPLE;
                    value <= value_tmp;
                else
                    state <= IO_CLOCK_LOW;
                end if;
                cnt <= to_unsigned(0, 10);
            end if;
       when IO_CLOCK_LOW =>
            cs <= '0';
            io_clock <= '0';
            if cnt = IO_CLOCK_CYCLES then
                state <= IO_CLOCK_HIGH;
                cnt <= to_unsigned(0, 10);
                value_tmp <= value_tmp(6 downto 0) & data_in;
                bit_read <= bit_read + 1;

            end if;
       end case;
    end if;
end process;

end tlc548_arch;

