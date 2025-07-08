
// FSM CODING FOR SHIFTING THE DATA !! 
//typedef enum {RESET=2'b00,LOAD=2'b01,SHIFT=2'b10} state;
//parameter WIDTH=8;


//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  fsm.sv                                                                                     //
//                                                                                                                 //
//    Description   :  FSM contains 3 State RESET LOAD SHIFT based on start and reset_n                            //                 
//                                                                                                                 //
//    Inputs        :  clk,reset_n,start                                                                           //
//                                                                                                                 //
//    Outputs       :  load enable reset                                                                           //
//                                                                                                                 //
                                                                                                                   //
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////









module fsm_operation(
  input reset_n,
  input start,
  input clk,
  output reg reset,
  output reg load,
  output reg enable);
//  output reg[1:0] state;
  reg [WIDTH-1:0] count;
reg [1:0] current_state, next_state;
parameter RESET=2'b00,LOAD=2'b01,SHIFT=2'b10;


  always@(posedge clk) begin

      if (!reset_n) current_state    <= RESET;
      else       current_state       <= next_state;
  end
  
  always@(posedge clk) begin  
  
      case(current_state) 
     
         RESET :  begin
                    if(!reset_n) begin
                      reset      <=  1;
                      load       <=  0;
                      enable     <=  0;
                      $display("IN RESET STATE");
                      next_state <= RESET;
                      count      <=0;
                    end
                    else if(start) begin
                       reset      <=  0;
                       load       <=  1;
                       enable     <=  0;
                       next_state <= LOAD;
                    end
                    //else next_state <= current_state;
                    end

         LOAD  :  begin
                    $display("IN LOAD STATE");
                    if (!start&&reset_n) begin
                       reset     <=   0;
                       load      <=   0;
                       enable    <=   1;
                       next_state <= SHIFT;
                    end
                    else if(!reset_n) begin
                       next_state <= RESET;
                       reset      <=  1;
                       load       <=  0;
                       enable     <=  0;
                       $display("IN RESET STATE");
                       next_state <= RESET;
                    end
                    //else next_state <= current_state;
                  end
         SHIFT : begin 
                    $display("IN SHIFT STATE");
                    if (!start&&reset_n) begin
                       reset     <=   0;
                       load      <=   0;
                       enable    <=   1;
                       next_state <= SHIFT;
                       count <= count +1;
                       if(count == WIDTH) enable    <=   0;
                       else               enable    <=   1;
                     end
                     else if (start && reset_n) 
                       begin
                          next_state <= LOAD;
                         reset      <=  0;
                          load       <=  1;
                          enable     <=  0;
                       end
                    // else begin
                      //    next_state <= RESET;
                       //   reset      <=  1;
                        //  load       <=  0;
                         // enable     <=  0;
                          //$display("IN RESET STATE");
                          //next_state <= RESET;
                      //end
                 end
       endcase
  end
endmodule

// TESTBENCH FOR FSM _CODING
module fsm_operation_tb ;
  wire reset;
  reg start;
  reg clk;
  reg reset_n;
  wire load;
  wire enable;
 

  fsm_operation FSM (
       .reset  (reset),
       .start   (start),
       .clk     (clk),
       .reset_n (reset_n),
       .load    (load),
       .enable  (enable)
   );
  initial begin
     clk= 0;
     reset_n =0;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    #20;   reset_n = 1;
           start  = 1;
    #10; 
 #50;   reset_n =1;
    start  = 0;
    #100;    
     reset_n =1;
     start  = 1;
#20;     
start  = 0;
    #200  $stop;
  end
endmodule


