-- long press (around 1-2s) to restart the camera module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity restart_camera is
Port (press : in std_logic;
      restart : out std_logic;
      clk : in std_logic );
end restart_camera;

architecture Behavioral of restart_camera is
signal count : unsigned(26 downto 0);
begin
process(clk)
begin
  if rising_edge(clk) then
    if press = '1' then
      if count = x"7FFFFFF" then
        restart <= '1';
        count <= (others => '0');
      else 
        restart <= '0';
        count <= count +1;
      end if;
      
    else 
      count <= (others => '0');
      restart <= '0';
      
    end if;
  end if;
end process;

end Behavioral;
