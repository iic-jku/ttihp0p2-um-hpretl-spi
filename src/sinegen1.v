/*
* SPDX-FileCopyrightText: 2022-2024 Harald Pretl
* Johannes Kepler University, Institute for Integrated Circuits
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* SPDX-License-Identifier: Apache-2.0
*
* Simple sine-generator based on LUT.
*/

`default_nettype none
`ifndef __SINEGEN1__
`define __SINEGEN1__

module sinegen1 (
	output wire	[15:0]	o_data,
	input				i_rst_n,
	input				i_clk,
	input [15:0]		i_step,
	input [1:0]			i_scale
);

	reg	[4:0]			read_ptr_r;
	reg	[15:0]			ctr_r;
	reg					ctr_msb_last_r;
	wire [3:0]			scale_w;

	// this bitpattern is a 16b UINT sine with a period of 32 samples with
	// 90% amplitude and an offset of 0x8000
	/* verilator lint_off LITENDIAN */
	localparam [0:(32*16)-1] sin_const = {
		16'h8000,16'h9679,16'hAC16,16'hC000,16'hD175,16'hDFC9,16'hEA6E,16'hF0FD,
		16'hF333,16'hF0FD,16'hEA6E,16'hDFC9,16'hD175,16'hC000,16'hAC16,16'h9679,
		16'h8000,16'h6987,16'h53EA,16'h4000,16'h2E8B,16'h2037,16'h1592,16'h0F03,
		16'h0CCD,16'h0F03,16'h1592,16'h2037,16'h2E8B,16'h4000,16'h53EA,16'h6987
	};
	/* verilator lint_on LITENDIAN */

	assign scale_w = i_scale << 2;

	assign o_data = sin_const[read_ptr_r*16 +: 16] >> scale_w;

	always @(posedge i_clk or negedge i_rst_n) begin
		if (i_rst_n === 1'b0) begin
			// reset all registers
			read_ptr_r <= 5'b0;
			ctr_r <= 16'b0;
			ctr_msb_last_r <= 1'b0;
		end else begin
			// the ctr is incremented by the step size control from outside
			ctr_r <= ctr_r + i_step;
			ctr_msb_last_r <= ctr_r[15];

			// on a ctr overflow the read pointer is incremented; the input step
			// allows thus to control the frequency of the generated sine
			if ((ctr_r[15] === 1'b0) && (ctr_msb_last_r === 1'b1))
				read_ptr_r <= read_ptr_r + 1'b1;
		end
	end

endmodule // sinegen1

`endif
`default_nettype wire
