/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Accumulator Module                              */
/***************************************************/

module accum # (
    parameter DATAW = 32,
    parameter ACCUMW = 32
)(
    input  clk,
    input  rst,
    input  signed [DATAW-1:0] data,
    input  ivalid,
    input  first,
    input  last,
    output signed [ACCUMW-1:0] result,
    output ovalid
);

/******* Your code starts here *******/
logic signed [ACCUMW-1:0] accumulation_r;
logic signed [DATAW-1:0] data_r;
logic ivalid_r, first_r, last_r, ovalid_r;

always_ff @ (posedge clk) begin
    if(rst) begin
        accumulation_r <= 0;
        data_r <= 0;
        
    end else begin
        ovalid_r <= 0;
        if (ivalid) begin
            if (first) begin
                accumulation_r <= data; 
            end else begin
                accumulation_r <= accumulation_r + data;
            end
            
            if (last) ovalid_r <= 1;
        end
    end
end

assign ovalid = ovalid_r;
assign result = accumulation_r;



/******* Your code ends here ********/

endmodule