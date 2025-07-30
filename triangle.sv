module triangle#(
parameter [11:0]COLOR =12'h000 
) (
    input clk_s          , 
    input rst            , 
    input video_on       , // semnal video activ
    input [11:0] h_count , // contor pe axa X
    input [11:0] v_count , // contor pe axa Y
    input bntL           , // buton stânga
    input bntR           , // buton dreapta
    input bntU           , // buton sus
    input bntD           , // buton jos
    output reg pe_l      , // semnal pentru detectare front stânga
    output reg pe_r      , // semnal pentru detectare front dreapta
    output reg pe_u      , // semnal pentru detectare front sus
    output reg pe_d      , // semnal pentru detectare front jos
    output reg[11:0]rgb    // semnal de culoare RGB
);

localparam signed H_CENTER           = 960 ; // coordonata X a centrului triunghiului
localparam signed V_BASE_LINE        = 540 ; // coordonata Y a bazei triunghiului
localparam signed TRIANGLE_HEIGHT    = 173 ; // înălțimea triunghiului
localparam signed TRIANGLE_HALF_BASE = 100 ; // jumătate din baza triunghiului
localparam signed OFFSET             = 30  ; // offset pentru deplasare

logic signed [11:0] offset_h                       ; // deplasare pe axa X
logic signed [11:0] offset_v                       ; // deplasare pe axa Y
logic signed [11:0] base_center_h                  ; // coordonata X a centrului bazei după deplasare
logic signed [11:0] base_v_coord                   ; // coordonata Y a bazei după deplasare
logic signed [11:0] h_cord                         ; // coordonata X a vârfului triunghiului
logic signed [11:0] v_cord                         ; // coordonata Y a vârfului triunghiului
logic signed [11:0] base_left_h                    ; // coordonata X a colțului stâng al bazei
logic signed [11:0] base_right_h                   ; // coordonata X a colțului drept al bazei
logic signed [23:0] term_h_spread_numerator        ; // termenul pentru lățimea triunghiului
logic signed [11:0] v_span_denominator             ; // denominator pentru calculul proporției pe axa Y
logic signed [11:0] current_calculated_left_edge_h ; // coordonata X a marginii stângi curente
logic signed [11:0] current_calculated_right_edge_h; // coordonata X a marginii drepte curente
logic reg_pe_l                                     ; // registre pentru detectarea fronturilor de la butoane
logic reg_pe_r                                     ; 
logic reg_pe_u                                     ; 
logic reg_pe_d                                     ; 

assign base_center_h = H_CENTER    + offset_h           ; // calculăm poziția centrului bazei după deplasare
assign base_v_coord  = V_BASE_LINE + offset_v           ; // calculăm poziția bazei pe Y după deplasare

assign h_cord   = base_center_h                         ; // vârful triunghiului are aceeași X ca centrul bazei
assign v_cord   = base_v_coord - TRIANGLE_HEIGHT        ; // calculăm coordonata Y a vârfului

assign base_left_h  = base_center_h - TRIANGLE_HALF_BASE; // calculăm X-ul colțului stâng
assign base_right_h = base_center_h + TRIANGLE_HALF_BASE; // calculăm X-ul colțului drept

assign vgaRed   = rgb[11:8]                             ; // canalele de culoare (roșu)
assign vgaGreen = rgb[7:4]                              ; // canalele de culoare (verde)
assign vgaBlue  = rgb[3:0]                              ; // canalele de culoare (albastru)

assign v_span_denominator = TRIANGLE_HEIGHT;                                                      // folosim înălțimea triunghiului pentru denominator
assign term_h_spread_numerator = (v_count - v_cord) * TRIANGLE_HALF_BASE;                         // calculăm numărătorul pentru lățime

assign current_calculated_left_edge_h = (v_span_denominator == 0) ? h_cord :
                                          h_cord - (term_h_spread_numerator / v_span_denominator ); // marginea stângă a triunghiului
assign current_calculated_right_edge_h = (v_span_denominator == 0) ? h_cord :
                                          h_cord + (term_h_spread_numerator / v_span_denominator ); // marginea dreaptă a triunghiului

// blocul care stabilește culoarea în funcție de poziția pixelului
always @(posedge clk_s or posedge rst) begin
    if (rst) rgb <= 12'h000; else 
    if ((v_count >= v_cord) && (v_count <= base_v_coord) &&
        (h_count >= current_calculated_left_edge_h) &&
        (h_count <= current_calculated_right_edge_h)) 
             rgb <= video_on ? COLOR : 12'h000;  else                                                   
             rgb <= video_on ? 12'hF0F : 12'h000;                                                
end

// detectarea frontului pozitiv pe butonul jos
always @(posedge clk_s or posedge rst) begin
    if (rst) reg_pe_d <= 1'b0; else
             reg_pe_d <= bntD;
end
assign pe_d = ~reg_pe_d & bntD;  // detectează frontul pe butonul jos

// detectarea frontului pozitiv pe butonul sus
always @(posedge clk_s or posedge rst) begin
    if (rst) reg_pe_u <= 1'b0; else
             reg_pe_u <= bntU;
end
assign pe_u = ~reg_pe_u & bntU; // detectează frontul pe butonul sus

// detectarea frontului pozitiv pe butonul stânga
always @(posedge clk_s or posedge rst) begin
    if (rst) reg_pe_l <= 1'b0;  else
             reg_pe_l <= bntL;
end
assign pe_l = ~reg_pe_l & bntL; // detectează frontul pe butonul stânga

// detectarea frontului pozitiv pe butonul dreapta
always @(posedge clk_s or posedge rst) begin
    if (rst) reg_pe_r <= 1'b0; else
             reg_pe_r <= bntR;
end
assign pe_r = ~reg_pe_r & bntR; // detectează frontul pe butonul dreapta

// actualizare offset X în funcție de apăsările butoanelor stânga/dreapta
always @(posedge clk_s or posedge rst) begin
    if (rst) offset_h <= 12'b0; else 
    if (pe_r && ((base_right_h+ OFFSET) <= 1919))  offset_h <= offset_h + OFFSET; else           // deplasare dreapta
    if (pe_l && ((base_left_h - OFFSET) >= 0))     offset_h <= offset_h - OFFSET;                // deplasare stânga
end

// actualizare offset Y în funcție de apăsările butoanelor sus/jos
always @(posedge clk_s or posedge rst) begin
    if (rst) offset_v<= 12'b0; else 
    if (pe_d && ((base_v_coord + OFFSET) <= 1079)) offset_v<= offset_v+ OFFSET; else            // deplasare jos
    if (pe_u && ((v_cord       - OFFSET) >= 0))    offset_v<= offset_v- OFFSET;                 // deplasare sus
end






endmodule
