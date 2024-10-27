/*
 * Copyright (c) 2024 Harald Pretl, IIC@JKU
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "chain1.v"

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
  assign uio_out = ui_in[2] ? out_w[15:8] : out_w[7:0]; 

  chain1 dut(
    .i_clk(clk),
    .i_dat(ui_in[0]),
    .i_load(ui_in[1]),
    .o_dat(uo_out[0]),
    .o_det(uo_out[1]),
    .o_check(uo_out[2]),
    .o_data(out_w)
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:3] = 5'b10000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, uio_in[7:0], ui_in[7:3], 1'b0};

endmodule // tt_um_hpretl_spi
