-- controller of ov7670 responsible for the initialization of ov7670
-- from zedboard to ov7670
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_controller is
Port (clk_50 : in std_logic;
      restart : in std_logic; -- will be control by the button using logic in restart_camera.vhd
      finish_configuration : out std_logic;
      sioc : out std_logic; 
      siod : inout std_logic; 
      reset : out std_logic;
      pwdn: out std_logic;
      xclk: out std_logic
 );
end ov7670_controller;

architecture Behavioral of ov7670_controller is

component ov7670_register 
Port (clk: in std_logic;
      restart: in std_logic; -- will be control by the button using logic in restart_camera.vhd
      sender_taken: in std_logic; -- 1: SCCB sender is not available 
      register_value: out std_logic_vector(15 downto 0); 
      finish_init: out std_logic); -- finish the configuation of ov7670
end component;

component SCCB_sender is
  Port (clk_50 : in std_logic; -- 50MHz clock will be used 
        siod : inout std_logic; 
        sioc : out std_logic;
        taken: out std_logic; -- 1: sending tha data to 0v7670
        having_data: in std_logic; -- 1: still have data to sent to ov7670 
        id: in std_logic_vector (7 downto 0);  -- ID for device to write 
        reg: in std_logic_vector (7 downto 0);  -- register to write 
        value: in std_logic_vector (7 downto 0)  -- value to write
        );
end component;
signal register_value_signal : std_logic_vector(15 downto 0);
signal having_data_signal: std_logic;
signal sending_out_signal: std_logic;
signal finish_init_signal : std_logic;
signal clk_25 : std_logic;
-- divice write ID is 0x42
constant write_id: std_logic_vector(7 downto 0) := x"42"; 
begin
-- pin F2, 0: reset mode 1: normal mode
reset <= '1';
-- pin B1, 0: normal mode 1: power down mode
pwdn <= '0';
--25MHz for clk of ov7670
xclk <= clk_25;
finish_configuration <= finish_init_signal;

-- process making 25MHz clock
process (clk_50)
begin
if rising_edge(clk_50)then
  clk_25 <= not clk_25;
end if;
end process;

-- finished init. = no data, so here i use not to convert it 
having_data_signal <= not finish_init_signal;
SCCB_sender1: SCCB_sender port map (clk_50 => clk_50, 
                                    siod => siod, 
                                    sioc => sioc, 
                                    taken => sending_out_signal,
                                    having_data => having_data_signal, 
                                    id => write_id, 
                                    reg => register_value_signal(15 downto 8), 
                                    value => register_value_signal(7 downto 0));
ov7670_register1: ov7670_register port map (clk => clk_50,
                                            restart => restart,
                                            sender_taken => sending_out_signal,
                                            register_value => register_value_signal(15 downto 0),
                                            finish_init => finish_init_signal);
end Behavioral;
