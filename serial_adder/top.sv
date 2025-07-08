
parameter WIDTH=8;


//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  top.sv                                                                                    //
//                                                                                                                //
//    Description   :  All the sub block modules are included                                                     //
//                                                                                                                //
//    Inputs        :  clock_top,reset_n_top,A_top B_top,start_top                                                //
//                                                                                                                //
//    Outputs       :  sum_top                                                                                    //
//                                                                                                                //
                                                                                                                  //
//                                                                                                                //
//                                                                                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////





`include "fsm.sv"
`include "full_adder.sv"
`include "parallel_to_serial_sr.sv"
`include "serial_parallel.sv"
`include "d_ff.sv"

module top(

   input [WIDTH-1:0] A_top,
   input [WIDTH-1:0] B_top,
   input clock_top,
   input resetn_top,
   input start_top,
   output [WIDTH:0] final_sum
   );
// internal signals 
   reg A_out_top;
   reg [WIDTH-1:0] sum_top;
   reg B_out_top;
   reg reset_top;
   reg load_top;
   reg enable_top;
   reg cin_top;
   reg cout_top;
   reg sum_out_top;

//PISO REGISTER
shift_register_parallel_to_serial PS (
                                        .clk(clock_top),
                                        .reset_n(resetn_top),
                                        .start(start_top),
                                        .load(load_top),
                                        .enable(enable_top),
                                        .A(A_top),
                                        .B(B_top),
                                        .A_out(A_out_top),
                                        .B_out(B_out_top)
                                     );

// FULL ADDER
 full_adder FA                      (
                                      .A_out(A_out_top),
                                      .B_out(B_out_top),
                                      .cin(cin_top), // doubt
                                      .cout(cout_top),//output 
                                      .sum_out(sum_out_top)//output

                                    );

// D_FLIP_FLOP

 d_flip_flop                  DFF(
                                    .clk(clock_top),
                                    .reset(reset_top),
                                    .Q(cin_top),
                                    .D(cout_top)  
                                 );


//FSM

 fsm_operation FSM                 (
                                     .reset_n  (resetn_top),
                                     .start    (start_top),
                                     .clk      (clock_top),
                                     .reset    (reset_top),
                                     .load     (load_top),
                                     .enable   (enable_top)
                                   );



// SIPO REGISTER
shift_register_serial_parallel SP(
                                    .clk(clock_top),
                                    .reset_n(reset_top),
                                    .sum(sum_top),
                                    .sum_out(sum_out_top),
                                    .enable(enable_top)
                                   // .load(load)
                                  );
    

//assign final_sum = (});
   assign final_sum = ({cin_top,sum_top});


endmodule

module top_sb_check_fsm;

   bit [WIDTH -1:0] A_sb;
   bit [WIDTH -1:0] B_sb;
   reg clk;
   reg reset_n;
   reg start;
   wire [WIDTH :0] sum_out_sb;

   top  SF      (  
                      .clock_top(clk),
                      .resetn_top(reset_n),
                      .start_top(start),
                      .A_top(A_sb),
                      .B_top(B_sb),
                      .final_sum(sum_out_sb)
                   );
 initial clk =0;
   always #5 clk = ~(clk);

initial begin
  start    = 0;
  reset_n  = 0;
#10;
  @(posedge clk);  // apply reset
  reset_n  = 1;
  @(posedge clk);  // come out of reset
  A_sb = $random;
     B_sb = $random;

  start = 1;
  @(posedge clk);  // go to LOAD state
  A_sb = $random;
     B_sb = $random;

  start = 0;
  reset_n = 0;     // THIS triggers the missing condition
  @(posedge clk);
  A_sb = $random;
     B_sb = $random;

  start = 0;
  reset_n = 1;
  @(posedge clk);
    clk = 0;
    reset_n = 0;
    start = 0;

    // Apply Reset
    @(posedge clk);
    reset_n = 0;
    @(posedge clk);
    reset_n = 1; // Come out of reset

    // Test: RESET → LOAD
    start = 1;
    @(posedge clk);

    // Test: LOAD → SHIFT (start=0)
    start = 0;
    @(posedge clk);

    // Test: SHIFT with count < WIDTH
    repeat (3) @(posedge clk);  // Let SHIFT stay with enable = 1

    // Test: SHIFT → LOAD again (start=1)
    start = 1;
    @(posedge clk);

    // Test: LOAD with reset_n=0 → go back to RESET
    start = 1;
    reset_n = 0;
    @(posedge clk);

    // Test: back to RESET state, ensure transitions again
    reset_n = 1;
    @(posedge clk);

    start = 1;
    @(posedge clk); // LOAD
    start = 0;
    @(posedge clk); // SHIFT

    // Final case: SHIFT state with start = 0 and reset_n = 0
    // To hit the missing (start=0, reset_n=0) condition coverage
    reset_n = 0;
    @(posedge clk);

    // Restore normal values
    reset_n = 1;
    start = 1;
    @(posedge clk);
     reset_n = 0;start = 0;
     #20;  
  repeat (40) begin
     reset_n = 1;
     start  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #100;
  end
 repeat (10) begin
     reset_n = 1;
     start  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #20 start  = 1;
     reset_n = 0;
     #40;
  end
 repeat (10) begin
     reset_n = 0;
     start  = 1;
     A_sb = $random;
     B_sb = $random;
    // #20 start  = 0;
     //#20 start  = 1;
     #40 reset_n = 1;
     #40;
  end
   #20;  
  repeat (5) begin
     reset_n = 0;
     start  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #50;
     start = ~(start);
     reset_n = ~(reset_n);
  end
  repeat (5) begin
     reset_n = 1;
     start  = 0;
     A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #50;
     start = ~(start);
     reset_n = ~(reset_n);
  end
start  = 1;
     A_sb = 'h00;
     B_sb = 'h00;
     #20 start  = 0;
      reset_n = 1;
     #10;
     start  = 1;
     A_sb = 'h20;
     B_sb = 'h30;
     reset_n = 0;

     #10 start  = 0;
     reset_n  = 0;
     #10;

 #10 start  = 0;
     reset_n  = 1;
 A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #100;

  #20 start  = 0;
      reset_n = 1;
     #10;
  A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #100;
 
      start  = 1;
      reset_n = 1;
   A_sb = $random;
     B_sb = $random;
     #20 start  = 0;
     #100;
 
     A_sb = 'h20;
     B_sb = 'h30;
     reset_n = 0;
     #10 start  = 0;
     reset_n  = 0;
     #10;
#200 $stop;

end
    //$display("Finished simulation for full coverage.");
    //$finish;
//end
endmodule

// TEST BENCH 
module top_tb  ();
   reg [WIDTH -1:0] A_sb;
   reg [WIDTH -1:0] B_sb;
   reg clock_sb;
   reg resetn_sb;
   reg start_sb;
   wire [WIDTH :0] sum_out_sb;

   top  SF      (  
                      .clock_top(clock_sb),
                      .resetn_top(resetn_sb),
                      .start_top(start_sb),
                      .A_top(A_sb),
                      .B_top(B_sb),
                      .final_sum(sum_out_sb)
                   );
   initial clock_sb =0;
   always #5 clock_sb = ~(clock_sb);
   
   initial begin
     resetn_sb = 0;start_sb = 0;
     #20;  
  repeat (4) begin
     resetn_sb = 1;
     start_sb  = 1;
     //A_sb = 'd32;//$random;
     A_sb = 'b11101011;//$random;
     B_sb = 'b11111011;//$random;
     #20 start_sb  = 0;
     #200;
 start_sb  = 1;
     A_sb = 'b11000000;//$random;
     B_sb = 'b10000000;//$random;
     #20 start_sb  = 0;
     #100;
 start_sb  = 1;
     A_sb = 'd126;//$random;
     B_sb = 'd240;//$random;
     #20 start_sb  = 0;
     #100;
 start_sb  = 1;
     A_sb = 'b1010101;//$random;
     B_sb = 'b1010101;//$random;
     #20 start_sb  = 0;
     #100;

  end/*
 repeat (10) begin
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #20 start_sb  = 1;
     resetn_sb = 0;
     #40;
  end
 repeat (10) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
    // #20 start_sb  = 0;
     //#20 start_sb  = 1;
     #40 resetn_sb = 1;
     #40;
  end

    #20;  
  repeat (5) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
  repeat (5) begin
     resetn_sb = 1;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
repeat (5) begin
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
repeat (8) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end

repeat (5) begin
     resetn_sb = 0;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end


 repeat (2) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = 'd32;//$random;
     B_sb = 'd35;//$random;
     #20 start_sb  = 0;
     #50;
  end

    resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #10;
      resetn_sb = 0;

     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     start_sb  = 0;
     #30;
     resetn_sb = 1;

     #50;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     start_sb  = 1;
     #30;
     resetn_sb = 1;
     #30;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40 resetn_sb = 0;
     start_sb  = 1;
#40;
#30;
     resetn_sb = 0;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
#40;
#30;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40;

#30;
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40;





     A_sb = $random;
     B_sb = $random;

    start_sb  = 1;
     A_sb = 'h00;
     B_sb = 'h00;
     #20 start_sb  = 0;
      resetn_sb = 1;
     #10;
     start_sb  = 1;
     A_sb = 'h20;
     B_sb = 'h30;
     resetn_sb = 0;

     #10 start_sb  = 0;
     resetn_sb  = 0;
     #10;

 #10 start_sb  = 0;
     resetn_sb  = 1;
 A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;

  #20 start_sb  = 0;
      resetn_sb = 1;
     #10;
  A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;
 
      start_sb  = 1;
      resetn_sb = 1;
   A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;
 
     A_sb = 'h20;
     B_sb = 'h30;
     resetn_sb = 0;
     #10 start_sb  = 0;
     resetn_sb  = 0;
     #10;
*/
/*
repeat(20) begin
    resetn_sb = 1;
     start_sb  = 1;
     A_sb = 'd25;
     B_sb = 'd25;
#20;
     start_sb  = 0;
    // start_sb  = 0;
    resetn_sb = 0;
#20;
 start_sb  = ~(start_sb);
       resetn_sb = ~(resetn_sb);

end
//end

 //////  load



     repeat(500) begin  
       resetn_sb = 1;
       start_sb  = 1;
       A_sb = $urandom;
       B_sb = $urandom;
       #20 start_sb  = 0;
       #100;
     end
     repeat(10) begin
       resetn_sb = 0;
       start_sb  = 1;
       A_sb = $urandom_range('d0,'d255);
       B_sb = $urandom_range('d0,'d255);
       #20 start_sb  = 0;
       #100;
     end
     #50;

       resetn_sb = 1;
       start_sb  = 0;
       A_sb = $urandom_range('d0,'d255);
       B_sb = $urandom_range('d0,'d255);
     #50;
     repeat (4) begin
       start_sb  = ~(start_sb);
       resetn_sb = ~(resetn_sb);
       A_sb = $urandom_range('d50,'d100);
       B_sb = $urandom_range('d40,'d60);
       #40;
       A_sb = 'D255;
       B_sb = 'D255;
       #50;
     end   
      #50;
      start_sb =0; resetn_sb=0;
      #50;
      start_sb =1; resetn_sb=0;
      #50;
      start_sb =0; resetn_sb=1;
      #50;
      start_sb =1; resetn_sb=1;
      #50;
      start_sb =1; resetn_sb=0;
      #50;
      start_sb =0; resetn_sb=1;
      #50;
     repeat (2) begin
       start_sb = ~(start_sb);
       resetn_sb = ~(resetn_sb);
       A_sb = 'h00;
       B_sb = 'h00;
       #40;
       A_sb = 'D255;
       B_sb = 'D255;
       #50;
     end   

     #20;
     resetn_sb = 0;start_sb = 0;
       A_sb = $random;
       B_sb = $random;
       #20 start_sb  = 0;
       #100;

     #50;
       resetn_sb = 1;start_sb = 1;
       A_sb = $random;
       B_sb = $random;


     #50;
       resetn_sb = 1;start_sb = 0;
       A_sb = $random;
       B_sb = $random;

     #50;
       resetn_sb = 1;start_sb = 1;
       A_sb = $random;
       B_sb = $random;

 #50; resetn_sb = 0;start_sb = 1;


       A_sb = $random;
       B_sb = $random;
*/
    // #20 start_sb  = 0;
     #300 $stop;   
  end
endmodule















