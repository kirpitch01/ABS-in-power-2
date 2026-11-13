//  Three tests 
// 1. Sending maximum values.
// 2. Sending minimum value.
// 3. Sending sequency.
//
`timescale 1ns / 1ps

module abs_in_pow2_tb(

    );
 localparam data_width = 16;
 localparam vector_length = 128;  
 localparam DELAY = 2; 
reg clk = 0;

reg signed [15:0] re = 16'd0;
reg signed [15:0] im = 16'd0;
wire  [32:0] out;
wire valid_out;
reg valid_in;
reg seq_test;
reg signed [data_width - 1:0 ] data_sim_re [vector_length-1:0];
reg signed [data_width - 1:0 ] data_sim_im [vector_length-1:0];
reg signed [data_width * 2:0 ] data_out_gen [vector_length-1:0];

int test_cnt = 0;
int seq_idx;
int i;
initial begin
    forever #4 
        clk = ~clk;
end


    initial 
        begin
            for (i = 0; i < vector_length + 2; i++)
                begin
                    if (i == 0)
                        begin
                            data_sim_re[i] = { 1'b0, {(data_width-1){1'b1}} };
                            data_sim_im[i] = { 1'b0, {(data_width-1){1'b1}} };
                            data_out_gen[i] =   2  * (2**15 -1)**2;
                        end
                    else if ( i == 1)
                        begin
                            data_sim_re[i] = { 1'b1, {(data_width-1){1'b0}} };
                            data_sim_im[i] = { 1'b1, {(data_width-1){1'b0}} };
                            data_out_gen[i] =   2  * (2**15)**2;           
                        end   
                    else 
                        begin    
                            data_sim_re[i] = data_width'($urandom_range(2**(data_width-1)-1, -1*(2**(data_width-2))));
                            data_sim_im[i] = data_width'($urandom_range(2**(data_width-1)-1, -1*(2**(data_width-2)))); 
                            data_out_gen[i] =  data_sim_re[i]*data_sim_re[i] + data_sim_im[i]*data_sim_im[i];
                        end    
                end 
        end

 
 task send_sequence;
 input [$clog2(vector_length+2)-1:0 ]idx;
    begin
        test_cnt = test_cnt + 1;
        valid_in = 1'b1;
        re = data_sim_re[idx];
        im = data_sim_im[idx];
        
        @(posedge clk);
    end
 endtask

 
 initial 
 begin
        @(posedge clk);    

    for ( seq_idx = 0; seq_idx < vector_length+2; seq_idx++)
        begin
            if (seq_idx <2)
            begin 
                send_sequence(seq_idx);
                valid_in = 0;
                repeat(8)
                @(posedge clk);
            end
            else
                send_sequence(seq_idx);
        end
        valid_in = 0;
        @(posedge clk);
    $stop;
end

property check_valid_out();
    @(posedge clk)(valid_in)|-> ##((DELAY))(valid_out);
endproperty

property check_data_out();
    int idx;
    @(posedge clk)(valid_in, idx = test_cnt - 1) |-> ##(2)(out == data_out_gen[idx]) ;
    
endproperty


assert property (check_valid_out())
$display("ok_valid");
else $error("valid out isn't correct ");


assert property (check_data_out())
//     $display("ok_data idx=%0d out=%0d exp=%0d", $sampled(idx), out, data_out_gen[idx]);
        $display($time);
    else $error(" out=%0d exp=%0d idx=%0d", out, data_out_gen[test_cnt], test_cnt);
 
 
 
abs_of_cmplx_num_in_pow2 abs_of_cmplx_num_in_pow2_inst (

   .CLK              (clk),           
//   .rst              (rst),           
   .VALID_IN         (valid_in), 
   .VALID_OUT        (valid_out),     
   // Input Ports - Busses
   .DATA_IM_IN(im),
   .DATA_RE_IN (re),
   // Output Ports - Single Bit
   // Output Ports - Busses
   .DATA_OUT  (out)
   // InOut Ports - Single Bit
   // InOut Ports - Busses
);

endmodule
