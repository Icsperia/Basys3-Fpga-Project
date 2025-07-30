module top(
    input  clk           ,
    input  rst           ,
    input btnU           ,
    input btnD           ,
    input btnL           ,
    input btnR           ,
    output       Hsync   ,
    output       Vsync   ,
    output [3:0] vgaRed  ,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue 

);

logic [19:0]delay    ;
logic [11:0]rgb      ;
logic [11:0]h_count  ;
logic [11:0]v_count  ;
logic [11:0]rgb_tr   ;
logic [11:0]rgb_rc   ;
logic [11:0]rgb_rc0  ;
logic [11:0]rgb_rc1  ;
logic [11:0]rgb_rc2  ;
logic [11:0]rgb_rc3  ;
logic [11:0]rgb_pre  ;
logic [3:0]red       ;
logic [3:0]green     ;
logic [3:0]blue      ;
logic clk_148Mhz     ;
logic video_on       ;
logic [11:0] left_rc_h1;
logic [11:0] left_rc_h2; 
logic [11:0] left_rc_v1; 
logic [11:0] left_rc_v2;
logic [11:0] right_rc_h1;
logic [11:0] right_rc_h2; 
logic [11:0] right_rc_v1; 
logic [11:0] right_rc_v2; 


assign vgaRed  = rgb[11:8]       ;
assign vgaGreen= rgb[7:4]        ;
assign vgaBlue = rgb[3:0]        ;
assign rgb_pre = (rgb_rc1 != 12'h000) ? rgb_rc1 :
                 (rgb_rc0 != 12'h000) ? rgb_rc0 :
                 (rgb_tr  != 12'h000) ? rgb_tr  :
                 (rgb_circ!= 12'h000) ? rgb_circ:
                 12'hF00; 

assign rgb = video_on ? rgb_pre : 12'h000;

//assign rgb_rc = rgb_rc0 | rgb_rc1 | rgb_rc3;


design_1_wrapper design_1_wrapper_i(
        .clk_in1_0(clk        ),
        .clk_out1_0(clk_148Mhz),
        .reset_0(rst          )
        );


vga_controller vga_ctrl(
        .clk     (clk_148Mhz  ) ,
        .rst     (rst         ) ,
        .video_on(video_on    ) ,
        .hsync   (Hsync       ) ,
        .vsync   (Vsync       ) ,
        .h_count (h_count     ) ,
        .v_count (v_count     )
        );
        
circle#
(
        .P_H      (959       ) ,
        .P_V      (540       ) ,
        .radius   (60        ) ,
        .COLOR    (12'hFFF   )
) color_i  (
        .clk     (clk_148Mhz) ,
        .rst     (rst       ) ,
        .video_on(video_on  ) ,
        .h_count (h_count   ) ,
        .v_count (v_count   ) ,
        .rc0_h1       (left_rc_h1), // Pass left paddle's current H1
        .rc0_h2     (left_rc_h2), // Pass left paddle's current H2
        .rc0_v1     (left_rc_v1), // Pass left paddle's current V1
        .rc0_v2     (left_rc_v2), // Pass left paddle's current V2
        .rc1_h1     (right_rc_h1), // Pass right paddle's current H1
        .rc1_h2     (right_rc_h2), // Pass right paddle's current H2
        .rc1_v1     (right_rc_v1), // Pass right paddle's current V1
        .rc1_v2     (right_rc_v2), // Pass right paddle's current V2
        .rgb       (rgb_circ  )
);


rectangle #(
        .RC_H1 (100), // Coordonata orizontală stânga
        .RC_H2 (200), // Coordonata orizontală dreapta
        .RC_V1 (0  ), // Coordonata verticală sus
        .RC_V2 (250), // Coordonata verticală jos
        .COLOR  (12'hFFF)   
) rectangle_left_i (
        .clk      (clk_148Mhz),
        .rst      (rst       ),
        .video_on (video_on  ),
        .h_count  (h_count   ),
        .v_count  (v_count   ), 
        .rgb      (rgb_rc0   ),
        .btnU     (btnU      ),
        .btnD     (btnR      ),
        .current_rc_h1 (left_rc_h1), // Connect outputs
        .current_rc_h2 (left_rc_h2),
        .current_rc_v1 (left_rc_v1),
        .current_rc_v2 (left_rc_v2)
);


rectangle #(
        .RC_H1  (1700   ),      // 100 pixels from the far right
        .RC_H2  (1800   ),      // Far right
        .RC_V1  (0      ),       // Start Y
        .RC_V2  (250    ),      // Bottom edge
        .COLOR  (12'hFFF) 

) rectangle_right_i (
        .clk      (clk_148Mhz),
        .rst      (rst       ),
        .video_on (video_on  ),
        .h_count  (h_count   ),
        .v_count  (v_count   ),
        .rgb      (rgb_rc1   ),
        .btnU     (btnL      ),
        .btnD     (btnD      ),
        .current_rc_h1 (right_rc_h1), // Connect outputs
        .current_rc_h2 (right_rc_h2),
        .current_rc_v1 (right_rc_v1),
        .current_rc_v2 (right_rc_v2)
);




endmodule