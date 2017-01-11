// A simple pong game for the MiST FPGA board
// (c) 2015 Till Harbaum

// Lesson 1: VGA signal with ball

module pong (
   input [1:0] CLOCK_27,
   output 		SDRAM_nCS,
   output reg	VGA_HS,
   output reg 	VGA_VS,
   output [5:0] VGA_R,
   output [5:0] VGA_G,
   output [5:0] VGA_B
);
					
// 640x480 60HZ VESA http://tinyvga.com/vga-timing/640x480@60Hz
parameter H   = 640;    // Width of visible area
parameter HFP = 16;     // Not usable area before H-Sync
parameter HS  = 96;     // Width of H-sync
parameter HBP = 48;     // Unavailable range after H-sync

parameter V   = 480;    // Height of visible area
parameter VFP = 10;     // Unavailable area before V-Sync
parameter VS  = 2;      // Height of V-Sync
parameter VBP = 33;     // Not usable range after V-Sync

reg[9:0]  h_cnt;        // Horizontal pixel counter
reg[9:0]  v_cnt;        // Vertical pixel counter

// Disable the unused SDRAM
assign SDRAM_nCS = 1;

localparam BALL_SIZE  = 16;   // Width and height of the ball

// Ball starts at the center of the visible screen area
reg [9:0] ball_x = HS + HBP + (H - BALL_SIZE)/2;
reg [9:0] ball_y = VS + VBP + (V - BALL_SIZE)/2;

//Both counters start with the start of the sync pulse

// horizontaler Pixelzaehler
always@(posedge pixel_clock) begin
	if(h_cnt==HS+HBP+H+HFP-1)   h_cnt <= 0;
	else                        h_cnt <= h_cnt + 1;

	// Generation of the negative H-sync signal
	VGA_HS <= (h_cnt >= HS);
end
  
// Vertical pixel counter
always@(posedge pixel_clock) begin
	// The vertical state changes at the beginning of each line
	if(h_cnt == 0) begin
		if(v_cnt==VS+VBP+V+VFP-1)  v_cnt <= 0; 
		else								v_cnt <= v_cnt + 1;

		// Generation of the negative V-sync signal
		VGA_VS <= (v_cnt >= VS);
	end
end

// Signal which indicates when the electron beam is currently drawing the ball
wire ball = (h_cnt >= ball_x) && (h_cnt < ball_x + BALL_SIZE) &&
				(v_cnt >= ball_y) && (v_cnt < ball_y + BALL_SIZE);

wire pixel = ball;

// White, if "pixel" otherwise black
assign VGA_R = pixel?6'b111111:6'b000000;
assign VGA_G = pixel?6'b111111:6'b000000;
assign VGA_B = pixel?6'b111111:6'b000000;

//PLL to generate the VGA pixel clock from the 27MHz
pll pll (
	 .inclk0(CLOCK_27[0]),
	 .c0(pixel_clock)
 );

endmodule
