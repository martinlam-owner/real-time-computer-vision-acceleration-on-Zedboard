# clk100
set_property PACKAGE_PIN    Y9 [get_ports {clk100 }]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]
#ov7670
set_property PACKAGE_PIN Y11  [get_ports {ov7670_reset}];  # "JA1"
set_property PACKAGE_PIN AA11 [get_ports {ov7670_pclk}];  # "JA2"
set_property PACKAGE_PIN Y10  [get_ports {ov7670_VSYNC}];  # "JA3"
set_property PACKAGE_PIN AA9  [get_ports {ov7670_sioc}];  # "JA4"
set_property PACKAGE_PIN AB11 [get_ports {ov7670_pwdn}];  # "JA7"
set_property PACKAGE_PIN AB10 [get_ports {ov7670_xclk}];  # "JA8"
set_property PACKAGE_PIN AB9  [get_ports {ov7670_HREF}];  # "JA9"
set_property PACKAGE_PIN AA8  [get_ports {ov7670_siod}];  # "JA10"
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_pclk];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_sioc];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_VSYNC];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_reset];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_pwdn];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_HREF];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_xclk];
set_property IOSTANDARD LVCMOS33 [get_ports ov7670_siod];
#ov7670 data
set_property PACKAGE_PIN W12 [get_ports {ov7670_data_in[1]}];  # "JB1"
set_property PACKAGE_PIN W11 [get_ports {ov7670_data_in[3]}];  # "JB2"
set_property PACKAGE_PIN V10 [get_ports {ov7670_data_in[5]}];  # "JB3"
set_property PACKAGE_PIN W8 [get_ports {ov7670_data_in[7]}];  # "JB4"
set_property PACKAGE_PIN V12 [get_ports {ov7670_data_in[0]}];  # "JB7"
set_property PACKAGE_PIN W10 [get_ports {ov7670_data_in[2]}];  # "JB8"
set_property PACKAGE_PIN V9 [get_ports {ov7670_data_in[4]}];  # "JB9"
set_property PACKAGE_PIN V8 [get_ports {ov7670_data_in[6]}];  # "JB10"
set_property IOSTANDARD LVCMOS33 [get_ports {ov7670_data_in[*]}];
#VGA
set_property PACKAGE_PIN Y21  [get_ports {vga_blue[0]}];  # "VGA-B1"
set_property PACKAGE_PIN Y20  [get_ports {vga_blue[1]}];  # "VGA-B2"
set_property PACKAGE_PIN AB20 [get_ports {vga_blue[2]}];  # "VGA-B3"
set_property PACKAGE_PIN AB19 [get_ports {vga_blue[3]}];  # "VGA-B4"
set_property PACKAGE_PIN AB22 [get_ports {vga_green[0]}];  # "VGA-G1"
set_property PACKAGE_PIN AA22 [get_ports {vga_green[1]}];  # "VGA-G2"
set_property PACKAGE_PIN AB21 [get_ports {vga_green[2]}];  # "VGA-G3"
set_property PACKAGE_PIN AA21 [get_ports {vga_green[3]}];  # "VGA-G4"
set_property PACKAGE_PIN AA19 [get_ports {vga_hsync}];  # "VGA-HS"
set_property PACKAGE_PIN V20  [get_ports {vga_red[0]}];  # "VGA-R1"
set_property PACKAGE_PIN U20  [get_ports {vga_red[1]}];  # "VGA-R2"
set_property PACKAGE_PIN V19  [get_ports {vga_red[2]}];  # "VGA-R3"
set_property PACKAGE_PIN V18  [get_ports {vga_red[3]}];  # "VGA-R4"
set_property PACKAGE_PIN Y19  [get_ports {vga_vsync}];  # "VGA-VS"
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[*]}];
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[*]}];
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[*]}];
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync];
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync];
#btn and LED
set_property PACKAGE_PIN P16 [get_ports {btn_reset}];  # "BTNC"
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset];
set_property PACKAGE_PIN T22 [get_ports {led_debug[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {led_debug[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {led_debug[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {led_debug[3]}];  # "LD3"
set_property PACKAGE_PIN V22 [get_ports {led_debug[4]}];  # "LD4"
set_property PACKAGE_PIN W22 [get_ports {led_debug[5]}];  # "LD5"
set_property PACKAGE_PIN U19 [get_ports {led_debug[6]}];  # "LD6"
set_property PACKAGE_PIN U14 [get_ports {led_debug[7]}];  # "LD7"
set_property IOSTANDARD LVCMOS33 [get_ports {led_debug[*]}];
#sw
set_property PACKAGE_PIN F22 [get_ports {sw_filter}];  # "sw0"
set_property IOSTANDARD LVCMOS25 [get_ports sw_filter];
# Magic
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of_objects [get_ports ov7670_pclk]];