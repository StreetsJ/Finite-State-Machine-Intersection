`timescale 1ns / 1ps 
`default_nettype none
`define one_sec 1
`define three_sec 3
`define fifteen_sec 15
`define thirty_sec 30 

module tlc_fsm(
    output reg [2:0] state,     //output for debugging 
    output reg RstCount,        //will be used in always block 
                                //seperate always block for ports below 
    output reg [1:0] highwaySignal, farmSignal,
    input wire farmSensor,      //sensor for farm road light efficiency 
    input wire [30:0] Count,    // will use n as computed earler  (n=31 - 1 =30)
    input wire Clk, Rst         // clock & reset 
    );
    //define states and colors as parameters 
    parameter Srst = 3'b111,
              S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100,
              S5 = 3'b101,
              red = 2'b01,
              green = 2'b11,
              yellow = 2'b10;
              
    //intermediate nets
    reg [2:0] nextState;  
    
    always@(*) 
    case(state) 
        Srst:
            begin             
                farmSignal = red;
                highwaySignal = red; 
                RstCount = 1;
                nextState = S0; 
            end 
        S0: 
        begin                   
            farmSignal = red;
            highwaySignal = red; 
            if(Count == `one_sec) begin
                nextState = S1;
                RstCount = 1;end    
            else begin
                nextState = S0;
                RstCount = 0; end
        end
        S1: 
        begin                  
            farmSignal = red;
            highwaySignal = green;
            if(Count >= `thirty_sec)begin
                if( farmSensor == 1) begin
                    nextState = S2; 
                    RstCount = 1; end end
            else begin
                nextState = S1; 
                RstCount = 0; end
        end
        S2: 
        begin               
            farmSignal = red;
            highwaySignal = yellow;
            if(Count == `three_sec) begin
                nextState = S3;
                RstCount = 1; end
            else begin
                nextState = S2;
                RstCount = 0; end
        end
        S3: 
        begin        
            farmSignal = red;
            highwaySignal = red;
            if(Count == `one_sec) begin
                nextState = S4;
                RstCount = 1; end
            else begin
                nextState = S3;
                RstCount = 0; end
        end
        S4: 
        begin               
            farmSignal = green;
            highwaySignal = red;
            if(Count == `fifteen_sec || (farmSensor == 0 && Count == `three_sec)) begin
                nextState = S5;
                RstCount =1; end
            else begin
                nextState = S4;
                RstCount =0; end     
        end
        S5: 
        begin            
            farmSignal = yellow;
            highwaySignal = red;
            if(Count == `three_sec) begin
                nextState = S0;
                RstCount = 1; end
            else begin
                nextState = S5;
                RstCount =0; end
        end
    endcase
  
    always@(posedge Clk)
        begin
            if(Rst)                    
                state <= Srst; 
            else
                state <= nextState; 
        end 
        
endmodule
