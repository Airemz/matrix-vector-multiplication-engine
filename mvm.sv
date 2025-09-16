/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Matrix Vector Multiplication (MVM) Module       */
/***************************************************/

module mvm # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32,
    parameter MEM_DATAW = IWIDTH * 8,
    parameter VEC_MEM_DEPTH = 256,
    parameter VEC_ADDRW = $clog2(VEC_MEM_DEPTH),
    parameter MAT_MEM_DEPTH = 512,
    parameter MAT_ADDRW = $clog2(MAT_MEM_DEPTH),
    parameter NUM_OLANES = 8
)(
    input clk,
    input rst,
    input [MEM_DATAW-1:0] i_vec_wdata,
    input [VEC_ADDRW-1:0] i_vec_waddr,
    input i_vec_wen,
    input [MEM_DATAW-1:0] i_mat_wdata,
    input [MAT_ADDRW-1:0] i_mat_waddr,
    input [NUM_OLANES-1:0] i_mat_wen,
    input i_start,
    input [VEC_ADDRW-1:0] i_vec_start_addr,
    input [VEC_ADDRW:0] i_vec_num_words,
    input [MAT_ADDRW-1:0] i_mat_start_addr,
    input [MAT_ADDRW:0] i_mat_num_rows_per_olane,
    output o_busy,
    output [OWIDTH-1:0] o_result [0:NUM_OLANES-1],
    output o_valid
);

/******* Your code starts here *******/

logic [MEM_DATAW-1:0] vec_rdata;
logic [VEC_ADDRW-1:0] vec_raddr;

logic [MEM_DATAW-1:0] matrix_rdata [0:NUM_OLANES-1];
logic [MAT_ADDRW-1:0] mat_raddr;

logic dot8_ovalid [0:NUM_OLANES - 1];
logic [OWIDTH-1:0] dot8_result [0:NUM_OLANES-1]; //double regitsers when pipelineing

logic accum_ovalid [0:NUM_OLANES - 1];


logic ctrl_ivalid;
logic accum_first;
logic accum_last;

// pipelining registers
logic ctrl_ivalid_pr1;
logic accum_first_pr1, accum_first_pr2, accum_first_pr3, accum_first_pr4, accum_first_pr5, accum_first_pr6;
logic accum_first_pr7, accum_first_pr8, accum_first_pr9;
logic accum_last_pr1, accum_last_pr2, accum_last_pr3, accum_last_pr4, accum_last_pr5, accum_last_pr6;
logic accum_last_pr7, accum_last_pr8, accum_last_pr9;
 

mem #(.DATAW(MEM_DATAW), .DEPTH(VEC_MEM_DEPTH), .ADDRW(VEC_ADDRW)) vec_mem(
    .clk(clk),
    .wdata(i_vec_wdata),
    .waddr(i_vec_waddr),
    .wen(i_vec_wen),
    .raddr(vec_raddr),
    .rdata(vec_rdata)
);

ctrl #( .VEC_ADDRW(VEC_ADDRW), 
        .MAT_ADDRW(MAT_ADDRW), 
        .VEC_SIZEW(VEC_ADDRW + 1), 
        .MAT_SIZEW(MAT_ADDRW + 1)) ctrl_fsm( // VEC_SIZEW and MAT_SIZEW might be wrong!
            .clk(clk),
            .rst(rst),
            .start(i_start),
            .vec_start_addr(i_vec_start_addr),
            .vec_num_words(i_vec_num_words),
            .mat_start_addr(i_mat_start_addr),
            .mat_num_rows_per_olane(i_mat_num_rows_per_olane),
            .vec_raddr(vec_raddr),
            .mat_raddr(mat_raddr),
            .accum_first(accum_first),
            .accum_last(accum_last),
            .ovalid(ctrl_ivalid),
            .busy(o_busy) 
);

genvar i;
generate 
    for (i = 0; i < NUM_OLANES; i = i + 1)
    begin: gen_lane 
        mem #( .DATAW(MEM_DATAW), .DEPTH(MAT_MEM_DEPTH), .ADDRW(MAT_ADDRW)) matrix_mem (
            .clk(clk),
            .wdata(i_mat_wdata),
            .waddr(i_mat_waddr),
            .wen(i_mat_wen[i]),
            .raddr(mat_raddr),
            .rdata(matrix_rdata[i])
        );
        
        dot8 #(.IWIDTH(IWIDTH), .OWIDTH(OWIDTH)) dot8_unit (
            .clk(clk),
            .rst(rst),
            .vec0(vec_rdata), 
            .vec1(matrix_rdata[i]), 
            .ivalid(ctrl_ivalid_pr1),   
            .result(dot8_result[i]), 
            .ovalid(dot8_ovalid[i])     
        );
        
        accum #(.DATAW(OWIDTH), .ACCUMW(OWIDTH)) accum_unit (
            .clk(clk),
            .rst(rst),
            .data(dot8_result[i]), 
            .ivalid(dot8_ovalid[i]),
            .first(accum_first_pr9),
            .last(accum_last_pr9),
            .result(o_result[i]),
            .ovalid(accum_ovalid[i])   
        );
     end
endgenerate    

always_ff @ (posedge clk) begin
    if(rst) begin

        ctrl_ivalid_pr1 <= '0;
        accum_first_pr1 <= '0;
        accum_first_pr2 <= '0;
        accum_first_pr3 <= '0;
        accum_first_pr4 <= '0;
        accum_first_pr5 <= '0;
        accum_first_pr6 <= '0;
        accum_last_pr1 <= '0;
        accum_last_pr2 <= '0;
        accum_last_pr3 <= '0;
        accum_last_pr4 <= '0;
        accum_last_pr5 <= '0;
        accum_last_pr6 <= '0;

    end else begin
        // stage 1
        ctrl_ivalid_pr1 <= ctrl_ivalid;
        accum_first_pr1 <= accum_first;
        accum_last_pr1 <= accum_last;
       
         
        // stage 2
        accum_first_pr2 <= accum_first_pr1;
        accum_last_pr2 <= accum_last_pr1;


        // stage 3
        accum_first_pr3 <= accum_first_pr2;
        accum_last_pr3 <= accum_last_pr2;
        
        // stage 4
        accum_first_pr4 <= accum_first_pr3;
        accum_last_pr4 <= accum_last_pr3;
        
        // stage 5
        accum_first_pr5 <= accum_first_pr4;
        accum_last_pr5 <= accum_last_pr4;
        
        // stage 6
        accum_first_pr6 <= accum_first_pr5;
        accum_last_pr6 <= accum_last_pr5;
        
        // stage 7
        accum_first_pr7 <= accum_first_pr6;
        accum_last_pr7 <= accum_last_pr6;
        
        // stage 8
        accum_first_pr8 <= accum_first_pr7;
        accum_last_pr8 <= accum_last_pr7;
        
        // stage 9
        accum_first_pr9 <= accum_first_pr8;
        accum_last_pr9 <= accum_last_pr8;
        
        
    end
end

assign o_valid = accum_ovalid[0];


/******* Your code ends here ********/

endmodule