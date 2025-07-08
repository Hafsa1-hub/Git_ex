
//parameter WIDTH = 8;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  full_adder.sv                                                                               //
//                                                                                                                 //
//    Description   :  Full adder will perform adder operation for given input A+B+C and assign it to output       //
//                                                                                                                 //
//    Inputs        :  A_out,B_out, cin, sum_out,cout                                                              //
//                                                                                                                 //
//    Outputs       :   sum_out, c_out                                                                             //
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////



module full_adder (
    input  A_out,
    input  B_out,
    input  cin,
    output sum_out,
    output cout
    );
   assign sum_out = A_out^ B_out ^ cin;
   assign cout    = ((A_out & B_out)| (B_out & cin)| (cin & A_out));

endmodule

///test bench

module full_adder_tb;
  reg A_out;
  reg B_out;
  reg cin;
  reg cout;
  wire sum;
  full_adder FA(
                 .A_out(A_out),
                 .B_out(B_out),
                 .cin(cin),
                 .cout(cout),
                 .sum(sum)
               );
 initial begin
    A_out =0;
    B_out =0;
    cin =0;
    // carry_in =D;
    #10;
    A_out =0;
    B_out =1;
    #10
   A_out =1;
   B_out =0;
   cin =1;
   #10
   A_out =1;
   B_out =1;
    cin =0;
   #10
    A_out =1;
    B_out =1;
    cin =1;

   #500$stop;
 
 end
endmodule
