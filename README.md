# real-time-computer-vision-acceleration-on-Zedboard
A real-time image processing system on FPGA that captures video from an OV7670 camera, performs 3x3 Gaussian filtering, and displays the result on a VGA monitor. The entire pipeline is implemented in pure VHDL with no soft-core CPU, achieving 60fps at 640×480 resolution.

## Block Diagram
ov7670 camera -> SCCB configuration -> VGA capture -> line buffer + 3x3 filter -> frame buffer -> VGA display

## features 
- real time video output (640*480 @60fps)
- pure hardware pipeline
- 3x3 gaussian filter 
- Asynchronous frame buffer** – Dual-port BRAM handles 30fps capture -> 60fps display

## Hardware used 
- FPGA board: zynq-7000 (Zedboard) 
- ov7670 camera without FIFO
- display: VGA Display used in CUHK

## Repository Structure
├── src/
│ ├── vhdl/
│ │ ├── clock.vhd # clock diviser  
│ │ ├── gaussian_filter.vhd # 3x3 gaussian filter
│ │ ├── ov7670_controller.vhd # initialization of ov7670 
│ │ ├── ov7670_on_top # Top module
│ │ ├── ov7670_register.vhd # configuration of ov7670 register
│ │ ├── restart_camera.vhd # restart ov7670 camera module
│ │ ├── SCCB_sender.vhd # SCCB bit-level sender
│ │ ├── VGA_capture.vhd # Pixel capture & RGB565->RGB444
│ │ └── VGA_Display.vhd # VGA timing & read BRAM
│ │
│ ├── xdc/
│ │ └── project.xdc # constraints file
│ │
| └── vivado_ip/
│   └── blk_mem_gen_0.xci
│ 
├── LICENSE
└── README.md