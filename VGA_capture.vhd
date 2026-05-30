-- getting RGB data from the ov7670

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_capture is
Port (pclk: in std_logic; 
      HREF: in std_logic; -- 1: transfer row data   
      VSYNC: in std_logic; -- 1: frame transfer finish/ not yet start  
      data_in: in std_logic_vector(7 downto 0); -- one data byte from ov7670
      data_out: out std_logic_vector(11 downto 0); -- R: 4 + G: 4 + B: 4
      one_pixel_done: out std_logic_vector(0 downto 0); -- one pixel need two bytes to transfer, check for whether 2 bytes is transferred
      address_of_pixel: out std_logic_vector(18 downto 0) -- address of pixel = row * 640 + column 
      );
end VGA_capture;

architecture Behavioral of VGA_capture is
signal bytes_flag: std_logic;
signal address : unsigned(18 downto 0);


begin
address_of_pixel <= std_logic_vector(address);
one_pixel_done(0) <= bytes_flag and HREF ;
process(pclk)
variable data_out_signal : std_logic_vector(15 downto 0);
begin
  if rising_edge(pclk) then
    if VSYNC = '1' then
      bytes_flag <= '0';
      address <= (others => '0');
    elsif (HREF = '1') then
      if(bytes_flag = '0') then 
        data_out_signal := data_in & data_out_signal(7 downto 0);
        bytes_flag <= '1';
      elsif (bytes_flag = '1') then
        data_out_signal := data_out_signal(15 downto 8) & data_in ;
        data_out <= data_out_signal (10 downto 7) & data_out_signal (15 downto 12) & data_out_signal(4 downto 1);
        address <= address + 1 ;
        bytes_flag <= '0';
      end if;
    else 
      bytes_flag <= '0'; 
    end if;
  end if;
end process;

end Behavioral;
