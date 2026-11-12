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
reg clk = 0;

reg signed [15:0] re = 16'd0;
reg signed [15:0] im = 16'd0;
wire  [32:0] out;
wire valid_out;
reg valid_in;
reg seq_test;
reg signed [data_width - 1:0 ] data_sim_re [vector_length-1:0];
reg signed [data_width - 1:0 ] data_sim_im [vector_length-1:0];
reg signed [data_width*2 :0 ] data_out_gen [vector_length-1:0];

int test_cnt = 1;
int seq_idx;
int i;
initial begin
    forever #4 
        clk = ~clk;
end


    initial 
        begin
            for (i = 0; i < vector_length; i++)
                begin
                    data_sim_re[i] = data_width'($urandom_range(2**(data_width-1)-1, -1*(2**(data_width-2))));
                    data_sim_im[i] = data_width'($urandom_range(2**(data_width-1)-1, -1*(2**(data_width-2)))); 
                    data_out_gen[i] =  data_sim_re[i]*data_sim_re[i] + data_sim_im[i]*data_sim_im[i];
                end 
        end


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

 task send_max;
    begin
        valid_in = 1'b1;
        re = { 1'b0, {(data_width-1){1'b1}} };
        im = { 1'b0, {(data_width-1){1'b1}} };
        @(posedge clk);
        valid_in = 1'b0;
        re = { (data_width){1'b0} };
        im = { (data_width){1'b0} };
        test_cnt = test_cnt + 1;
    end
 endtask    
 task send_min;
    begin
        valid_in = 1'b1;
        re = { 1'b1, {(data_width-1){1'b0}} };
        im = { 1'b1, {(data_width-1){1'b0}} };
        @(posedge clk);
        valid_in = 1'b0;
        re = { (data_width){1'b0} };
        im = { (data_width){1'b0} };
        test_cnt = test_cnt + 1;
    end
 endtask     
 
 task send_sequence;
 input [$clog2(vector_length)-1:0 ]idx;
    begin
        seq_test = 1'b1;
        valid_in = 1'b1;
        re = data_sim_re[idx];
        im = data_sim_im[idx];
        test_cnt = test_cnt + 1;
        @(posedge clk);
    end
 endtask

 
 initial 
 begin
    @(posedge clk);
    send_max();
 
    repeat (15)
        @(posedge clk);
        
    send_min();
    
    repeat (15)
        @(posedge clk);    

    for ( seq_idx = 0; seq_idx < vector_length; seq_idx++)
        begin
            send_sequence(seq_idx);
        end

end

property check_valid_out();
    @(posedge clk)(valid_in)|-> ##((2))(valid_out);
endproperty

property check_data_out();
    @(posedge clk)(seq_test & valid_in ) |-> ##(2
    )(out == data_out_gen[seq_idx-2]) ;
endproperty


assert property (check_valid_out())
//$display($time);
else $error("valid out isn't correct");


assert property (check_data_out())
    $display(seq_idx);
    else $error(" %0t: out=%0d exp=%0d idx=%0d", 
 $time, out, data_out_gen[seq_idx-2], seq_idx);
endmodule