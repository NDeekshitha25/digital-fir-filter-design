/*
-------------------------------------------------------
Fixed-Point FIR Filter
-------------------------------------------------------
Implements a parameterized FIR filter using
shift registers and multiply-accumulate (MAC)
operations. The output is scaled using fixed-point
arithmetic with saturation logic.
-------------------------------------------------------
*/

`timescale 1ns/100ps
module fir_filter(
    input  logic               i_clk,
    input  logic               i_rstb,
    input  logic signed [15:0] i_data,
    input  logic signed [15:0] i_coeff0,
    input  logic signed [15:0] i_coeff1,
    input  logic signed [15:0] i_coeff2,
    input  logic signed [15:0] i_coeff3,
    output logic signed [15:0] o_data
);

// Edit the code here begin ---------------------------------------------------

    logic signed [15:0] data [0:3];
    logic signed [33:0] sum;
    logic signed [17:0] scaled_sum;

    always_ff @(posedge i_clk or negedge i_rstb) begin
        if(!i_rstb) begin
            data[0] <= '0;
            data[1] <= '0;
            data[2] <= '0;
            data[3] <= '0;
        end
        else begin
            data[0] <= i_data;
            data[1] <= data[0];
            data[2] <= data[1];
            data[3] <= data[2];
        end
    end

    always_comb begin
        sum = (data[0] * i_coeff0) + 
              (data[1] * i_coeff1) + 
              (data[2] * i_coeff2) + 
              (data[3] * i_coeff3);

        scaled_sum = sum >>> 16;

        if (scaled_sum > 18'sd32767) begin
            o_data = 16'sh7FFF; 
        end
        else if (scaled_sum < -18'sd32768) begin
            o_data = 16'sh8000; 
        end
        else begin
            o_data = scaled_sum[15:0]; 
        end
    end

// Edit the code here end -----------------------------------------------------

/* 
    Following section is necessary for dumping waveforms. This is needed for debug and simulations 
*/
`ifndef DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/fir_filter.vcd");
        $dumpvars(0, fir_filter);
    end
`endif

endmodule
