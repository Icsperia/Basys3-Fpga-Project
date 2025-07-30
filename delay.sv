// Original delay module with corrected bit width for 'delay' register
module delay#(
    parameter VAL_DLY = 1000000 // Default delay value (e.g., for 10ms at 100MHz clock)
)(
    input clk,     // Clock signal
    input rst,     // Reset signal
    input btn,     // Button input (active high)
    output reg delay_en // Output pulse, high for one clock cycle periodically
);

// 'delay' register must be wide enough to hold VAL_DLY.
// For VAL_DLY = 1,000,000, we need 20 bits (2^19 < 1M < 2^20).
reg [19:0] delay; // Corrected from [17:0]

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // On reset, clear counter and disable pulse
        delay <= 0;
        delay_en <= 0;
    end else begin
        if (btn) begin
            // If button is pressed, increment counter
            if (delay >= VAL_DLY) begin
                // If counter reaches VAL_DLY, generate a pulse and reset counter
                delay <= 0;
                delay_en <= 1; // Pulse for one cycle
            end else begin
                // Continue counting
                delay <= delay + 1;
                delay_en <= 0; // Keep pulse low
            end
        end else begin
            // If button is released, reset counter and disable pulse immediately
            delay <= 0;
            delay_en <= 0;
        end
    end
end
endmodule