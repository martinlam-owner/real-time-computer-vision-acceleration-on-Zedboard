-- using VGA driver with modification 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Display is
Port (clk25MHz : in std_logic;
      frame_pixel : in std_logic_vector(11 downto 0);
      hsync, vsync : out std_logic;
      pixel_address: out std_logic_vector(18 downto 0);
      red, green, blue : out std_logic_vector(3 downto 0) );
end VGA_Display;

architecture Behavioral of VGA_Display is

signal hcount, vcount : integer := 0;
signal address : unsigned(18 downto 0) := (others => '0');

-- row constants
constant H_TOTAL : integer := 800 - 1; --  
constant H_SYNC : integer := 96 - 1; -- 
constant H_BACK : integer := 48 - 1; -- 
constant H_START : integer := 96 + 48 - 1; -- 143
constant H_ACTIVE : integer := 640 - 1; -- 
constant H_END : integer := 800 - 16 - 1; -- 783
constant H_FRONT : integer := 16 - 1; -- 
-- column constants
constant V_TOTAL : integer := 524 - 1; -- 
constant V_SYNC : integer := 2 - 1; -- 
constant V_BACK : integer := 31 - 1; -- 
constant V_START : integer := 2 + 31 - 1; -- 32
constant V_ACTIVE : integer := 480 - 1; -- 
constant V_END : integer := 524 - 11 - 1; --  512
constant V_FRONT : integer := 11 - 1; -- 

begin

-- ? horizontal counter
hcount_proc : process (clk25MHz)
begin
  if (rising_edge(clk25MHz)) then
    if (hcount = H_TOTAL) then
      hcount <= 0;
    else
      hcount <= hcount + 1;
    end if;
  end if;
end process hcount_proc;

-- ? vertical counter
vcount_proc : process (clk25MHz)
begin
  if (rising_edge(clk25MHz)) then
    if (hcount = H_TOTAL) then
      if (vcount = V_TOTAL) then
        vcount <= 0;
      else
        vcount <= vcount + 1;
      end if;
    end if;
  end if;
end process vcount_proc;

-- ? generate hsync
hsync_gen_proc : process (hcount)
begin
  if (hcount <= H_SYNC ) then
    hsync <= '0';
  else
    hsync <= '1';
  end if;
end process hsync_gen_proc;

-- ? generate vsync
vsync_gen_proc : process (vcount)
begin
  if (vcount <= V_SYNC ) then
    vsync <= '0';
  else
    vsync <= '1';
  end if;
end process vsync_gen_proc;

-- ? generate RGB signals for 1024x600
data_output_proc : process (hcount, vcount)
begin
  if ((hcount > H_START and hcount <= H_END) and
     (vcount > V_START and vcount <= V_END)) then
  -- Display Area
    red <= frame_pixel(11 downto 8);
    green <= frame_pixel(7 downto 4);
    blue <= frame_pixel(3 downto 0);
   
  else
  -- Blanking Area
  red <= "0000";
  green <= "0000";
  blue <= "0000";
  end if;
end process data_output_proc;

-- determine the address of pixel
process(clk25MHz)
begin
  if rising_edge(clk25MHz) then
    
    if (hcount = H_TOTAL and vcount = V_TOTAL) then
      address <= (others => '0');
    elsif (hcount > H_START and hcount <= H_END) and
          (vcount > V_START and vcount <= V_END) then
      address <= address + 1;
    end if;
  end if;
  
end process;
pixel_address <= std_logic_vector(address);

end Behavioral;
