module circle#
(
    parameter P_H          = 0 , // Poziția inițială pe orizontală
    parameter P_V          = 0 , // Poziția fixă pe verticală
    parameter radius       = 0 , // Raza cercului
    parameter [11:0] COLOR = 12'hFFF       // Culoarea cercului (format RGB 12-bit)
)(
    input  clk           ,                            
    input  rst           ,                            
    input  video_on      , // Semnal activ pentru afișare video
    input [11:0] rc0_h1, // Left paddle H1
    input [11:0] rc0_h2, // Left paddle H2
    input [11:0] rc0_v1, // Left paddle V1
    input [11:0] rc0_v2, // Left paddle V2
    input [11:0] rc1_h1, // Right paddle H1
    input [11:0] rc1_h2, // Right paddle H2
    input [11:0] rc1_v1, // Right paddle V1
    input [11:0] rc1_v2, // Right paddle V2
    input [11:0] h_count, // Coordonata curentă orizontală (pixel)
    input [11:0] v_count, // Coordonata curentă verticală (pixel)
    output reg [11:0] rgb                  // Ieșirea RGB (culoarea pixelului curent)
);

    localparam SCREEN_WIDTH  = 1920  ; // Lățimea ecranului
    localparam SCREEN_LENGTH = 1080  ;
   
    logic [11:0] h_pos               ; // Poziția curentă a cercului pe axa X
    logic [11:0] v_pos               ; // Poziția curentă a cercului pe axa X
    logic [20:0] dh, dv              ; // Distanțe pe X și Y față de pixelul curent
    logic [20:0] distance            ; // Pătratul distanței de la centru la pixel
    logic [20:0] p_radius            ; // Pătratul razei
    logic        dir_right           ; // Direcția de mișcare: 1 = dreapta, 0 = stânga
    logic        move_tick           ; // Semnal de temporizare pentru mișcare
    logic        dir_down            ; 
    logic rec_hit_dect               ;
    logic rec_hit_dect_left; // Collision with left rectangle
    logic rec_hit_dect_right; // Collision with right rectangle
    logic any_rec_hit_dect; // Collision with any rectangle
    
    assign p_radius = radius * radius; // Calculăm raza la pătrat o singură dată
    assign dh = h_count - h_pos      ; // Distanța orizontală față de centru
    assign dv = v_count - v_pos      ; // Distanța verticală față de centru (fixă)
    assign distance = dh*dh + dv*dv  ; // Pătratul distanței euclidiene
    
   assign rec_hit_dect_left  = ((h_pos + radius >= rc0_h1) && (h_pos - radius <= rc0_h2) &&
                                 (v_pos + radius >= rc0_v1) && (v_pos - radius <= rc0_v2));

    // Collision detection for right paddle
    assign rec_hit_dect_right = ((h_pos + radius >= rc1_h1) && (h_pos - radius <= rc1_h2) &&
                                 (v_pos + radius >= rc1_v1) && (v_pos - radius <= rc1_v2));

    // Combined collision detection
    assign any_rec_hit_dect = rec_hit_dect_left || rec_hit_dect_right;


delay #(
.VAL_DLY(100000)              
        )delay_i_u(
        .clk    (clk      ),
        .rst    (rst      ),
        .btn    (1'b1     ),
       .delay_en(move_tick)
        );






    // ==============================
    // Bloc always pentru mișcarea cercului
    // ==============================
    always @(posedge clk or posedge rst) begin
        if (rst || any_rec_hit_dect) begin
            h_pos <= P_H/2;
            dir_right <= 1;
        end else if (move_tick) begin
            if (dir_right) begin
                if (h_pos + radius + 1 >= SCREEN_WIDTH) dir_right <= 0;    else      
                                                            h_pos <= h_pos + 1;
            end else begin
                if (h_pos <= radius + 1)  dir_right <= 1; else
                                              h_pos <= h_pos - 1;
            end
        end
    end
    
   
       always @(posedge clk or posedge rst) begin
        if (rst ||  any_rec_hit_dect) begin
            v_pos <= P_V/2;
            dir_down <= 1;
        end else if (move_tick) begin
            if (dir_down) begin
                if (v_pos + radius + 1 >= SCREEN_LENGTH) dir_down<= 0;    else      
                                                          v_pos <= v_pos + 1;
            end else begin
                if (v_pos <= radius + 1)  dir_down <= 1; else
                                             v_pos <= v_pos - 1;
            end
        end
    end
   
   
    // ==============================
    // Bloc always pentru generarea semnalului RGB
    // ==============================
   
    always@(posedge clk or posedge rst) begin
        if (rst)rgb <= 12'h000;else
        if (distance <= p_radius) rgb <= video_on ? COLOR : 12'h000;  else      
                                  rgb <= 12'h000;      
    end

endmodule
