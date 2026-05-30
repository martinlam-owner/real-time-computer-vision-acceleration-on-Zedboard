-- ov7670 register initialization
-- from zedboard to ov7670
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_register is
Port (clk: in std_logic;
      restart: in std_logic; -- will be control by the button using logic in restart_camera.vhd
      sender_taken: in std_logic; -- 1: SCCB sender taken 0: SCCB not yet taken
      register_value: out std_logic_vector(15 downto 0);
      finish_init: out std_logic); -- finish the configuation of ov7670
end ov7670_register;

architecture Behavioral of ov7670_register is
signal command_number : std_logic_vector(7 downto 0) := (others => '0');
signal register_value_sig : std_logic_vector(15 downto 0) := (others => '0');
begin
register_value <= register_value_sig;
with register_value_sig select 
  finish_init <= '1' when x"FFFF",
                 '0' when others;
           
process(clk)
begin
  if rising_edge(clk)then
    if (restart = '1') then
      command_number <= (others => '0');
    elsif (restart = '0') then
      if (sender_taken = '1') then
         command_number <= std_logic_vector(unsigned(command_number) + 1);
      end if;
     
    end if;
    
    case command_number is 
    when x"00" => register_value_sig <= x"1280";
    when x"01" => register_value_sig <= x"1280"; -- COM7   Reset
	when x"02" => register_value_sig <= x"1204"; -- COM7   Size & RGB output
	when x"03" => register_value_sig <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)
	when x"04" => register_value_sig <= x"0C00"; -- COM3   Lots of stuff, enable scaling, all others off
	when x"05" => register_value_sig <= x"3E00"; -- COM14  PCLK scaling off
	when x"06" => register_value_sig <= x"8C00"; -- RGB444 Set RGB format
    when x"07" => register_value_sig <= x"0400"; -- COM1   no CCIR601
 	when x"08" => register_value_sig <= x"4010"; -- COM15  Full 0-255 output, RGB 565
	when x"09" => register_value_sig <= x"3a04"; -- TSLB   Set UV ordering,  do not auto-reset window
	when x"0A" => register_value_sig <= x"1438"; -- COM9  - AGC Celling
	when x"0B" => register_value_sig <= x"4fb3"; -- MTX1  - colour conversion matrix
    when x"0C" => register_value_sig <= x"50b3"; -- MTX2  - colour conversion matrix
	when x"0D" => register_value_sig <= x"5100"; -- MTX3  - colour conversion matrix
	when x"0E" => register_value_sig <= x"523d"; -- MTX4  - colour conversion matrix
	when x"0F" => register_value_sig <= x"53a7"; -- MTX5  - colour conversion matrix
	when x"10" => register_value_sig <= x"54e4"; -- MTX6  - colour conversion matrix
	when x"11" => register_value_sig <= x"589e"; -- MTXS  - Matrix sign and auto contrast
	when x"12" => register_value_sig <= x"3dc0"; -- COM13 - Turn on GAMMA and UV Auto adjust
	when x"13" => register_value_sig <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)		
	when x"14" => register_value_sig <= x"1711"; -- HSTART HREF start (high 8 bits)
	when x"15" => register_value_sig <= x"1861"; -- HSTOP  HREF stop (high 8 bits)
	when x"16" => register_value_sig <= x"32A4"; -- HREF   Edge offset and low 3 bits of HSTART and HSTOP
	when x"17" => register_value_sig <= x"1903"; -- VSTART VSYNC start (high 8 bits)
	when x"18" => register_value_sig <= x"1A7b"; -- VSTOP  VSYNC stop (high 8 bits) 
	when x"19" => register_value_sig <= x"030a"; -- VREF   VSYNC low two bits
	--when x"1A" => register_value_sig <= x"7142"; -- test
	--when x"1B" => register_value_sig <= x"7002"; -- test
	when others => register_value_sig <= x"FFFF";
    end case;
  end if;
 
end process;

end Behavioral;
