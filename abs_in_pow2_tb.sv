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
reg valid_in;

reg signed [data_width - 1:0 ] data_sim_re [vector_length-1:0];
reg signed [data_width - 1:0 ] data_sim_im [vector_length-1:0];
reg signed [data_width*2 :0 ] data_out_gen [vector_length-1:0];

initial begin
    forever #4 
        clk = ~clk;
end


    initial 
        begin
            for (int i = 0; i < vector_length; i++)
                begin
                    data_sim_re[i] = data_width'($urandom_range(100 , 0));
                    data_sim_im[i] = data_width'($urandom_range(2**(data_width-2), -32768)); 
                    data_out_gen[i] =  data_sim_re[i]*data_sim_re[i] + data_sim_im[i]*data_sim_im[i];
                end 
        end


abs_of_cmplx_num_in_pow2 abs_of_cmplx_num_in_pow2_inst (

   .clk              (clk),           
//   .rst              (rst),           
   .valid_in         (valid_in),      
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
    end
 endtask     
 
 task send_sequence;
 input [$clog2(vector_length)-1:0 ]idx;
    begin
        valid_in = 1'b1;
        re = data_sim_re[idx];
        im = data_sim_im[idx];
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

    for (int seq_idx = 0; seq_idx < vector_length; seq_idx++)
        begin
            send_sequence(seq_idx);
        end

end


endmodule
