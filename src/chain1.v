/*  
    SPDX-FileCopyrightText: 2024 Harald Pretl
    Johannes Kepler University, Institute for Integrated Circuits
    SPDX-License-Identifier: Apache-2.0

   Very simple scan chain with load register and magic cookie detection for
   SG13G2 May'2024 run. Target is to test RTL2GDS flow for functionality. 

   The output o_check is XOR of i_dat and i_load (pure logic in case all else
   fails).

   8 pins available on testchiplet:

    1 = VDD
    2 = VSS
    3 = i_clk (like SPI SCLK)
    4 = i_dat (like SPI MOSI)
    5 = i_load (like SPI nCS)
    6 = o_dat (like SPI MISO)
    7 = o_det (magic cookie detected)
    8 = o_check (XOR of i_dat and i_load)
*/

`ifndef __CHAIN1__
`define __CHAIN1__
`default_nettype none

module chain1 (
    input wire          i_clk,
    input wire          i_dat,
    input wire          i_load,
    output wire         o_dat,
    output wire         o_det,
    output wire         o_check,
    output wire [15:0]  o_data
);

    reg [15:0] scan_r, data_r;

    // here we see if the stored content is matching a magic cookie
    assign o_det = (data_r === 16'hcafe) ? 1'b1 : 1'b0;
    // provide loaded data
    assign o_data = data_r;
    // shift out MSB register bit
    assign o_dat = scan_r[15];

    // here the scan chain, shift MSB first (as in SPI)
    always @(posedge i_clk) begin
        if (i_load === 1'b0)
            scan_r <= {scan_r[14:0],i_dat};
    end

    // and here we latch the result
    always @(posedge i_load) begin
        data_r <= scan_r;
    end

    // here a very simple boolean function to check basic functionality
    assign o_check = i_dat ^ i_load;

endmodule // chain1
`endif 

