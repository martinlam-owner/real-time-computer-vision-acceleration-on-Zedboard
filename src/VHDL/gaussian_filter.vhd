-- 3x3 Gaussian Filter for RGB444 (12-bit)
-- Kernel:
--   1  2  1
--   2  4  2
--   1  2  1
-- Normalization factor: 1/16

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gaussian_filter is
Port ( 
    clk         : in  std_logic;                          -- 25MHz
    rst_n       : in  std_logic;                          
    pixel_in    : in  std_logic_vector(11 downto 0);      -- RGB input
    pixel_valid : in  std_logic;                          -- one_pixel_done
    pixel_out   : out std_logic_vector(11 downto 0);      -- RBG data after filter
    out_valid   : out std_logic                           -- ready to outpuy=t
);
end gaussian_filter;

architecture Behavioral of gaussian_filter is

    -- line buffer : 3 line, 640 pixel per line
    type line_buffer_t is array(0 to 2, 0 to 639) of std_logic_vector(11 downto 0);
    signal line_buf : line_buffer_t;
    
    -- 3x3 filter
    type window_t is array(0 to 2, 0 to 2) of std_logic_vector(11 downto 0);
    signal window : window_t;
    
    -- counting the pixel address
    signal x_cnt : integer range 0 to 639 := 0;
    signal y_cnt : integer range 0 to 479 := 0;
    
    -- for 3 clock cycle delay 
    signal valid_dly : std_logic_vector(2 downto 0) := (others => '0');
    
    -- seperate the RGB signal 
    signal r00, r01, r02 : integer range 0 to 15;
    signal r10, r11, r12 : integer range 0 to 15;
    signal r20, r21, r22 : integer range 0 to 15;
    signal g00, g01, g02 : integer range 0 to 15;
    signal g10, g11, g12 : integer range 0 to 15;
    signal g20, g21, g22 : integer range 0 to 15;
    signal b00, b01, b02 : integer range 0 to 15;
    signal b10, b11, b12 : integer range 0 to 15;
    signal b20, b21, b22 : integer range 0 to 15;
    
    -- convolution result 
    signal r_sum, g_sum, b_sum : integer range 0 to 240;
    signal r_out, g_out, b_out : std_logic_vector(3 downto 0);
    
begin
-- pixel address calculator
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            x_cnt <= 0;
            y_cnt <= 0;
        elsif rising_edge(clk) then
            if pixel_valid = '1' then
                if x_cnt = 639 then
                    x_cnt <= 0;
                    if y_cnt = 479 then
                        y_cnt <= 0;
                    else
                        y_cnt <= y_cnt + 1;
                    end if;
                else
                    x_cnt <= x_cnt + 1;
                end if;
            end if;
        end if;
    end process;
  
-- line buffer
    process(clk)
    begin
        if rising_edge(clk) then
            if pixel_valid = '1' then
                -- writing in line 0
                line_buf(0, x_cnt) <= pixel_in;
                
                -- line buffer shift 
                if x_cnt = 639 then
                    for i in 1 to 2 loop
                        for j in 0 to 639 loop
                            line_buf(i, j) <= line_buf(i-1, j);
                        end loop;
                    end loop;
                end if;
            end if;
        end if;
    end process;
    
-- window shifting algo 
    process(clk)
    begin
        if rising_edge(clk) then
            if pixel_valid = '1' then
               
                window(0, 0) <= window(0, 1);
                window(0, 1) <= window(0, 2);
                window(0, 2) <= pixel_in;
                
                window(1, 0) <= window(1, 1);
                window(1, 1) <= window(1, 2);
                window(1, 2) <= line_buf(0, x_cnt);
                
                window(2, 0) <= window(2, 1);
                window(2, 1) <= window(2, 2);
                if y_cnt >= 1 then
                    window(2, 2) <= line_buf(1, x_cnt);
                else
                    window(2, 2) <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
-- RGB seperation
    process(clk)
    begin
        if rising_edge(clk) then
            -- line 0
            r00 <= to_integer(unsigned(window(0, 0)(11 downto 8)));
            r01 <= to_integer(unsigned(window(0, 1)(11 downto 8)));
            r02 <= to_integer(unsigned(window(0, 2)(11 downto 8)));
            g00 <= to_integer(unsigned(window(0, 0)(7 downto 4)));
            g01 <= to_integer(unsigned(window(0, 1)(7 downto 4)));
            g02 <= to_integer(unsigned(window(0, 2)(7 downto 4)));
            b00 <= to_integer(unsigned(window(0, 0)(3 downto 0)));
            b01 <= to_integer(unsigned(window(0, 1)(3 downto 0)));
            b02 <= to_integer(unsigned(window(0, 2)(3 downto 0)));
            
            -- line 1
            r10 <= to_integer(unsigned(window(1, 0)(11 downto 8)));
            r11 <= to_integer(unsigned(window(1, 1)(11 downto 8)));
            r12 <= to_integer(unsigned(window(1, 2)(11 downto 8)));
            g10 <= to_integer(unsigned(window(1, 0)(7 downto 4)));
            g11 <= to_integer(unsigned(window(1, 1)(7 downto 4)));
            g12 <= to_integer(unsigned(window(1, 2)(7 downto 4)));
            b10 <= to_integer(unsigned(window(1, 0)(3 downto 0)));
            b11 <= to_integer(unsigned(window(1, 1)(3 downto 0)));
            b12 <= to_integer(unsigned(window(1, 2)(3 downto 0)));
            
            -- line 2
            r20 <= to_integer(unsigned(window(2, 0)(11 downto 8)));
            r21 <= to_integer(unsigned(window(2, 1)(11 downto 8)));
            r22 <= to_integer(unsigned(window(2, 2)(11 downto 8)));
            g20 <= to_integer(unsigned(window(2, 0)(7 downto 4)));
            g21 <= to_integer(unsigned(window(2, 1)(7 downto 4)));
            g22 <= to_integer(unsigned(window(2, 2)(7 downto 4)));
            b20 <= to_integer(unsigned(window(2, 0)(3 downto 0)));
            b21 <= to_integer(unsigned(window(2, 1)(3 downto 0)));
            b22 <= to_integer(unsigned(window(2, 2)(3 downto 0)));
        end if;
    end process;
    
-- kernal
-- 1  2  1
-- 2  4  2
-- 1  2  1
    process(clk)
    begin
        if rising_edge(clk) then
            r_sum <= r00 + r01*2 + r02 +
                     r10*2 + r11*4 + r12*2 +
                     r20 + r21*2 + r22;
                     
            g_sum <= g00 + g01*2 + g02 +
                     g10*2 + g11*4 + g12*2 +
                     g20 + g21*2 + g22;
                     
            b_sum <= b00 + b01*2 + b02 +
                     b10*2 + b11*4 + b12*2 +
                     b20 + b21*2 + b22;
        end if;
    end process;
    
    -- shifting for division
    r_out <= std_logic_vector(to_unsigned(r_sum / 16, 4));
    g_out <= std_logic_vector(to_unsigned(g_sum / 16, 4));
    b_out <= std_logic_vector(to_unsigned(b_sum / 16, 4));
    
    -- combine the output 
    pixel_out <= r_out & g_out & b_out;
    
-- delay 3 clock cycle 
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            valid_dly <= (others => '0');
        elsif rising_edge(clk) then
            valid_dly(0) <= pixel_valid;
            valid_dly(1) <= valid_dly(0);
            valid_dly(2) <= valid_dly(1);
        end if;
    end process;
    
    out_valid <= valid_dly(2);

end Behavioral;