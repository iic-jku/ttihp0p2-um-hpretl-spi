/*
 * Copyright (c) 2024 Harald Pretl, IIC@JKU
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "chain2.v"
`include "dsmod1.v"

module tt_um_hpretl_spi (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [15:0] out_w;

  assign uio_oe = 8'b11111111;  // using IO for output
  assign uio_out = ui_in[3] ? out_w[15:8] : out_w[7:0]; 

  chain2 spi(
    .i_resetn(rst_n),
    .i_clk(clk),
    .i_spi_clk(ui_in[0]),
    .i_spi_dat(ui_in[1]),
    .i_spi_load(ui_in[2]),
    .o_spi_dat(uo_out[0]),
    .o_det(uo_out[1]),
    .o_check(uo_out[2]),
    .o_data(out_w)
  );

  dsmod1 dac(
    .i_data(out_w),
    .i_rst_n(rst_n),
    .i_clk(clk),
    .i_mode(ui_in[7]),
    .o_ds(uo_out[7]),
    .o_ds_n(uo_out[6])
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[5:3] = 3'b000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:0], ui_in[6:4], 1'b0};

endmodule // tt_um_hpretl_spi
