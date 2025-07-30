module vga_controller
#(
    parameter H_RES = 1920,
    parameter H_FRONT_PORCH = 88,
    parameter H_SYNC_PULSE = 44,
    parameter H_BACK_PORCH = 148,

    parameter V_RES = 1080,
    parameter V_FRONT_PORCH = 4,
    parameter V_SYNC_PULSE = 5,
    parameter V_BACK_PORCH = 36
)
(
    input clk,
    input rst,
    output video_on,
    output hsync,
    output vsync,
    output reg [11:0] h_count,
    output reg [11:0] v_count
);


    localparam H_FRAME = H_RES + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH - 1;
    localparam V_FRAME = V_RES + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH - 1;
   
always @(posedge clk or posedge rst) begin
if (rst)                 h_count <= 12'b0;    else
if (h_count == H_FRAME)  h_count <= 12'b0;    else
                         h_count <= h_count + 1;
    end

always @(posedge clk or posedge rst) begin
  if (rst) v_count <= 12'b0;  else 
  if (h_count == H_FRAME)     begin
  if (v_count == V_FRAME)  v_count <= 12'b0;else
                           v_count <= v_count + 1;
  end
end
    
    assign hsync    = ((h_count >= (H_RES + H_FRONT_PORCH)) && (h_count <  (H_RES + H_FRONT_PORCH + H_SYNC_PULSE)));
    assign vsync    = ((v_count >= (V_RES + V_FRONT_PORCH)) &&(v_count <  (V_RES + V_FRONT_PORCH + V_SYNC_PULSE)));
    assign video_on = (h_count < H_RES) && (v_count < V_RES);
  
    assign p_tick = clk;

endmodule
