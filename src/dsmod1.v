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
* 16b Delta-Sigma Modulator with Single-Bit Output
*/

`default_nettype none
`ifndef __DSMOD1__
`define __DSMOD1__

module dsmod1(
	input 		[15:0]	i_data,		// data in
	input				i_rst_n,
	input				i_clk,
	input				i_mode, 	// 0 = 1st order, 1 = 2nd order SD-modulator
	output reg			o_ds,		// single-bit SD-modulator output
	output wire			o_ds_n		//  plus the complementary output
);

	reg 		[15:0]	accu1;
	reg			[15:0]	accu2;
	reg			[1:0]	accu3;

	reg			[1:0]	mod2_ctr;	// clk divide by 4 for 1st stage of 2nd order mod.
	reg			[1:0]	mod2_out;	// output 1st stage

	localparam			ORD1 		= 1'd0;
	localparam			ORD2 		= 1'd1;

	// provide out and out_n to make levelshifter easier
  	assign o_ds_n = ~o_ds;

  	always @(posedge i_clk or negedge i_rst_n) begin
		if (i_rst_n == 1'b0) begin
			// reset all registers
			accu1 <= 16'b0;
			accu2 <= 16'b0;
			accu3 <=  2'b0;
			o_ds <= 1'b0;
			mod2_ctr <= 2'b0;
			mod2_out <= 2'b0;
		end else begin
			// sd-modulator is running

			if (i_mode === ORD1) begin
				// delta-sigma modulator 1st order
				// this simple structure works if everything
				// is UINT
				{o_ds,accu1} <= i_data + accu1;
			end else if (i_mode === ORD2) begin
				// delta-sigma modulator 2nd order
				// the first stage runs on clk/4, the second
				// stage runs on clk

				if (mod2_ctr === 2'b0) begin
					// this only happens every 4th clk
					// cycle
					{mod2_out,accu1} <= {2'b00,i_data} 
								+ {1'b0,accu1,1'b0} 
								+ 18'h10000 
								- {2'b0,accu2};
					accu2 <= accu1;
				end

				// this is the clk divider for the 1st stage
				mod2_ctr <= mod2_ctr + 1'b1;
				
				// this simple structure is the 2nd stage
				// running on clk
				{o_ds,accu3} <= mod2_out + accu3;
			end
		end
	end
endmodule // dsmod1

`endif
`default_nettype wire
