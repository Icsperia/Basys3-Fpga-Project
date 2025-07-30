module rectangle#(
  
    parameter RC_H1 = 0,               // Coordonata orizontală stânga
    parameter RC_H2 = 0,               // Coordonata orizontală dreapta
    parameter RC_V1 = 0,               // Coordonata verticală sus
    parameter RC_V2 = 0,               // Coordonata verticală jos
    parameter [11:0] COLOR = 12'h000   // Culoare dreptunghi 
)(
    input clk            ,                         
    input rst            , // Reset asincron
    input video_on       , // Semnal activ video (afișare activă)
    input btnU           , // Buton sus
    input btnD           , // Buton jos
    input [11:0] h_count , // Coordonata pixel curent (orizontal)
    input [11:0] v_count , // Coordonata pixel curent (vertical)
    output reg [11:0] rgb, // Culoarea pixelului curent
    output pe_u          , // Semnal pentru front pozitiv pe btnU
    output pe_d          , // Semnal pentru front pozitiv pe btnD
    output  [11:0] current_rc_h1, // New: Output actual H1
    output  [11:0] current_rc_h2, // New: Output actual H2
    output  [11:0] current_rc_v1, // New: Output actual V1
    output  [11:0] current_rc_v2  // New: Output actual V2
);

localparam signed OFFSET = 10  ; // Pasul de deplasare verticală a dreptunghiului

// Semnale interne
logic signed [11:0] offset_ver1; // Deplasare verticală a dreptunghiului
logic reg_pe_r                 ; // Registru pentru front pozitiv pe btnD
logic reg_pe_u                 ; // Registru pentru front pozitiv pe btnU
logic delay_up                 ; // Semnal de întârziere pentru btnU (debounce)
logic delay_down               ; // Semnal de întârziere pentru btnD (debounce)

   // Assign current positions to outputs
    assign current_rc_h1 = RC_H1; // H positions are fixed by parameter
    assign current_rc_h2 = RC_H2;
    assign current_rc_v1 = RC_V1 + offset_ver1;
    assign current_rc_v2 = RC_V2 + offset_ver1;


// ==============================
// Afișarea dreptunghiului
// ==============================   
always @(posedge clk or posedge rst) begin
    if (rst)  rgb <= 12'h000;   else 
    if (((h_count >= current_rc_h1) && (h_count <=  current_rc_h2)) && ((v_count >= current_rc_v1) && (v_count <= current_rc_v2)))
        rgb <= video_on ? COLOR : 12'h000; else
        rgb <= 12'h000 ;
end



// ==============================
// Mișcarea verticală a dreptunghiului
// ==============================
always @(posedge clk or posedge rst ) begin
    if(rst) offset_ver1 <= 12'b0;  else  
    if (delay_down) begin 
    if ((RC_V2 + offset_ver1 + OFFSET) <= 1079) offset_ver1 <= offset_ver1 + OFFSET; 
    end else
    if (delay_up) begin 
    if ((RC_V1 + offset_ver1 - OFFSET) >= 0)    offset_ver1 <= offset_ver1 - OFFSET;   
        end
        
    end


           

delay #(
.VAL_DLY(1000000)              
    )delay_i_u(
        .clk      (clk      ),
        .rst      (rst      ),
        .btn      (btnU     ),
        .delay_en (delay_up )
                            );

delay #(
.VAL_DLY(1000000)      
        )delay_i_d(
        .clk     (clk        ),
        .rst     (rst        ),
        .btn     (btnD       ),
        .delay_en(delay_down )
        );

endmodule
