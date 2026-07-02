/*
-------------------------------------------------------
Moving Average FIR Filter
-------------------------------------------------------
Implements a 4-tap moving average FIR filter using
shift registers and arithmetic averaging.
-------------------------------------------------------
*/

`timescale 1ns/100ps
module moving_average#(
    parameter DATA_WD = 16
)(
    input  logic                      i_clk,
    input  logic                      i_rstb,
    input  logic signed [DATA_WD-1:0] i_data,
    output logic signed [DATA_WD-1:0] o_data
);

// Edit the code here begin ---------------------------------------------------

  
    logic signed [DATA_WD-1:0] pipe [0:3];
  
    logic signed [DATA_WD+1:0] sum;

    always_ff @( posedge i_clk or negedge i_rstb ) begin
        if(!i_rstb) begin
            pipe[0] <= '0;
            pipe[1] <= '0;
            pipe[2] <= '0;
            pipe[3] <= '0;
            o_data  <= '0;
        end else begin
            
            pipe[0] <= i_data;
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            pipe[3] <= pipe[2];
            
            
            o_data  <= sum >>> 2;
        end
    end


    always_comb begin
        sum = pipe[0] + pipe[1] + pipe[2] + pipe[3];
    end

// Edit the code here end -----------------------------------------------------

/*
    Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/moving_average.vcd");
        $dumpvars(0, moving_average);
    end
`endif
   
endmodule
