/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* MVM Control FSM                                 */
/***************************************************/

module ctrl # (
    parameter VEC_ADDRW = 8,
    parameter MAT_ADDRW = 9,
    parameter VEC_SIZEW = VEC_ADDRW + 1,
    parameter MAT_SIZEW = MAT_ADDRW + 1
    
)(
    input  clk,
    input  rst,
    input  start,
    input  [VEC_ADDRW-1:0] vec_start_addr,
    input  [VEC_SIZEW-1:0] vec_num_words,
    input  [MAT_ADDRW-1:0] mat_start_addr,
    input  [MAT_SIZEW-1:0] mat_num_rows_per_olane,
    output [VEC_ADDRW-1:0] vec_raddr,
    output [MAT_ADDRW-1:0] mat_raddr,
    output accum_first,
    output accum_last,
    output ovalid,
    output busy
);

/******* Your code starts here *******/
// input registers  
logic  [VEC_ADDRW-1:0] r_vec_start_addr;
logic  [VEC_SIZEW-1:0] r_vec_num_words;
logic  [MAT_ADDRW-1:0] r_mat_start_addr;
logic  [MAT_SIZEW-1:0] r_mat_num_rows_per_olane;

// output registers
logic [VEC_ADDRW-1:0] r_vec_raddr;
logic [MAT_ADDRW-1:0] r_mat_raddr;
logic r_accum_first;
logic r_accum_last; 
logic r_ovalid; 
logic r_busy;

// counters  
logic [MAT_SIZEW-1:0] row_counter;
logic [VEC_SIZEW-1:0] vector_word_counter;

//pipelining 
logic [MAT_ADDRW-1:0] row_base_addr;
logic [VEC_SIZEW-1:0] vec_num_words_minus_1;
logic [MAT_SIZEW-1:0] mat_rows_minus_1;


enum {IDLE, COMPUTE} state, next_state;


always_ff @ (posedge clk) begin
    if (rst) begin
        state <= IDLE;
        
        r_vec_start_addr <= '0;
        r_vec_num_words <= '0;
        r_mat_start_addr <= '0;
        r_mat_num_rows_per_olane <= '0;
        row_counter <= '0; 
        vector_word_counter <= '0;
        
        row_base_addr <= '0;
        vec_num_words_minus_1 <= '0;
        mat_rows_minus_1 <= '0;    
       
     end else begin
        state <= next_state; 
        
        if (state == IDLE && start) begin
            r_vec_start_addr <= vec_start_addr;
            r_vec_num_words <= vec_num_words;
            r_mat_start_addr <= mat_start_addr;
            r_mat_num_rows_per_olane <= mat_num_rows_per_olane;
            
            vec_num_words_minus_1 <= vec_num_words - 1;
            mat_rows_minus_1 <= mat_num_rows_per_olane - 1;
            
            row_counter <= '0;
            vector_word_counter <= '0;
            row_base_addr <= mat_start_addr;
        end
        
        if (state == COMPUTE) begin
            if(vector_word_counter == r_vec_num_words - 1) begin
                vector_word_counter <= '0;
                if(row_counter == r_mat_num_rows_per_olane - 1) begin
                    row_counter <= '0;
                end else begin
                    row_counter <= row_counter + 1;
                    row_base_addr <= row_base_addr + r_vec_num_words;
                end
            end else begin
                vector_word_counter <= vector_word_counter + 1;
            end
        end
     end
end


always_comb begin: state_decoder
    case(state)
        IDLE: next_state = (start)? COMPUTE : IDLE;
        COMPUTE: next_state = (
            vector_word_counter  == r_vec_num_words -1  && 
            row_counter == r_mat_num_rows_per_olane -1) ? IDLE : COMPUTE; 
        default : next_state = IDLE;
    endcase 
end 

always_comb begin: output_decoder

    case(state)
        IDLE: begin
            r_vec_raddr = '0;
            r_mat_raddr = '0;
            r_accum_first = '0;
            r_accum_last = '0; 
            r_ovalid = '0; 
            r_busy = '0;
            
        end
         
        COMPUTE: begin
            r_vec_raddr = r_vec_start_addr + vector_word_counter;
            r_mat_raddr = row_base_addr + vector_word_counter;
            
            if (vector_word_counter == 0) r_accum_first = '1; 
            else r_accum_first = '0;
            
            if (vector_word_counter == r_vec_num_words - 1) r_accum_last = '1;
            else r_accum_last = '0;
            
            r_ovalid = '1;
            r_busy = '1;          
        end
        
        default: begin
            r_vec_raddr = '0;
            r_mat_raddr = '0;
            r_accum_first = '0;
            r_accum_last = '0; 
            r_ovalid = '0; 
            r_busy = '0;
        end

     endcase
end
    
assign vec_raddr = r_vec_raddr;
assign mat_raddr = r_mat_raddr;
assign accum_first = r_accum_first;
assign accum_last = r_accum_last; 
assign ovalid = r_ovalid; 
assign busy = r_busy;

/******* Your code ends here ********/

endmodule