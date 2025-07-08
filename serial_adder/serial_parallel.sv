
//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  serial_parallel.sv                                                                          //
//                                                                                                                 //
//    Description   :  Serial data will be shifted when enable is high                                             //
//                                                                                                                 //
//    Inputs        :  clk,reset_n.enable,sum_out                                                                  //
//                                                                                                                 //
//    Outputs       :  sum                                                                                         //
//                                                                                                                 //
                                                                                                                   //
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module shift_register_serial_parallel (
    input  clk,
    input  reset_n,
    input  enable,
    input  sum_out,
    output reg [WIDTH-1:0] sum
    );

    reg [WIDTH-1:0] reg_data;
    reg [3:0] count;
    
     always @(posedge clk) begin
        if (reset_n)     begin 
             reg_data <= '0;
            count <=0;
        end
  
        else if (enable) begin

               reg_data <= {sum_out, reg_data[WIDTH-1:1]}; // Shift right

               count <= count + 1;
        end
        if (count == WIDTH) begin   sum <= reg_data; count <= 0; end
    end
//assign sum = reg_data;
endmodule






// test bench*/

module shift_register_serial_parallel_tb;
  reg clk;
  reg reset_n;
  reg sum_out;
  reg enable;
  wire[WIDTH:0] sum;

shift_register_serial_parallel SP(
                                    .clk(clk),
                                    .reset_n(reset_n),
                                    .sum_out(sum_out),
                                    .enable(enable),
                                    .sum(sum)
                                  );
  initial begin
     clk = 0;
     reset_n =0;
    enable  ='d0;
  end
 always #5 clk =~clk;
 initial begin
     #10 reset_n = 1;
     #20 reset_n = 0;
         sum_out = 1;
         //$display("The value of sum_out is %d ",sum_out);
         enable  ='d1;
         sum_out = 1;
	 //$display("The value of sum_out is %d ",sum_out);
      sum_out = 1;
    //     $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 1;
      //   $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 0;
       //  $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 0;
         //$display("The value of sum_out is %d ",sum_out);
 #10 sum_out = 0;
    //     $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 1;
      //   $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 0;
       //  $display("The value of sum_out is %d ",sum_out);
     #10 sum_out = 1;
         //$display("The value of sum_out is %d ",sum_out);
     #100;
         $stop;
 end
 endmodule

