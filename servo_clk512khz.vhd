library IEEE;
use IEEE.std_logic_1164.all;

-- This entity will use the system clock as a base clock
-- and start from 0 to 10240 (1ms of 512kHz, or a count to 512, so for a period of 20ms, we need 10240)
-- Initially this will not be used
entity servo_clk512khz is
port (
  rst : in std_logic;
  clk : in std_logic;
  servo_clk : out std_logic);
end servo_clk512khz;

architecture behavioral of servo_clk512khz is

signal count : integer range 0 to 10240 := 0;
signal servo_clk_s : std_logic;

begin

  process(rst, clk)
  begin
  
  end process;

servo_clk <= servo_clk_s;
end architecture;