//parameter WIDTH = 8;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  Paralle to serial shift Register                                                            //
//                                                                                                                 //
//    Description   :  For each Clock Data will be loaded if start bit is high  Data will Shift when Enabe is high //
//                                                                                                                 //
//    Inputs        :  clk, reset_n, load enable, start A ,B                                                       //
//                                                                                                                 //
//    Outputs       :   A_out, B_out                                                                               //
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////





module shift_register_parallel_to_serial(
   input wire clk,
   input wire reset_n,
   input wire load,
   input wire enable,
   input wire start,
   input wire [WIDTH-1:0] A,
   input wire [WIDTH-1:0] B,
   output reg A_out,
   output reg B_out
);

   reg [WIDTH-1:0] temp_A;
   reg [WIDTH-1:0] temp_B;

   always@(posedge clk) begin
     if (!reset_n) begin  // Reset State 
       A_out <=0;       
       B_out <=0;      
    end

     else begin
         $strobe("Design The data of A is %b and B is %b ",A,B);
         if(load) begin
           temp_A <=A;   // IF its Blocking its shifting X after that its shift normal data
           temp_B <=B;
           $strobe("Design The data of temp_A is %b and temp_B is %b ",temp_A,temp_B,$time);
         end
         if(enable) begin
           temp_A <= temp_A >> 1; 
           temp_B <= temp_B >> 1; 
           $strobe("after enable Design The data of temp_A is %b and temp_B is %b ",temp_A,temp_B);
           A_out  <= temp_A[0];
           B_out  <= temp_B[0]; 
           $strobe("The LSB of A_out is %B_out and B is %b ",A_out,B_out);
         end
     end
   end
 endmodule


// Testbench 

module shift_register_parallel_to_serial_tb  ();
   reg clk;
   reg reset_n;
   reg start;
   reg [WIDTH -1:0] A;
   reg [WIDTH -1:0] B;
   wire A_out;
   wire B_out;
   reg load;
   reg enable;

shift_register_parallel_to_serial PS (
                                        .clk(clk),
                                        .reset_n(reset_n),
                                        .start(start),
                                        .load(load),
                                        .enable(enable),
                                        .A(A),
                                        .B(B),
                                        .A_out(A_out),
                                        .B_out(B_out)
                                     );
initial clk =0;
always #5 clk = ~(clk);
initial begin
    reset_n = 0;
#10;    
   reset_n  = 1;
   A ='hff;
   B ='hff;
   load =1;
#10;    
   enable =1;
   reset_n  = 1;
#10 A ='hff;
#10 B ='hff;
   $display("TB:::The data of A is %b and B is %b ",A,B);
#200;
$stop;
end
endmodule

