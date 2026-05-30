-- top module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ov7670_on_top is
Port (clk100: in std_logic;
      ov7670_sioc: out std_logic; 
      ov7670_siod: inout std_logic;
      ov7670_reset: out std_logic;
      ov7670_pwdn: out std_logic;
      ov7670_xclk: out std_logic;
      ov7670_data_in: in std_logic_vector(7 downto 0);
      ov7670_pclk: in std_logic;
      ov7670_HREF: in std_logic;
      ov7670_VSYNC: in std_logic;
      
      vga_red: out std_logic_vector(3 downto 0);
      vga_green: out std_logic_vector(3 downto 0);
      vga_blue: out std_logic_vector(3 downto 0);
      vga_hsync: out std_logic;
      vga_vsync: out std_logic;
      
      btn_reset: in std_logic;
      led_debug: out std_logic_vector (7 downto 0); 
      
      sw_filter: in std_logic
);
end ov7670_on_top;

architecture Behavioral of ov7670_on_top is

component restart_camera is
Port (press : in std_logic;
      restart : out std_logic;
      clk : in std_logic );
end component;

component clock is
generic (N: integer);
port(clk: in std_logic;
     clk_out: out std_logic);
end component;

component ov7670_controller is
Port (clk_50 : in std_logic;
      restart : in std_logic; -- will be control by the button using logic in restart_camera.vhd
      finish_configuration : out std_logic;
      sioc : out std_logic; 
      siod : inout std_logic; 
      reset : out std_logic;
      pwdn: out std_logic;
      xclk: out std_logic);
end component;

component blk_mem_gen_0 is
Port(clka : in std_logic;
     wea: in std_logic_vector(0 downto 0);
     addra : in std_logic_vector(18 downto 0);
     dina : in std_logic_vector(11 downto 0);
     clkb: in std_logic;
     addrb: in std_logic_vector(18 downto 0);
     doutb: out std_logic_vector(11 downto 0));
end component;

component VGA_capture is
Port (pclk: in std_logic; 
      HREF: in std_logic; -- 1: transfer row data   
      VSYNC: in std_logic; -- 1: frame transfer finish/ not yet start  
      data_in: in std_logic_vector(7 downto 0); -- one data byte from ov7670
      data_out: out std_logic_vector(11 downto 0); -- R: 4 + G: 4 + B: 4
      one_pixel_done: out std_logic_vector(0 downto 0); -- one pixel need two bytes to transfer, check for whether 2 bytes is transferred
      address_of_pixel: out std_logic_vector(18 downto 0) -- address of pixel = row * 640 + column 
      );
end component;

component VGA_Display is
Port (clk25MHz : in std_logic;
      frame_pixel : in std_logic_vector(11 downto 0);
      hsync, vsync : out std_logic;
      pixel_address: out std_logic_vector(18 downto 0);
      red, green, blue : out std_logic_vector(3 downto 0) );
end component;

component gaussian_filter is
Port ( 
    clk         : in  std_logic;                          -- 25MHz
    rst_n       : in  std_logic;                          
    pixel_in    : in  std_logic_vector(11 downto 0);      -- RGB input
    pixel_valid : in  std_logic;                          -- one_pixel_done
    pixel_out   : out std_logic_vector(11 downto 0);      -- RBG data after filter
    out_valid   : out std_logic);                         -- ready to output
end component;

signal clk50, clk_25 : std_logic;
signal restart_signal: std_logic;
signal one_pixel_done_signal: std_logic_vector(0 downto 0);
signal capture_address: std_logic_vector(18 downto 0);
signal capture_data: std_logic_vector(11 downto 0);
signal frame_address: std_logic_vector(18 downto 0);
signal frame_pixel: std_logic_vector(11 downto 0);
signal finish_configuration_signal: std_logic;
signal filtered_data : std_logic_vector(11 downto 0);
signal wea_aligned : std_logic_vector(0 downto 0);
signal wea_pipe : std_logic_vector(2 downto 0);
signal raw_data_delayed : std_logic_vector(11 downto 0);
signal final_data : std_logic_vector(11 downto 0);
--test
signal test_addr      : unsigned(18 downto 0) := (others => '0');
signal test_data      : std_logic_vector(11 downto 0);
signal test_we        : std_logic_vector(0 downto 0) := "1";
signal test_clk_counter : integer := 0;
signal test_pclk      : std_logic := '0';


begin
--test
process(clk50)
begin
    if rising_edge(clk50) then
        test_clk_counter <= test_clk_counter + 1;
        if test_clk_counter = 24 then           
            test_clk_counter <= 0;
            test_pclk <= not test_pclk;
        end if;
    end if;
end process;
process(test_pclk)
begin
    if rising_edge(test_pclk) then
        test_addr <= test_addr + 1;
    end if;
end process;

test_data <= "1111" & "0000" & "0000" when test_addr < 76800 else   
             "0000" & "1111" & "0000" when test_addr < 153600 else  
             "0000" & "0000" & "1111" when test_addr < 230400 else  
             "1111" & "1111" & "1111";
             
--test


clock50: clock 
generic map (N => 1)
port map (clk => clk100,
          clk_out => clk50);
          
clock25: clock
generic map (N => 2)
port map (clk => clk100, 
          clk_out => clk_25);

restart_camera_by_btn: restart_camera
port map (press => btn_reset,
          restart => restart_signal,
          clk => clk50);

VGA_display1: VGA_display
port map( clk25MHz => clk_25,
          frame_pixel => frame_pixel,
          hsync => vga_hsync,
          vsync => vga_vsync,
          pixel_address => frame_address,
          red => vga_red,
          green => vga_green,
          blue => vga_blue);
         
capture: VGA_capture
port map(pclk => ov7670_pclk,
         HREF => ov7670_HREF,
         VSYNC => ov7670_VSYNC,
         data_in => ov7670_data_in,
         data_out => capture_data,
         address_of_pixel => capture_address,
         one_pixel_done => one_pixel_done_signal);

controller: ov7670_controller
port map(clk_50 => clk50,
         restart => restart_signal,
         finish_configuration => finish_configuration_signal,
         sioc => ov7670_sioc,
         siod => ov7670_siod,
         reset => ov7670_reset,
         pwdn => ov7670_pwdn,
         xclk => ov7670_xclk);
led_debug <= "0000000" & finish_configuration_signal;

gaussian_filter_inst: gaussian_filter
port map(
    clk         => ov7670_pclk,
    rst_n       => '0',
    pixel_in    => capture_data,
    pixel_valid => one_pixel_done_signal(0),
    pixel_out   => filtered_data,
    out_valid   => open
);

-- since gaussian filter need to wait three cycle to start convolution, so wait for 3 clock cycle
process(ov7670_pclk)
begin
    if rising_edge(ov7670_pclk) then
        wea_pipe(0) <= one_pixel_done_signal(0);
        wea_pipe(1) <= wea_pipe(0);
        wea_pipe(2) <= wea_pipe(1);
    end if;
end process;
wea_aligned(0) <= wea_pipe(2);

process(ov7670_pclk)
begin
  if rising_edge(ov7670_pclk) then
    raw_data_delayed <= capture_data;
  end if;
end process;
-- use a sw to choose whether data pass through the filter or not 
final_data <= filtered_data when sw_filter = '1' else raw_data_delayed;


frame_block: blk_mem_gen_0
port map(clka => ov7670_pclk, --test_pclk
         wea => wea_aligned, --"1"
         addra => capture_address, --std_logic_vector(test_addr)
         dina => final_data, --test_data
         clkb => clk_25,
         addrb => frame_address,
         doutb => frame_pixel);

end Behavioral;

