/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* 8-Lane Dot Product Module                       */
/***************************************************/

module dot8 # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32
)(
    input clk,
    input rst,
    input signed [8*IWIDTH-1:0] vec0,
    input signed [8*IWIDTH-1:0] vec1,
    input ivalid,
    output signed [OWIDTH-1:0] result,
    output ovalid
);

/******* Your code starts here *******/

logic signed [IWIDTH-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
logic signed [IWIDTH-1:0] b0, b1, b2, b3, b4, b5, b6, b7;

logic r_valid_0, r_valid_1, r_valid_2, r_valid_3, r_valid_4, r_valid_5, r_valid_6, r_valid_7;

logic signed [2*IWIDTH+1:0] temp_mul_0, temp_mul_1, temp_mul_2, temp_mul_3, temp_mul_4, temp_mul_5, temp_mul_6, temp_mul_7;

logic signed [2*IWIDTH+2:0] first_add_0, first_add_1, first_add_2, first_add_3;

logic signed [2*IWIDTH+3:0] second_add_0, second_add_1;

logic signed [2*IWIDTH+3:0] temp_second_add_0, temp_second_add_1;

logic signed [OWIDTH-1:0] final_add_0;

logic signed [2*IWIDTH+1:0] temp_mul_before_first_add_0, temp_mul_before_first_add_1, temp_mul_before_first_add_2, temp_mul_before_first_add_3, temp_mul_before_first_add_4, temp_mul_before_first_add_5, temp_mul_before_first_add_6, temp_mul_before_first_add_7;

logic signed [2*IWIDTH+2:0] temp_first_add_0, temp_first_add_1, temp_first_add_2, temp_first_add_3;

always_ff @ (posedge clk) begin
    if(rst) begin
        // Reset all pipeline registers
        a0 <= 0; a1 <= 0; a2 <= 0; a3 <= 0; a4 <= 0; a5 <= 0; a6 <= 0; a7 <= 0;
        b0 <= 0; b1 <= 0; b2 <= 0; b3 <= 0; b4 <= 0; b5 <= 0; b6 <= 0; b7 <= 0;
        
        r_valid_0 <= 0; r_valid_1 <= 0; r_valid_2 <= 0; r_valid_3 <= 0; r_valid_4 <= 0; 
   
        temp_mul_0 <= 0; temp_mul_1 <= 0; temp_mul_2 <= 0; temp_mul_3 <= 0; temp_mul_4 <= 0; temp_mul_5 <= 0; 
        temp_mul_6 <= 0; temp_mul_7 <= 0;
        temp_mul_before_first_add_0 <= 0;
        temp_mul_before_first_add_1 <= 0;
        temp_mul_before_first_add_2 <= 0;
        temp_mul_before_first_add_3 <= 0;
        temp_mul_before_first_add_4 <= 0;
        temp_mul_before_first_add_5 <= 0;
        temp_mul_before_first_add_6 <= 0;
        temp_mul_before_first_add_7 <= 0;
        
        temp_first_add_0 <= 0;
        temp_first_add_1 <= 0;
        temp_first_add_2 <= 0;
        temp_first_add_3 <= 0;
        
        temp_second_add_0 <= 0;
        temp_second_add_1 <= 0;
        
        first_add_0 <= 0; first_add_1 <= 0; first_add_2 <= 0; first_add_3 <= 0;
        
        second_add_0 <= 0; second_add_1 <= 0;
        
        final_add_0 <= 0;
        
    
    end else begin
    
        // Stage 0: Input
        a7 <= vec0[IWIDTH-1:0]; a6 <= vec0[2*IWIDTH-1:IWIDTH] ; a5 <= vec0[3*IWIDTH-1:2*IWIDTH]; a4 <= vec0[4*IWIDTH-1:3*IWIDTH]; 
        a3 <= vec0[5*IWIDTH-1:4*IWIDTH]; a2 <= vec0[6*IWIDTH-1:5*IWIDTH]; a1 <= vec0[7*IWIDTH-1:6*IWIDTH]; a0 <= vec0[8*IWIDTH-1:7*IWIDTH];
        
        b7 <= vec1[IWIDTH-1:0]; b6 <= vec1[2*IWIDTH-1:IWIDTH] ; b5 <= vec1[3*IWIDTH-1:2*IWIDTH]; b4 <= vec1[4*IWIDTH-1:3*IWIDTH]; 
        b3 <= vec1[5*IWIDTH-1:4*IWIDTH]; b2 <= vec1[6*IWIDTH-1:5*IWIDTH]; b1 <= vec1[7*IWIDTH-1:6*IWIDTH]; b0 <= vec1[8*IWIDTH-1:7*IWIDTH];
        r_valid_0 <= ivalid;
        
        // Stage 1: after mul 
        temp_mul_0 <= a0 * b0; 
        temp_mul_1 <= a1 * b1; 
        temp_mul_2 <= a2 * b2; 
        temp_mul_3 <= a3 * b3; 
        temp_mul_4 <= a4 * b4; 
        temp_mul_5 <=  a5 * b5; 
        temp_mul_6 <= a6 * b6; 
        temp_mul_7 <= a7 * b7;
        
        r_valid_1 <= r_valid_0;
        
        // stage 1.5: before first add
        temp_mul_before_first_add_0 <= temp_mul_0;
        temp_mul_before_first_add_1 <= temp_mul_1;
        temp_mul_before_first_add_2 <= temp_mul_2;
        temp_mul_before_first_add_3 <= temp_mul_3;
        temp_mul_before_first_add_4 <= temp_mul_4;
        temp_mul_before_first_add_5 <= temp_mul_5;
        temp_mul_before_first_add_6 <= temp_mul_6;
        temp_mul_before_first_add_7 <= temp_mul_7;
        
        r_valid_2 <= r_valid_1;
        // add an rvalid here
        
        // Stage 2: after first add 
        
        first_add_0 <= temp_mul_before_first_add_0 + temp_mul_before_first_add_1; 
        first_add_1 <= temp_mul_before_first_add_2 + temp_mul_before_first_add_3; 
        first_add_2 <= temp_mul_before_first_add_4 + temp_mul_before_first_add_5; 
        first_add_3 <= temp_mul_before_first_add_6 + temp_mul_before_first_add_7;
        
        r_valid_3 <= r_valid_2;
        
        // stage 2.5: before second add 
        
        temp_first_add_0 <= first_add_0;
        temp_first_add_1 <= first_add_1;
        temp_first_add_2 <= first_add_2;
        temp_first_add_3 <= first_add_3;
        
        r_valid_4 <= r_valid_3;
        // Stage 3: second add 
        
        second_add_0 <= temp_first_add_0 + temp_first_add_1; 
        second_add_1 <= temp_first_add_2 + temp_first_add_3;
        
        r_valid_5 <= r_valid_4;
        
        // Stage 3.5: before final add
        
        temp_second_add_0 <= second_add_0;
        temp_second_add_1 <= second_add_1;
        
        r_valid_6 <= r_valid_5;

        // Stage 4: final add
        
        final_add_0 <= temp_second_add_0 + temp_second_add_1;    
        
        r_valid_7 <= r_valid_6;       
        
    end
end   

assign ovalid = r_valid_7;
assign result = final_add_0;


/******* Your code ends here ********/

endmodule