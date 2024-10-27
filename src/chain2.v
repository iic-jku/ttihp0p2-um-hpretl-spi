/*  
    SPDX-FileCopyrightText: 2024 Harald Pretl
    Johannes Kepler University, Institute for Integrated Circuits
    SPDX-License-Identifier: Apache-2.0

   Very simple scan chain with load register and magic cookie detection for
   SG13G2 TinyTapeout Nov'2024 run. Target is to test RTL2GDS flow for functionality. 

   The output o_check is XOR of i_dat and i_load (pure logic in case all else
   fails).

   IO description:

    i_clk (high running clock to sample the SPI input lines)
    i_spi_clk (like SPI SCLK)
    i_spi_dat (like SPI MOSI)
    i_spi_load (like SPI nCS)
    o_spi_dat (like SPI MISO)
    o_det (magic cookie detected)
    o_check (XOR of i_dat and i_load)
*/

`ifndef __CHAIN2__
`define __CHAIN2__
`default_nettype none

module chain2 (
    input wire          i_resetn,
    input wire          i_clk,
    input wire          i_spi_clk,
    input wire          i_spi_dat,
    input wire          i_spi_load,
    output wire         o_spi_dat,
    output wire         o_det,
    output wire         o_check,
    output wire [15:0]  o_data
);

    reg [15:0] scan_r, data_r;
    reg last_spi_clk_r;

    // here we see if the stored content is matching a magic cookie
    assign o_det = (data_r === 16'hcafe) ? 1'b1 : 1'b0;
    // provide loaded data
    assign o_data = data_r;
    // shift out MSB register bit
    assign o_spi_dat = scan_r[15];

    // here the scan chain, shift MSB first (as in SPI)
    always @(posedge i_clk or negedge i_resetn) begin
        if (i_resetn === 1'b0) begin
            scan_r <= 16'b0;
            data_r <= 16'b0;
            last_spi_clk_r <= 1'b0;
        end else begin
            if ((i_spi_load === 1'b0) && (i_spi_clk === 1'b1) && (last_spi_clk_r === 1'b0))
                scan_r <= {scan_r[14:0],i_spi_dat};

            if (i_spi_load === 1'b1)
                data_r <= scan_r;

            last_spi_clk_r <= i_spi_clk;
        end
    end

    // here a very simple boolean function to check basic functionality
    assign o_check = i_spi_dat ^ i_spi_load;

endmodule // chain2
`endif 
