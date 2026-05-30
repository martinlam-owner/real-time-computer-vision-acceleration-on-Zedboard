-- initialising the 0v7670 through SCCB 
-- from zedboard to ov7670
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SCCB_sender is
  Port (clk_50 : in std_logic; -- 50MHz clock will be used 
        siod : inout std_logic;
        sioc : out std_logic;
        taken: out std_logic; -- 1: taken from register 0: not yet taken from register
        having_data: in std_logic; -- 1: still command line  sent to ov7670 
        id: in std_logic_vector (7 downto 0);  -- ID for device to write 
        reg: in std_logic_vector (7 downto 0);  -- register to write 
        value: in std_logic_vector (7 downto 0)  -- value to write
        );
end SCCB_sender;

architecture Behavioral of SCCB_sender is
signal diviser: unsigned (7 downto 0) := "00000001"; -- give some time for the 0v7670 setting up 
signal valid_bit_array: std_logic_vector (31 downto 0) := (others => '0'); -- control SCL (sioc)
signal data_bit_array: std_logic_vector (31 downto 0) := (others => '1'); -- control SDA(siod), '1' when idle 
begin
 -- this process is for get the ack signal
 process(valid_bit_array, data_bit_array)
 begin
 -- bit 12, 21, 30 are ack signal so check 11-10, 20-19, 29-28
 if valid_bit_array(11 downto 10) = "10" or 
    valid_bit_array(20 downto 19) = "10" or
    valid_bit_array(29 downto 28) = "10" then
    -- allow the ov7670 respond the Zedboard 
    siod <= 'Z';
 else
    -- sending the data bit
    siod <= data_bit_array(31);
 end if;
 end process;
 
 process(clk_50)
 begin
 if rising_edge(clk_50) then
   taken <= '0';
   if valid_bit_array(31) = '0' then
     sioc <= '1';
     
     if having_data = '1' then
     
        if diviser = "00000000" then
          -- start condition + id + ack + reg + ack + value + ack + stop condition
          data_bit_array <= "100" & id & '0' & reg & '0' & value & '0' & "01";
          valid_bit_array <= "111" & "11111111" & "1" & "11111111" & "1" & "11111111" & "1" & "11";
          taken <= '1';
        else
          -- for ov7670 setting up 
          diviser <= diviser + 1; 
        end if; 
     end if;
   else
     -- prepare to start 
     if valid_bit_array(31 downto 29) = "111" and valid_bit_array(2 downto 0) = "111" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '1';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '1';
       end case;
     -- start condition  
     elsif valid_bit_array(31 downto 29) = "111" and valid_bit_array(2 downto 0) = "110" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '1';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '1';
       end case;
     -- ready for transferring data   
     elsif valid_bit_array(31 downto 29) = "111" and valid_bit_array(2 downto 0) = "100" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '0';
         when "01" => sioc <= '0';
         when "10" => sioc <= '0';
         when "11" => sioc <= '0';
       end case;
     -- prepare to stop  
     elsif valid_bit_array(31 downto 29) = "110" and valid_bit_array(2 downto 0) = "000" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '0';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '1';
       end case;
     -- stop condition  
     elsif valid_bit_array(31 downto 29) = "100" and valid_bit_array(2 downto 0) = "000" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '1';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '1';
       end case;
     -- idle   
     elsif valid_bit_array(31 downto 29) = "000" and valid_bit_array(2 downto 0) = "000" then
       case diviser(7 downto 6) is
         when "00" => sioc <= '1';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '1';
       end case;
     -- transferring data 
     else
     case diviser(7 downto 6) is
         when "00" => sioc <= '0';
         when "01" => sioc <= '1';
         when "10" => sioc <= '1';
         when "11" => sioc <= '0';
       end case;
      
     end if; 
     
     if diviser = "11111111" then
     -- right shifting 
     data_bit_array <= data_bit_array(30 downto 0) & '1';
     valid_bit_array <= valid_bit_array(30 downto 0) & '0';
     diviser <= (others => '0'); 
     else
     diviser <= diviser + 1;
     end if;
     
   end if;
      
 end if;
 
 end process;
 

end Behavioral;
